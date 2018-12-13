import UIKit
import RxCocoa
import RxSwift
import RxDataSources

private let quizDetailCell = "quizDetailCell"
private let quizQuestionCell = "quizQuestionCell"
private let quizParticipantCell = "quizParticipantCell"

class QuizDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: QuizDetailViewModel
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.sectionHeaderHeight = 50
        tv.sectionFooterHeight = 0
        tv.separatorStyle = .none
        tv.separatorInset = .zero
        return tv
    }()
    
    init(quiz: Quiz) {
        viewModel = QuizDetailViewModel(quiz: quiz)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "\(quiz.name)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let delete = UIImage(imageLiteralResourceName: "delete")
        let update = UIImage(imageLiteralResourceName: "update")
        
        let deleteBarButton = UIBarButtonItem(image: delete, style: .plain, target: self, action: #selector(deleteTapped))
        let updateBarButton = UIBarButtonItem(image: update, style: .plain, target: self, action: #selector(updateTapped))
        
        self.navigationItem.setRightBarButtonItems([deleteBarButton, updateBarButton], animated: false)
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: quizDetailCell)
        tableView.register(QuizQuestionTableCell.self, forCellReuseIdentifier: quizQuestionCell)
        tableView.register(QuizParticipantTableCell.self, forCellReuseIdentifier: quizParticipantCell)
        
        tableView.bounces = false
        
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        bindUI()
    }
    
    private func bindUI() {
        viewModel.loadPageTrigger.onNext(())

        let dataSource = RxTableViewSectionedReloadDataSource<DetailSectionModel>.init(configureCell: { (dataSource, tableView, indexPath, section) -> UITableViewCell in
            
            switch section {
            case .detail(let quiz):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: quizDetailCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
                
                cell.configure(quiz)
                return cell
            case .participants(let participants):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: quizParticipantCell, for: indexPath) as? QuizParticipantTableCell else { return UITableViewCell() }
                
                cell.delegate = self
                cell.configure(participants)
                
                return cell
            case .questions(let questions):
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: quizQuestionCell, for: indexPath) as? QuizQuestionTableCell else { return UITableViewCell() }
                
                cell.configure(questions)
                
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
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                
                let alertController = UIAlertController(title: "Success", message: "Quiz deleted successfully.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
        
        tableView.delegate = self
    }
    
    @objc
    private func deleteTapped() {
        let alertController = UIAlertController(title: "Are you sure?", message: "You sure that you want to delete quiz \(viewModel.quiz.name)?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I am sure", style: .default) { (_) in
            self.viewModel.deleteTrigger.onNext(())
        }
        
        alertController.addAction(cancel)
        alertController.addAction(yes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func updateTapped() {
        let now = Date()
        let quiz = viewModel.quiz
        
        if quiz.start < now && quiz.end > now {
            self.showErrorAlert(message: "The quiz has already started and not finished yet. You have to wait until its finishes.")
        } else if quiz.start < now && quiz.end < now {
            let viewController = QuizPercentageUpdateViewController(quiz: quiz)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if quiz.start > now && quiz.end > now {
            let viewController = QuizCreateViewController(quiz: quiz)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension QuizDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))

        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let title = UILabel()
            title.text = viewModel.items.value[section].title
            title.font = UIFont.preferredFont(forTextStyle: .headline)
            
            headerView.contentView.addSubview(title)
            title.fillSuperView(spacing: .init(top: 0, left: 16, bottom: 0, right: -16), size: .zero)
        }
    }
}

extension QuizDetailViewController: QuizParticipantTableCellDelegate {
    func didTapParticipant(_ participant: QuizParticipant) {
        guard let user = participant.participant else { return }
        let viewController = QuizParticipantAnswersViewController(quizID: participant.quiz, userID: user.id, name: user.username)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension QuizDetailViewController: PercentageUpdateDelegate {
    func updateQuiz(quiz: Quiz) {
        viewModel.updateQuiz(quiz: quiz)
    }
}

extension QuizDetailViewController: UpdateQuizDelegate {
    func updateQuiz(q: Quiz) {
        viewModel.updateQuiz(quiz: q, questions: q.questions)
    }
}