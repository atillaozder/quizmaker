import UIKit
import RxCocoa
import RxSwift

private let courseCell = "courseCell"

class CourseViewController: UIViewController {
    
    private let viewModel = CourseViewModel()
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = 50
        tv.estimatedRowHeight = 50
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.bounces = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "My Courses"
        self.view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.register(CourseTableCell.self, forCellReuseIdentifier: courseCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: courseCell, cellType: CourseTableCell.self)) { (_, element, cell) in
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = "Number of students: \(element.students.count)"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
    
    private func appendTapped(_ indexPath: IndexPath) {
        let course = viewModel.items.value[indexPath.row]
        let viewController = CourseAppendStudentViewController(courseID: course.id)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func removeTapped(_ indexPath: IndexPath) {
        let course = viewModel.items.value[indexPath.row]
        let viewController = CourseRemoveStudentsViewController(course: course)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CourseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}