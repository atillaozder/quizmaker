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
}