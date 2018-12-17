
import UIKit
import RxSwift
import RxCocoa

private let quizAnswerCell = "quizAnswerCell"

/// Provider to list own answers for specific quiz.
public class MyAnswersViewController: UIViewController {
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
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
    
    /**
     Constructor of the class.
     
     - Parameters:
        - quizID: the quiz identifier.
     
     - Precondition: `quizID` must be non-nil.
     - Precondition: `quizID` must be greater than 0.
     
     - Postcondition:
     Controller will be initialized.
     */
    init(quizID: Int) {
        viewModel = MyAnswerListViewModel(quizID: quizID)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Your Answers"
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.register(MyAnswersTableCell.self, forCellReuseIdentifier: quizAnswerCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        bindUI()
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
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
            .drive(tableView.rx.items(cellIdentifier: quizAnswerCell, cellType: MyAnswersTableCell.self)) { (row, element, cell) in
                cell.configure(element)
            }.disposed(by: disposeBag)
    }
}
