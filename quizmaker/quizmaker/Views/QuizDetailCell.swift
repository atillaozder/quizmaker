import UIKit

class QuizDetailTableCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 14), true, false)
    }()
    
    let descriptionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 12), true, false)
    }()
    
    let startDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 13), true, false)
    }()
    
    let endDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 13), true, false)
    }()
    
    let courseNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 13), true, false)
    }()
    
    let percentageLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 13), true, false)
    }()
    
    let ownerNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 13), true, false)
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
            descriptionLabel,
            ownerNameLabel,
            courseNameLabel,
            startDateLabel,
            endDateLabel,
            percentageLabel,
            numberOfQuestionsLabel,
            numberOfParticipantsLabel,
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
    
    func configure(_ element: Quiz) {
        nameLabel.text = "Name: \(element.name)"
        descriptionLabel.text = "Description: \(element.description ?? "")"
        ownerNameLabel.text = "Quiz Created By: \(element.ownerName)"
        
        if let courseName = element.courseName {
            courseNameLabel.text = "Course Name: \(courseName)"
        }
        
        if !element.beGraded || !element.isPrivate {
            percentageLabel.isHidden = true
        }
        
        percentageLabel.text = "Percentage: \(element.percentage)"
        
        let startDate = DateFormatter.localizedString(from: element.start, dateStyle: .medium, timeStyle: .medium)
        startDateLabel.text = "Starts: \(startDate)"
        
        let endDate = DateFormatter.localizedString(from: element.end, dateStyle: .medium, timeStyle: .medium)
        endDateLabel.text = "Ends: \(endDate)"
        
        numberOfParticipantsLabel.text = "Number of Participants: \(element.participants.count)"
        numberOfQuestionsLabel.text = "Number of Questions: \(element.questions.count)"
    }
}