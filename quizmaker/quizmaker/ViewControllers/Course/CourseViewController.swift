
import UIKit
import RxCocoa
import RxSwift

private let courseCell = "courseCell"

/// Provider to list courses.
public class CourseViewController: UIViewController {
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel = CourseListViewModel()
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 50
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.bounces = false
        return tv
    }()
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "My Courses"
        self.view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.delegate = self
        tableView.register(CourseTableCell.self, forCellReuseIdentifier: courseCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem()
        
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
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: courseCell, cellType: CourseTableCell.self)) { (_, element, cell) in
                cell.configure(element)
            }.disposed(by: disposeBag)
        
        viewModel.failure
            .observeOn(MainScheduler.instance)
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
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Course.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                
                let viewController = MyQuizListViewController(courseID: item.id, courseName: item.name)
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
                
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
    
    /// :nodoc:
    private func appendTapped(_ indexPath: IndexPath) {
        let course = viewModel.items.value[indexPath.row]
        let viewController = CourseAddStudentViewController(course: course)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// :nodoc:
    private func removeTapped(_ indexPath: IndexPath) {
        let course = viewModel.items.value[indexPath.row]
        let viewController = CourseRemoveStudentViewController(course: course)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

/// :nodoc:
extension CourseViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let appendStudent = UITableViewRowAction(style: .normal, title: "Append Students") { (action, indexPath) in
            self.appendTapped(indexPath)
        }
        
        appendStudent.backgroundColor = UIColor.AppColors.complementary.rawValue
        
        let removeStudent = UITableViewRowAction(style: .normal, title: "Remove Students") { (action, indexPath) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        return [appendStudent, removeStudent]
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let appendStudent = UIContextualAction(style: .normal, title: "Append Student") { (_, _, _) in
            self.appendTapped(indexPath)
        }
        
        appendStudent.backgroundColor = UIColor.AppColors.complementary.rawValue
        
        let removeStudent = UIContextualAction(style: .normal, title: "Remove Student") { (_, _, _) in
            self.removeTapped(indexPath)
        }
        
        removeStudent.backgroundColor = UIColor.AppColors.main.rawValue
        
        let configuration = UISwipeActionsConfiguration(actions: [appendStudent, removeStudent])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
