import UIKit
import RxSwift

private let studentTableCell = "studentTableCell"

class CourseRemoveStudentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let disposeBag = DisposeBag()
    let viewModel: CourseRemoveStudentsViewModel
    
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
    
    init(course: Course) {
        viewModel = CourseRemoveStudentsViewModel(course: course)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.navigationItem.title = "Remove Students"
        self.view.backgroundColor = .white
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
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
    
    private func removeTapped(_ indexPath: IndexPath) {
        var student = viewModel.students.value[indexPath.row]
        if isFiltering() {
            student = viewModel.filteredStudents.value[indexPath.row]
        }

        let alertController = UIAlertController(title: "Are you sure?", message: "You will remove \(student.username) from the course. The operation cannot be undone", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Remove", style: .default) { (_) in
            self.viewModel.removeStudent(id: student.id)
        }

        alertController.addAction(cancel)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
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
        
        return viewModel.students.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeStudent = UITableViewRowAction(style: .normal, title: "Remove") { (action, indexPath) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        return [removeStudent]
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeStudent = UIContextualAction(style: .normal, title: "Remove") { (_, _, _) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        let configuration = UISwipeActionsConfiguration(actions: [removeStudent])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

extension CourseRemoveStudentsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}