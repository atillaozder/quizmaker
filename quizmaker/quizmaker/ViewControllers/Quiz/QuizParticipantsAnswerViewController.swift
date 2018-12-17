
import UIKit
import RxSwift

private let quizAnswerCell = "quizAnswerCell"

/// Provider to get specific participant answers in a specific quiz.
public class QuizParticipantAnswersViewController: UIViewController, KeyboardHandler {
    
    /// :nodoc:
    public var scrollView: UIScrollView = UIScrollView()
    /// :nodoc:
    public var contentView: UIView = UIView()

    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel: ParticipantAnswerViewModel
    
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
    
    /// :nodoc:
    private var gradePapers: UIBarButtonItem = UIBarButtonItem()
    
    /// :nodoc:
    weak var delegate: UpdateQuizFromParticipant?
    
    /**
     Constructor of the class.
     
     - Parameters:
        - quizID: the quiz identifier.
        - userID: the user identifier.
        - name: the user's name.
     
     - Precondition: `quizID` must be non-nil.
     - Precondition: `userID` must be non-nil.
     - Precondition: `name` must be non-nil.
     - Precondition: `quizID` must be greater than 0.
     - Precondition: `userID` must be greater than 0.

     - Postcondition:
     Controller will be initialized.
     */
    init(quizID: Int, userID: Int, name: String) {
        viewModel = ParticipantAnswerViewModel(quizID: quizID, userID: userID)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "\(name)'s Answers"
        
        if UserDefaults.standard.getUserType() == "I" {
            gradePapers = UIBarButtonItem(title: "Grade", style: .plain, target: self, action: #selector(gradeTapped))
            self.navigationItem.setRightBarButton(gradePapers, animated: false)
        }
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
        
        tableView.register(QuizParticipantAnswerTableCell.self, forCellReuseIdentifier: quizAnswerCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableFooterView = UIView(frame: frame)
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        bindUI()
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
        viewModel.success.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let title = "Participant answers validated successfully."
                self.delegate?.updateParticipant()
                self.showDismissAlert(title)
            }).disposed(by: disposeBag)
        
        viewModel.failure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                self.gradePapers.isEnabled = true
                self.view.isUserInteractionEnabled = true
                switch error {
                case .apiMessage(let response):
                    self.showErrorAlert(message: response.message)
                case .api(let response):
                    self.showErrorAlert(message: response.errorDesc)
                case .quiz(.validate(let response)):
                    let q = response.questionPoint
                    let p = response.point
                    let msg = response.message + " \(q), \(p)"
                    self.showErrorAlert(message: msg)
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        viewModel.answers
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: quizAnswerCell, cellType: QuizParticipantAnswerTableCell.self)) { (row, element, cell) in
                cell.configure(element)
                cell.delegate = self
            }.disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
        addObservers()
    }
    
    /// :nodoc:
    @objc
    private func viewTapped() {
        self.view.endEditing(true)
    }
    
    /// :nodoc:
    func setTableHeaderView(participant: QuizParticipant) {
        let container = UIView(frame: .init(x: 0, y: 0, width: self.view.frame.height, height: 100))
        container.backgroundColor = UIColor.groupTableViewBackground
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let gradeLabel = UILabel()
        gradeLabel.font = UIFont.systemFont(ofSize: 16)
        let finishedInLabel = UILabel()
        finishedInLabel.font = UIFont.systemFont(ofSize: 16)
        let completionLabel = UILabel()
        completionLabel.font = UIFont.systemFont(ofSize: 16)
        
        gradeLabel.text = "Grade: \(participant.grade)"
        finishedInLabel.text = "Finished in: \(participant.finishedIn ?? "-")"
        completionLabel.text = "Completion: \(participant.completion)%"
        
        let stackView = UIStackView(arrangedSubviews: [gradeLabel, completionLabel, finishedInLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        headerView.addSubview(stackView)
        stackView.fillSuperView(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        headerView.addSubview(separator)
        separator.setAnchors(top: nil, bottom: headerView.bottomAnchor, leading: headerView.leadingAnchor, trailing: headerView.trailingAnchor, spacing: .zero, size: .init(width: 0, height: 0.5))
        
        headerView.bringSubviewToFront(separator)
        
        let top = UIView()
        top.backgroundColor = .lightGray
        headerView.addSubview(top)
        top.setAnchors(top: headerView.topAnchor, bottom: nil, leading: headerView.leadingAnchor, trailing: headerView.trailingAnchor, spacing: .zero, size: .init(width: 0, height: 0.5))
        
        headerView.bringSubviewToFront(top)
        
        container.addSubview(headerView)
        headerView.fillSuperView(spacing: .init(top: 10, left: 0, bottom: -10, right: 0), size: .zero)
        
        tableView.tableHeaderView = container
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
    
    @objc
    private func gradeTapped() {
        guard !viewModel.answers.value.isEmpty else { return }
        self.view.endEditing(true)
        let alertController = UIAlertController(title: "Are you sure you want to finish validating?", message: "Your current points will be saved.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.view.isUserInteractionEnabled = false
            self.viewModel.validateAndGrade()
            self.gradePapers.isEnabled = false
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(yes)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

/// :nodoc:
extension QuizParticipantAnswersViewController: GradeQuestion {
    func gradeQuestion(answer: Answer) {
        viewModel.setPoints(point: answer)
    }
}

/// :nodoc:
protocol GradeQuestion: class {
    func gradeQuestion(answer: Answer)
}

/// :nodoc:
protocol UpdateQuizFromParticipant: class {
    func updateParticipant()
}
