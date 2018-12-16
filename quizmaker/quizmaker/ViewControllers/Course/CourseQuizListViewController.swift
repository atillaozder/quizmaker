
import UIKit
import RxSwift
import RxDataSources

private let courseQuizCell = "courseQuizCell"

/// Provider to list quizzes of specific course.
public class CourseQuizListViewController: UIViewController {
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    var viewModel: QuizListViewModel
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    private var lastSelectedQuiz: Quiz?
    
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
    
    /**
     Constructor of the class.
     
     - Parameters:
        - courseID: the course identifier.
        - courseName: the course name.
     
     - Precondition: `courseID` must be non-nil.
     - Precondition: `courseID` must be greater than 0.
     - Precondition: `courseName` must be non-nil.
     
     - Postcondition:
     Controller will be initialized.
     */
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
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
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
            .asObservable()
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
        
        viewModel.success
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                guard let lastQuiz = self.lastSelectedQuiz else { return }
                let viewController = AnswerQuestionsViewController(quiz: lastQuiz)
                self.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Quiz.self))
            .subscribe(onNext: { [weak self] (indexPath, quiz) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                strongSelf.lastSelectedQuiz = quiz
                
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
}
