
import UIKit
import RxSwift
import RxCocoa

private let studentTableCell = "studentTableCell"

/// Provider to add students to the specific course.
public class CourseAddStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, KeyboardHandler {
    
    /// :nodoc:
    public var scrollView: UIScrollView = UIScrollView()
    
    /// :nodoc:
    public var contentView: UIView = UIView()
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: CourseAddStudentViewModel
    
    /// :nodoc:
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.bounces = false
        return tv
    }()
    
    /**
     Constructor of the class.
     
     - Parameters:
        - course: the course instance.
     
     - Precondition: `course` must be non-nil.
     
     - Postcondition:
     Controller will be initialized.
     */
    init(course: Course) {
        viewModel = CourseAddStudentViewModel(course: course)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    lazy var selectedCount: UIBarButtonItem = {
        return UIBarButtonItem(title: "", style: .done, target: self, action: #selector(appendTapped))
    }()
    
    /// :nodoc:
    lazy var searchController: UISearchController = {
        let sv = UISearchController(searchResultsController: nil)
        sv.dimsBackgroundDuringPresentation = false
        sv.hidesNavigationBarDuringPresentation = false
        sv.searchBar.autocorrectionType = .no
        sv.searchBar.autocapitalizationType = .none
        sv.searchResultsUpdater = self
        sv.obscuresBackgroundDuringPresentation = false
        sv.searchBar.placeholder = "Search Students"
        return sv
    }()
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Students"
        self.view.backgroundColor = .white
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.setRightBarButton(selectedCount, animated: false)
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.register(StudentTableCell.self, forCellReuseIdentifier: studentTableCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        tableView.dataSource = self
        tableView.delegate = self
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        bindUI()
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        viewModel.loadPageTrigger.onNext(())
        
        viewModel.success.asObservable()
            .subscribe(onNext: { [unowned self] (_) in
                self.showDismissAlert("Students has been added successfully")
            }).disposed(by: disposeBag)
        
        viewModel.failure.asObservable()
            .subscribe(onNext: { [unowned self] (error) in
                switch error {
                case .apiMessage(let response):
                    self.showErrorAlert(message: response.message)
                case .api(let response):
                    self.showErrorAlert(message: response.errorDesc)
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    /// :nodoc:
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    /// :nodoc:
    @objc
    private func appendTapped(_ sender: UIBarButtonItem) {
        if viewModel.selectedStudents.value.count > 0 {
            let alertController = UIAlertController(title: "Are you sure?", message: "\(viewModel.selectedStudents.value.count) students are selected. You sure you want to append all?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Append", style: .default) { (_) in
                self.viewModel.appendStudentsTrigger.onNext(())
                self.navigationItem.setRightBarButton(nil, animated: true)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(yes)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Controls if search bar is empty or not.
     
     - Returns:
     true or false.
     */
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
     Controls if search bar is filtering right now. To return true search controller must be active and search bar must not be empty.
     
     - Returns:
     true or false.
     */
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    /**
     It controls the given text to the specified attributes of students. If text found in username for example, the user will append in filtered content and monitored in screen. It is a kind of search function.
     
     - Parameters:
        - searchText: Query that is entered by logged user.
     
     - Precondition: searchText must be non-nil.
     - Precondition: searchText must be contains at least one character, number etc. not whitespaces.
     
     - Postcondition:
     If query will found in username, firstname, lastname, email or student id, the user will append in filtered content and the user interface refreshed to display filtered content.
     */
    func filterContentForSearchText(_ searchText: String) {
        let filteredStudents = viewModel.students.value.filter { (user) -> Bool in
            let query = searchText.lowercased()
            let studentId = user.studentID ?? ""
            return user.username.lowercased().contains(query) || user.firstName.lowercased().contains(query) || user.lastName.lowercased().contains(query) || user.email.lowercased().contains(query) || studentId.lowercased().contains(query)
        }
        
        viewModel.filteredStudents.accept(filteredStudents)
        tableView.reloadData()
    }
    
    /// :nodoc:
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return viewModel.filteredStudents.value.count
        }
        
        return 0
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: studentTableCell, for: indexPath) as? StudentTableCell else { return UITableViewCell() }
        
        if isFiltering() {
            let student = viewModel.filteredStudents.value[indexPath.row]
            let contains = viewModel.selectedStudents.value.contains(where: { $0.id == student.id })
            cell.selectedBefore = contains
            cell.configure(student)
        }
        
        return cell
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StudentTableCell {
            if !cell.selectedBefore {
                cell.selectedBefore = true
                let selectedStudent = viewModel.filteredStudents.value[indexPath.row]
                var students = viewModel.selectedStudents.value
                let contains = students.contains(where: { $0.id == selectedStudent.id })
                if !contains {
                    students.append(selectedStudent)
                }
                
                viewModel.selectedStudents.accept(students)
                selectedCount.title = "\(viewModel.selectedStudents.value.count) Append"
            } else {
                cell.selectedBefore = false
                let deselectedStudent = viewModel.filteredStudents.value[indexPath.row]
                var students = viewModel.selectedStudents.value
                for (index, student) in students.enumerated() {
                    if student.id == deselectedStudent.id {
                        students.remove(at: index)
                    }
                }
                
                viewModel.selectedStudents.accept(students)
                selectedCount.title = "\(viewModel.selectedStudents.value.count) Append"
            }
        }
    }
    
    /// :nodoc:
    public func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            var frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        if #available(iOS 11.0, *) {
            frame.size.height -= view.safeAreaInsets.bottom
        } else {
            frame.size.height -= bottomLayoutGuide.length
        }
        
        var contentInset: UIEdgeInsets = .zero
        contentInset.bottom = frame.size.height
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    /// :nodoc:
    public func keyboardWillHide(notification: Notification) {
        var contentInset: UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = 50
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = .zero
    }
}

/// :nodoc:
extension CourseAddStudentViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
