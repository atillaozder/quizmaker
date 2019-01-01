
import UIKit

/// :nodoc:
class TruefalseTableCell: UITableViewCell {
    
    var question: Question?
    
    weak var delegate: AnswerDelegate?
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), false, false)
    }()
    
    let tLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "T", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let fLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "F", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    lazy var trueFalseStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [tLabel, fLabel], .fillEqually, .fill, .horizontal, 5)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        contentView.addSubview(questionLabel)
        questionLabel.setAnchors(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: 0, right: -16))
        
        contentView.addSubview(trueFalseStackView)
        trueFalseStackView.setAnchors(top: questionLabel.bottomAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: -16, right: -16))
        
        trueFalseStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addGestures()
    }
    
    private func addGestures() {
        tLabel.isUserInteractionEnabled = true
        tLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tTapped)))
        
        fLabel.isUserInteractionEnabled = true
        fLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fTapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "T", questionID: question.id)
        delegate?.setAnswer(answer)
        
        fLabel.layer.sublayers?.removeAll()
        tLabel.roundCorners(.allCorners, radius: 5, withBorder: true, borderColor: .red)
    }
    
    @objc
    private func fTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "F", questionID: question.id)
        delegate?.setAnswer(answer)
        
        tLabel.layer.sublayers?.removeAll()
        fLabel.roundCorners(.allCorners, radius: 5, withBorder: true, borderColor: .red)
    }
    
    func configure(_ element: Question, _ row: Int, answer: Answer?) {
        self.question = element
        questionLabel.text = "\(element.questionNumber ?? (row + 1))- \(element.question)"
        
        if let a = answer {
            if a.answer == "T" {
                tTapped()
            } else if a.answer == "F" {
                fTapped()
            }
        } else {
            tLabel.layer.sublayers?.removeAll()
            fLabel.layer.sublayers?.removeAll()
        }
    }
}
