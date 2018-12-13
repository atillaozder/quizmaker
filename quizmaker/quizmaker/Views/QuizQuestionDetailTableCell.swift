import UIKit

class QuizQuestionDetailTableCell: UITableViewCell {
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(2, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 14), true, false)
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
        
        contentView.addSubview(stackView)
        stackView.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: Question) {
        questionLabel.text = element.question
        questionTypeLabel.text = element.questionType
    }
}