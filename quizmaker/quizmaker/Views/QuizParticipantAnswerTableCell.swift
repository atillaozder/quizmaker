import UIKit

class QuizParticipantAnswerTableCell: UITableViewCell {
    
    let answerLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let realAnswerLabel: UILabel = {
        return UILabel.uiLabel(0, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let correctLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 13), true, false)
    }()
    
    let pointLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 13), true, false)
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
        let stackView = UIStackView(arrangedSubviews: [questionLabel, realAnswerLabel, answerLabel, pointLabel, correctLabel])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(stackView)
        stackView.fillSuperView(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
    }
    
    func configure(_ element: ParticipantAnswer) {
        questionLabel.text = "Question: \(element.question.question)"
        realAnswerLabel.text = "Answer: \(element.question.answer)"
        answerLabel.text = "Participant Answer: \(element.answer)"
        
        if let point = element.question.point {
            pointLabel.isHidden = false
            pointLabel.text = "Point: \(point)"
        } else {
            pointLabel.isHidden = true
        }
        
        if let correct = element.isCorrect {
            correctLabel.isHidden = false
            correctLabel.text = correct ? "Correct Answer" : "Wrong Answer"
            correctLabel.textColor = correct ? .green : .red
        } else {
            correctLabel.text = "Not validated yet"
            correctLabel.textColor = .brown
        }
    }
}