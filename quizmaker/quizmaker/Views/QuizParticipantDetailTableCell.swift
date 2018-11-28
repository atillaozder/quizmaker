import UIKit

class QuizParticipantDetailTableCell: UITableViewCell {
    
    let usernameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let firstLastNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let gradesLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let completionLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let finishedInLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let emailLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let studentIdLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.accessoryType = .disclosureIndicator
        
        let arrangedSubviews = [
            usernameLabel,
            firstLastNameLabel,
            emailLabel,
            studentIdLabel,
            gradesLabel,
            completionLabel,
            finishedInLabel,
            ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 0
        
        contentView.addSubview(stackView)
        stackView.fillSuperView(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ element: QuizParticipant) {
        if let participant = element.participant {
            usernameLabel.text = "Username: \(participant.username)"
            firstLastNameLabel.text = "Name: \(participant.firstName) \(participant.lastName)"
            emailLabel.text = "Email: \(participant.email)"
            if let studentID = participant.studentID {
                studentIdLabel.text = "Student ID: \(studentID)"
            }
        }
        
        completionLabel.text = "Completed \(element.completion)%"
        gradesLabel.text = "Grade: \(element.grade)"
        
        if let finishedIn = element.finishedIn {
            finishedInLabel.text = "Finished in \(finishedIn)"
        }
    }
}