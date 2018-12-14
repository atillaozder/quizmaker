
import UIKit

private let quizQuestionDetailCell = "quizQuestionDetailCell"

/// :nodoc:
public class QuizQuestionTableCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var heightConstraint: NSLayoutConstraint?
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.sectionHeaderHeight = 0
        tv.estimatedSectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.estimatedSectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.isScrollEnabled = false
        return tv
    }()
    
    var items: [Question] = [] {
        didSet {
            cellHeights = [:]
            tableView.reloadData()
        }
    }
    
    private var cellHeights: [IndexPath: CGFloat] = [:]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        tableView.register(QuizQuestionDetailTableCell.self, forCellReuseIdentifier: quizQuestionDetailCell)
        
        contentView.addSubview(tableView)
        tableView.fillSafeArea()
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        heightConstraint = tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tableView.layer.removeAllAnimations()
        
        var estimation: CGFloat = 0
        cellHeights.forEach { (k, v) in
            estimation += v
        }
        
        if estimation != 0 {
            heightConstraint?.constant = estimation * (CGFloat(items.count) + 0.3)
        } else {
            heightConstraint?.constant = tableView.contentSize.height
        }

        layoutIfNeeded()
    }
    
    func configure(_ element: [Question]) {
        items = element
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: quizQuestionDetailCell, for: indexPath) as? QuizQuestionDetailTableCell else {
            return UITableViewCell()
        }
        
        cell.configure(items[indexPath.row], idx: indexPath.row + 1)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
