
import UIKit
import RxSwift
import RxDataSources

private let courseQuizCell = "courseQuizCell"

public class CourseQuizListViewController: UIViewController {
    
    var viewModel: QuizListViewModel
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
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
    
    init(courseID: Int, courseName: String) {
        self.viewModel = QuizListViewModel(courseID: courseID)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "\(courseName)'s Quizzes"
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: courseQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
    
    public func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>.init(configureCell: { (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: courseQuizCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            
            var notParticipateYet = true
            quiz.participants.forEach({ (user) in
                if user.id == UserDefaults.standard.getUserIdentifier() {
                    notParticipateYet = false
                }
            })
            
            if notParticipateYet {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            } else {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .gray
            }
            
            return cell
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
            .subscribe(onNext: { [weak self] (indexPath, quiz) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                
                var notParticipateYet = true
                quiz.participants.forEach({ (user) in
                    if user.id == UserDefaults.standard.getUserIdentifier() {
                        notParticipateYet = false
                    }
                })
                
                if !notParticipateYet {
                    if quiz.end > Date() && quiz.ownerID != UserDefaults.standard.getUserIdentifier() {
                        
                        // Go to quiz Questions Page
                        
                    } else {
                        strongSelf.showErrorAlert(message: "Quiz Has Ended.")
                    }
                }
            }).disposed(by: disposeBag)
    }
}
