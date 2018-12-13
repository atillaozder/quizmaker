
import UIKit

public class QuizDetailTableCell: UITableViewCell {
    
    let customImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(imageLiteralResourceName: "quiz"))
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        iv.tintColor = .lightGray
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 14), true, false)
    }()
    
    let descriptionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let startDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()

    let endDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let courseNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let percentageLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let ownerNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 14), true, false)
    }()
    
    let numberOfParticipantsLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 12), true, false)
    }()
    
    let numberOfQuestionsLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .systemFont(ofSize: 12), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        
        let arrangedSubviews = [
            nameLabel,
            ownerNameLabel,
            courseNameLabel,
            startDateLabel,
            endDateLabel,
//            dateLabel,
            percentageLabel,
            descriptionLabel,
//            numberOfQuestionsLabel,
//            numberOfParticipantsLabel,
            ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 5
        
        let horizontalStack = UIStackView(arrangedSubviews: [customImageView, stackView])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        customImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        customImageView.setHeightConstraint(constant: 80, priority: 999)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: Quiz) {
        nameLabel.text = "\(element.name)"
        descriptionLabel.text = "\(element.description ?? "")"
        ownerNameLabel.text = "Created By: \(element.ownerName)"
        
        if let courseName = element.courseName {
            courseNameLabel.text = "Course: \(courseName)"
        } else {
            courseNameLabel.isHidden = true
        }
        
        if !element.beGraded || !element.isPrivate {
            percentageLabel.isHidden = true
        }
        
        percentageLabel.text = "\(element.percentage)%"
        
        let startDate = DateFormatter.localizedString(from: element.start, dateStyle: .medium, timeStyle: .short)
        let endDate = DateFormatter.localizedString(from: element.end, dateStyle: .medium, timeStyle: .short)
        
        startDateLabel.text = "Start: \(startDate)"
        endDateLabel.text = "Until: \(endDate)"
        
//        numberOfParticipantsLabel.text = "# Participants: \(element.participants.count)"
//        numberOfQuestionsLabel.text = "# Questions: \(element.questions.count)"
    }
}

