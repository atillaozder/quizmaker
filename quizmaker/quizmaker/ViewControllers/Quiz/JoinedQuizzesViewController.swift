import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let joinedQuizCell = "joinedQuizCell"

class JoinedQuizzesViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel: JoinedQuizzesViewModel
    
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
    
    init(waiting: Bool) {
        viewModel = JoinedQuizzesViewModel(waiting: waiting)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal Error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = viewModel.waiting ? "Waiting Quizzes" : "End Quizzes"
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: joinedQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>.init(configureCell: { [weak self] (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: joinedQuizCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            
            guard let strongSelf = self else { return cell }
            if !strongSelf.viewModel.waiting {
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
            return true
        })
        
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
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
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Quiz.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                
                if !strongSelf.viewModel.waiting {
                    // Show Answers and Grade
                }
                
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
}