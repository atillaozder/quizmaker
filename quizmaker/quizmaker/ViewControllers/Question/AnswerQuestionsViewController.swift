
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let multichoiceCellId = "multichoiceCellId"
private let textCellId = "textCellId"
private let truefalseCellId = "truefalseCellId"

/// Provider to answer a quiz questions.
public class AnswerQuestionsViewController: UIViewController, KeyboardHandler {
    
    /// :nodoc:
    public var scrollView: UIScrollView = UIScrollView()
    
    /// :nodoc:
    public var contentView: UIView = UIView()

    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: AnswerQuestionsViewModel
    
    /// :nodoc:
    private var seconds = 0

    /// :nodoc:
    private var remaining = 0 {
        didSet {
            let title = secondsToHoursMinutesSeconds(seconds: remaining)
            rightButtonItem.title = "\(title.0):\(title.1):\(title.2)"
        }
    }
    
    /// :nodoc:
    private var timer = Timer()
    
    /// :nodoc:
    private let rightButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    
    /**
     Constructor of the class.
     
     - Parameters:
        - quiz: the quiz instance.
     
     - Precondition: `quiz` must be non-nil.
     
     - Postcondition:
     Controller will be initialized.
     */
    public init(quiz: Quiz) {
        viewModel = AnswerQuestionsViewModel(quiz: quiz)

        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = quiz.name
        
        let interval = quiz.end.timeIntervalSince(Date())
        remaining = Int(interval)
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    /// :nodoc:
    @objc
    private func updateTimer() {
        seconds += 1
        remaining -= 1
        
        if remaining == 0 {
            let finishedIn = secondsToHoursMinutesSeconds(seconds: seconds)
            let time = "\(finishedIn.0) hours \(finishedIn.1) minutes \(finishedIn.2) seconds"
            self.view.isUserInteractionEnabled = false
            self.viewModel.timeIsUp(time: time)
            
            self.timer.invalidate()
            
            let alertController = UIAlertController(title: "Ooops", message: "Time is up! Dont worry we've saved your current answers. Goodbye!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                alertController.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 20
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.bounces = false
        return tv
    }()
    
    /// :nodoc:
    private let finishButton = UIButton(type: .system)
    
    /// :nodoc:
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let backButton = UIBarButtonItem(image: UIImage(named: "clear")?.withRenderingMode(.alwaysTemplate), landscapeImagePhone: nil, style: .done, target: self, action: #selector(finishTapped))
        navigationItem.leftBarButtonItem = backButton
        
        tableView.register(MultichoiceTableCell.self, forCellReuseIdentifier: multichoiceCellId)
        tableView.register(TextTableCell.self, forCellReuseIdentifier: textCellId)
        tableView.register(TruefalseTableCell.self, forCellReuseIdentifier: truefalseCellId)

        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem()
        self.navigationItem.setRightBarButton(rightButtonItem, animated: false)
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        finishButton.backgroundColor = UIColor.AppColors.main.rawValue
        
        footer.addSubview(finishButton)
        finishButton.fillSafeArea()
        finishButton.setTitle("End Quiz", for: .normal)
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        
        tableView.tableFooterView = footer
        bindUI()
    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    /// :nodoc:
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuestionDetailSectionModel>.init(configureCell: { [weak self] (dataSource, tableView, indexPath, section) -> UITableViewCell in
            
            switch section {
            case .multichoice(let q):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: multichoiceCellId, for: indexPath) as? MultichoiceTableCell else { return UITableViewCell() }
                
                let answer = self?.viewModel.answers.first(where: { $0.questionID == q.id })
                let index = self?.viewModel.questions.value.firstIndex(where: { $0.id == q.id })
                cell.configure(q, index ?? 0, answer: answer)
                cell.delegate = self
                
                return cell
            case .text(let q):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: textCellId, for: indexPath) as? TextTableCell else { return UITableViewCell() }
                
                let answer = self?.viewModel.answers.first(where: { $0.questionID == q.id })
                let index = self?.viewModel.questions.value.firstIndex(where: { $0.id == q.id })
                cell.configure(q, index ?? 0, answer: answer)
                cell.delegate = self
                
                return cell
            case .truefalse(let q):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: truefalseCellId, for: indexPath) as? TruefalseTableCell else { return UITableViewCell() }
                
                let answer = self?.viewModel.answers.first(where: { $0.questionID == q.id })
                let index = self?.viewModel.questions.value.firstIndex(where: { $0.id == q.id })
                cell.configure(q, index ?? 0, answer: answer)
                cell.delegate = self
                
                return cell
            }
        })
        
        viewModel.items
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.failure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                self.view.isUserInteractionEnabled = true
                switch error {
                case .apiMessage(let response):
                    self.showErrorAlert(message: response.message)
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        viewModel.success.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let title = "You have finished the quiz. Congratulations."
                self.showDismissAlert(title)
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    public func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            var frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        if #available(iOS 11.0, *) {
            frame.size.height -= view.safeAreaInsets.bottom
        } else {
            frame.size.height -= bottomLayoutGuide.length
        }
        
        var contentInset: UIEdgeInsets = .zero
        contentInset.bottom = frame.size.height
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    /// :nodoc:
    public func keyboardWillHide(notification: Notification) {
        var contentInset: UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = 50
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = .zero
    }
    
    /// :nodoc:
    @objc
    private func finishTapped() {
        let alertController = UIAlertController(title: "Are you sure you want to finish quiz?", message: "Your current answers will be saved. Remember, this operation can not be undone.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.view.isUserInteractionEnabled = false
            let finishedIn = self.secondsToHoursMinutesSeconds(seconds: self.seconds)
            let time = "\(finishedIn.0) hours \(finishedIn.1) minutes \(finishedIn.2) seconds"
            self.viewModel.sendAnswers(time: time)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(yes)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// :nodoc:
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

/// :nodoc:
extension AnswerQuestionsViewController: AnswerDelegate {
    func setAnswer(_ answer: Answer) {
        viewModel.setAnswer(answer)
    }
}
