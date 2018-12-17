
import UIKit

/// :nodoc:
public class QuizParticipantDetailTableCell: UITableViewCell {
    
    let customImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(imageLiteralResourceName: "user_profile"))
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let usernameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let firstLastNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let gradesLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 14), true, false)
    }()
    
    let completionLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 14), true, false)
    }()
    
    let finishedInLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 14), true, false)
    }()
    
    let emailLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let studentIdLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layoutIfNeeded()
        customImageView.roundCorners(.allCorners, radius: customImageView.frame.size.height / 2)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.accessoryType = .disclosureIndicator
        
        let arrangedSubviews = [
//            usernameLabel,
            firstLastNameLabel,
            studentIdLabel,
            emailLabel,
//            gradesLabel,
//            completionLabel,
//            finishedInLabel,
            ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        
        let horizontalStack = UIStackView(arrangedSubviews: [customImageView, stackView])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSuperView(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)

        customImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        customImageView.setHeightConstraint(constant: 40, priority: 999)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ element: QuizParticipant) {
        if let participant = element.participant {
            firstLastNameLabel.text = "Name: \(participant.firstName) \(participant.lastName)"
            if participant.firstName.isEmpty && participant.lastName.isEmpty {
                firstLastNameLabel.text = "Name: \(participant.username)"
            }
            
            emailLabel.text = "Email: \(participant.email)"
            if let studentID = participant.studentID {
                studentIdLabel.text = "Student ID: \(studentID)"
            }
        }
    }
}
