
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let publicQuizCell = "publicQuizCell"

class PublicQuizListViewController: UIViewController, KeyboardHandler {
    
    var scrollView: UIScrollView = UIScrollView()
    var contentView: UIView = UIView()
    
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
    
    lazy var searchController: UISearchController = {
        let sv = UISearchController(searchResultsController: nil)
        sv.dimsBackgroundDuringPresentation = false
        sv.hidesNavigationBarDuringPresentation = false
        sv.searchBar.autocorrectionType = .no
        sv.searchBar.autocapitalizationType = .none
        sv.searchResultsUpdater = self
        sv.obscuresBackgroundDuringPresentation = false
        sv.searchBar.placeholder = "Search Quizzes"
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Public Quizzes"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.register(QuizDetailTableCell.self, forCellReuseIdentifier: publicQuizCell)
        self.view.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSectionModel>(configureCell: { (dataSource, tableView, indexPath, quiz) -> UITableViewCell in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: publicQuizCell, for: indexPath) as? QuizDetailTableCell else { return UITableViewCell() }
            
            cell.configure(quiz)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
            return cell
        })
        
        viewModel.filtered
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.success
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] () in
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
        addObservers()
        viewModel.loadPageTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let currentContent = viewModel.items.value
        if isFiltering() {
            var filteredContent: [QuizSectionModel] = []
            let query = searchText.lowercased()
            
            currentContent.forEach { (model) in
                model.items.forEach({ (q) in
                    if q.name.lowercased().contains(query) ||
                        q.ownerName.lowercased().contains(query) {
                        filteredContent.append(.quiz(item: q))
                    }
                })
            }
            
            viewModel.filtered.accept(filteredContent)
        } else {
            viewModel.filtered.accept(currentContent)
        }
    }
    
    func keyboardWillShow(notification: Notification) {
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
    
    func keyboardWillHide(notification: Notification) {
        var contentInset: UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = 50
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = .zero
    }
}
extension PublicQuizListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

