import UIKit

class QuizCreateQuestionTableCell: UITableViewCell {
    
    private let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    private let answerLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    private let pointLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.accessoryType = .disclosureIndicator
        
        contentView.addSubview(questionLabel)
        questionLabel.setAnchors(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10))
        
        contentView.addSubview(answerLabel)
        answerLabel.setAnchors(top: questionLabel.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10))
        
        contentView.addSubview(pointLabel)
        pointLabel.setAnchors(top: answerLabel.bottomAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: -10, right: -10))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ question: Question) {
        questionLabel.text = "Q: \(question.question)"
        answerLabel.text = "A: \(question.answer)"
        if let point = question.point {
            pointLabel.text = "Total Point: \(point)"
        } else {
            pointLabel.text = ""
        }
    }
}