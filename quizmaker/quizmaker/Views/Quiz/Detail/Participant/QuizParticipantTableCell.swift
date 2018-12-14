
import UIKit

/// :nodoc:
protocol QuizParticipantTableCellDelegate: class {
    func didTapParticipant(_ participant: QuizParticipant)
}

private let quizParticipantDetailCell = "quizParticipantDetailCell"

/// :nodoc:
public class QuizParticipantTableCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var heightConstraint: NSLayoutConstraint?
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 150
        tv.sectionHeaderHeight = 0
        tv.estimatedSectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        tv.estimatedSectionFooterHeight = 0
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.isScrollEnabled = false
        return tv
    }()
    
    var items: [QuizParticipant] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var cellHeight: CGFloat?
    weak var delegate: QuizParticipantTableCellDelegate?
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let height = cellHeight {
            heightConstraint?.constant = height * (CGFloat(items.count) + 0.3)
        } else {
            heightConstraint?.constant = tableView.contentSize.height
        }
        
        layoutIfNeeded()
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        tableView.register(QuizParticipantDetailTableCell.self, forCellReuseIdentifier: quizParticipantDetailCell)
        
        contentView.addSubview(tableView)
        tableView.fillSafeArea()
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        heightConstraint = tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ element: [QuizParticipant]) {
        items = element
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: quizParticipantDetailCell, for: indexPath) as? QuizParticipantDetailTableCell else {
            return UITableViewCell()
        }
        
        cell.configure(items[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else { return }
        self.delegate?.didTapParticipant(items[indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeight = cell.frame.size.height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
