
import UIKit
import RxSwift
import RxCocoa

private let quizAnswerCell = "quizAnswerCell"

public class MyAnswersViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel: MyAnswerListViewModel
    
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
    
    init(quizID: Int) {
        viewModel = MyAnswerListViewModel(quizID: quizID)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Your Answers"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.register(QuizParticipantAnswerTableCell.self, forCellReuseIdentifier: quizAnswerCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
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
        
        viewModel.answers
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: quizAnswerCell, cellType: QuizParticipantAnswerTableCell.self)) { (row, element, cell) in
                cell.configure(element)
            }.disposed(by: disposeBag)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
}
