
import UIKit

/// :nodoc:
public class QuizParticipantAnswerTableCell: UITableViewCell {
    
    weak var delegate: GradeQuestion?
    
    var participantAnswer: ParticipantAnswer?
    
    let answerLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let realAnswerLabel: UILabel = {
        return UILabel.uiLabel(0, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let participantPointLabel: UILabel = {
        return UILabel.uiLabel(2, .byWordWrapping, "", .center, .gray, .systemFont(ofSize: 18), true, false)
    }()
    
    let pointLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let gradeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Score"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .never
        tf.keyboardType = .numberPad
        tf.returnKeyType = .done
        tf.tag = 0
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [questionLabel, realAnswerLabel, answerLabel, pointLabel])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let horizontalStack = UIStackView(arrangedSubviews: [stackView, participantPointLabel, gradeTextField])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 10
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        participantPointLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        gradeTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        gradeTextField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
    }
    
    @objc
    private func didChangeTextField(_ textField: UITextField) {
        guard let p = self.participantAnswer else { return }
        guard let txt = textField.text else { return }
        if txt.isNumeric {
            if var point = Int(txt) {
                if let qPoint = p.question.point, point > qPoint {
                    textField.text = "\(qPoint)"
                    point = qPoint
                }
                
                let answer = Answer(point: point, questionID: p.question.id)
                delegate?.gradeQuestion(answer: answer)
            } else {
                textField.text = ""
            }
        } else {
            textField.text = ""
        }
    }
    
    func configure(_ element: ParticipantAnswer) {
        self.participantAnswer = element
        questionLabel.text = "Question: \(element.question.question)"
        realAnswerLabel.text = "Answer: \(element.question.answer)"
        answerLabel.text = "Participant Answer: \(element.answer)"
        
        if let qPoint = element.question.point {
            pointLabel.isHidden = false
            pointLabel.text = "Total: \(qPoint) point"
        } else {
            pointLabel.isHidden = true
        }
        
        if let type = QuestionType(rawValue: element.question.questionType) {
            
            switch type {
            case .multichoice, .truefalse:
                gradeTextField.isHidden = true
                participantPointLabel.isHidden = false
                
                if let pPoint = element.point {
                    participantPointLabel.text = "GETS \(pPoint)"
                }
            case .text:

                participantPointLabel.isHidden = true
                gradeTextField.isHidden = false
                
                if let validated = element.isValidated, validated {
                    if let pPoint = element.point {
                        gradeTextField.text = "\(pPoint)"
                        let answer = Answer(point: pPoint, questionID: element.question.id)
                        delegate?.gradeQuestion(answer: answer)
                    }
                }

            }
        }
    }
}
