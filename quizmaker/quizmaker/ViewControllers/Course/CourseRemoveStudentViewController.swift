
import UIKit
import RxSwift

private let studentTableCell = "studentTableCell"

/// Provider to remove students from the specific course.
public class CourseRemoveStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: CourseRemoveStudentViewModel
    
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
        viewModel = CourseRemoveStudentViewModel(course: course)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.navigationItem.title = "Remove Students"
        self.view.backgroundColor = .white
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
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
                let alertController = UIAlertController(title: nil, message: "Student has been removed successfully", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    self.searchController.searchBar.text = ""
                    self.tableView.reloadData()
                })
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
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
    private func removeTapped(_ indexPath: IndexPath) {
        var student = viewModel.students.value[indexPath.row]
        if isFiltering() {
            student = viewModel.filteredStudents.value[indexPath.row]
        }
        
        let alertController = UIAlertController(title: "Are you sure?", message: "You will remove \(student.username) from the course. The operation cannot be undone", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Remove", style: .default) { (_) in
            self.viewModel.removeStudentTrigger.onNext(student.id)
        }
        
        alertController.addAction(cancel)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
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
        
        return viewModel.students.value.count
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: studentTableCell, for: indexPath) as? StudentTableCell else { return UITableViewCell() }
        
        if indexPath.row < viewModel.students.value.count {
            var student = viewModel.students.value[indexPath.row]
            
            if isFiltering() {
                student = viewModel.filteredStudents.value[indexPath.row]
            }
            
            cell.configure(student)
        }
        
        return cell
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeStudent = UITableViewRowAction(style: .normal, title: "Remove") { (action, indexPath) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        return [removeStudent]
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeStudent = UIContextualAction(style: .normal, title: "Remove") { (_, _, _) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        let configuration = UISwipeActionsConfiguration(actions: [removeStudent])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

/// :nodoc:
extension CourseRemoveStudentViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
