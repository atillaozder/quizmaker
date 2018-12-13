import UIKit

public class QuizQuestionDetailTableCell: UITableViewCell {
    
    let qNumberLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(2, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let questionTypeLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 12), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        let arrangedSubviews = [
            questionLabel,
            questionTypeLabel
        ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let horizontalStack = UIStackView(arrangedSubviews: [qNumberLabel, stackView])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.spacing = 0
        horizontalStack.axis = .horizontal
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSuperView(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        qNumberLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: Question, idx: Int) {
        questionLabel.text = "\(element.question)"
        questionTypeLabel.text = "Type of question: \(element.questionType)"
        qNumberLabel.text = "\(idx)-"
    }
}
