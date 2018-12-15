
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

private let courseQuizCell = "courseQuizCell"

/// Provider to list created quizzes.
public class MyQuizListViewController: UIViewController {
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    var viewModel: QuizListViewModel
    
    private let disposeBag = DisposeBag()
    
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
    init() {
        self.viewModel = QuizListViewModel()
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "My Quizzes"
    }
    
    /**
     Convenience Constructor of the class.
     
     - Parameters:
        - courseID: the course identifier.
        - courseName: the course name.
     
     - Precondition: `courseID` must be non-nil.
     - Precondition: `courseID` must be greater than 0.
     - Precondition: `courseName` must be non-nil.
     
     - Postcondition:
     Controller will be initialized.
     */
    convenience init(courseID: Int, courseName: String) {
        self.init()
        self.viewModel = QuizListViewModel(courseID: courseID)
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
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.register(QuizListTableCell.self, forCellReuseIdentifier: courseQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        bindUI()
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>.init(configureCell: { (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: courseQuizCell, for: indexPath) as? QuizListTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            
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
        
        viewModel.success
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                
                let alertController = UIAlertController(title: "Success", message: "Quiz deleted successfully.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
                    self.viewModel.loadPageTrigger.onNext(())
                })
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Quiz.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                let quizDetailViewController = QuizDetailViewController(quiz: item)
                strongSelf.navigationController?.pushViewController(quizDetailViewController, animated: true)
            }).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPageTrigger.onNext(())
    }
    
    private func deleteTapped(_ indexPath: IndexPath) {
        guard indexPath.section < viewModel.items.value.count else { return }
        let section = viewModel.items.value[indexPath.section]
        guard indexPath.row < section.items.count else { return }
        let quiz = section.items[indexPath.row]
        
        let alertController = UIAlertController(title: "Are you sure?", message: "You sure that you want to delete selected quiz \(quiz.name)?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I am sure", style: .default) { (_) in
            self.viewModel.delete(quiz)
        }
        
        alertController.addAction(cancel)
        alertController.addAction(yes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateTapped(_ indexPath: IndexPath) {
        guard indexPath.section < viewModel.items.value.count else { return }
        let section = viewModel.items.value[indexPath.section]
        guard indexPath.row < section.items.count else { return }
        let quiz = section.items[indexPath.row]
        let now = Date()
        if quiz.start < now && quiz.end > now {
            self.showErrorAlert(message: "The quiz has already started and not finished yet. You have to wait until its finishes.")
        } else if quiz.start < now && quiz.end < now {
            if UserDefaults.standard.getUserType() == "I" && quiz.beGraded {
                let viewController = QuizUpdateViewController(quiz: quiz)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                self.showErrorAlert(message: "The quiz has ended. You cannot update it but you can delete and create a new quiz if you want.")
            }
        } else if quiz.start > now && quiz.end > now {
            let viewController = QuizCreateViewController(quiz: quiz)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

/// :nodoc:
extension MyQuizListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            self.deleteTapped(indexPath)
        }
        
        delete.backgroundColor = .red
        
        let update = UITableViewRowAction(style: .normal, title: "Update") { (action, indexPath) in
            self.updateTapped(indexPath)
        }
        
        update.backgroundColor = UIColor.AppColors.complementary.rawValue
        
        return [delete, update]
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (_, _, _) in
            self.deleteTapped(indexPath)
        }
        
        delete.backgroundColor = .red
        
        let update = UIContextualAction(style: .normal, title: "Update") { (_, _, _) in
            self.updateTapped(indexPath)
        }
        
        update.backgroundColor = UIColor.AppColors.complementary.rawValue
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, update])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
