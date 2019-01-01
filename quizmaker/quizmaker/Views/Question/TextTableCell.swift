
import UIKit

/// :nodoc:
class TextTableCell: UITableViewCell, UITextViewDelegate {
    
    var question: Question?
    
    weak var delegate: AnswerDelegate?
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), false, false)
    }()
    
    let answerTextView: UITextView = {
        let tv = UITextView()
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.keyboardType = .default
        tv.returnKeyType = .done
        tv.layer.borderWidth = 0.5
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.tag = 0
        return tv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        contentView.addSubview(questionLabel)
        questionLabel.setAnchors(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: 0, right: -16))
        
        contentView.addSubview(answerTextView)
        answerTextView.setAnchors(top: questionLabel.bottomAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: -16, right: -16))
        
        answerTextView.setHeightConstraint(constant: 75, priority: 999)
        answerTextView.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let question = self.question else { return }
        let answer = Answer(answer: textView.text, questionID: question.id)
        delegate?.setAnswer(answer)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func configure(_ element: Question, _ row: Int, answer: Answer?) {
        self.question = element
        questionLabel.text = "\(element.questionNumber ?? (row + 1))- \(element.question)"
        
        if let a = answer {
            answerTextView.text = a.answer
            textViewDidChange(answerTextView)
        } else {
            answerTextView.text = ""
        }
    }
}
