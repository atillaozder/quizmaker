import UIKit
import RxSwift
import RxCocoa

private let studentTableCell = "studentTableCell"

class CourseAppendStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let disposeBag = DisposeBag()
    let viewModel: CourseAppendStudentViewModel
    
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
    
    init(courseID: Int) {
        viewModel = CourseAppendStudentViewModel(courseID: courseID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var selectedCount: UIBarButtonItem = {
       return UIBarButtonItem(title: "", style: .done, target: self, action: #selector(appendTapped))
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Append Students"
        self.view.backgroundColor = .white
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.setRightBarButton(selectedCount, animated: false)
        
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
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let filteredStudents = viewModel.students.value.filter { (user) -> Bool in
            let query = searchText.lowercased()
            let studentId = user.studentID ?? ""
            return user.username.lowercased().contains(query) || user.firstName.lowercased().contains(query) || user.lastName.lowercased().contains(query) || user.email.lowercased().contains(query) || studentId.lowercased().contains(query)
        }
        
        viewModel.filteredStudents.accept(filteredStudents)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return viewModel.filteredStudents.value.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: studentTableCell, for: indexPath) as? StudentTableCell else { return UITableViewCell() }
        
        if isFiltering() {
            let student = viewModel.filteredStudents.value[indexPath.row]
            let contains = viewModel.selectedStudents.value.contains(where: { $0.id == student.id })
            cell.selectedBefore = contains
            cell.configure(student)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}

extension CourseAppendStudentViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}