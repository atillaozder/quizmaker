import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let publicQuizCell = "publicQuizCell"

class PublicQuizListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = PublicQuizViewModel()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Public Quizzes"
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: publicQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>.init(configureCell: { (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: publicQuizCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
            return cell
        })
        
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.success
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { () in
                // Go to Question Page
            }).disposed(by: disposeBag)
        
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
            .subscribe(onNext: { [weak self] (indexPath, quiz) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                
                let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to append \(quiz.name), this operation cannot be undone.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                let appendAction = UIAlertAction(title: "Append", style: .default, handler: { (_) in
                    strongSelf.viewModel.append(quiz.id)
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(appendAction)
                strongSelf.present(alertController, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
}
