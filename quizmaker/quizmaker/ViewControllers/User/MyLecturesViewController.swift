
import UIKit
import RxSwift
import RxCocoa

private let courseCell = "courseCell"

public class MyLecturesViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let viewModel = MyLecturesViewModel()
    
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "My Lectures"
        self.view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
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
                
                let viewController = CourseQuizListViewController(courseID: item.id, courseName: item.name)
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
                
            }).disposed(by: disposeBag)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
}
