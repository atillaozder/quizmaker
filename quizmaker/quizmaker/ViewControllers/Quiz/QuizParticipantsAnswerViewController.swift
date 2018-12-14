
import UIKit
import RxSwift

private let quizAnswerCell = "quizAnswerCell"

public class QuizParticipantAnswersViewController: UIViewController {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
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
    
    init(quizID: Int, userID: Int, name: String) {
        viewModel = ParticipantAnswerViewModel(quizID: quizID, userID: userID)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "\(name)'s Answers"
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
        
        if UserDefaults.standard.getUserType() == "I" {
            let gradePapers = UIBarButtonItem(title: "Grade", style: .plain, target: self, action: #selector(gradeTapped))
            self.navigationItem.setRightBarButton(gradePapers, animated: false)
        }
        
        tableView.register(QuizParticipantAnswerTableCell.self, forCellReuseIdentifier: quizAnswerCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableFooterView = UIView(frame: frame)
        bindUI()
    }
    
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
            .drive(tableView.rx.items(cellIdentifier: quizAnswerCell, cellType: QuizParticipantAnswerTableCell.self)) { (row, element, cell) in
                cell.configure(element)
            }.disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
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
        finishedInLabel.text = "Finished in: \(participant.finishedIn ?? "-") min"
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
    
    @objc
    private func gradeTapped() {
        guard !viewModel.answers.value.isEmpty else { return }
//        let viewController = GradeAnswersViewController()
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
