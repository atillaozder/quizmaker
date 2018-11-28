import UIKit

class QuizListTableCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .body), true, false)
    }()
    
    let startDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .footnote), true, false)
    }()
    
    let endDateLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .footnote), true, false)
    }()
    
    let differenceLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .gray, .preferredFont(forTextStyle: .footnote), true, false)
    }()
//
//    let numberOfParticipantsLabel: UILabel = {
//        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .footnote), true, false)
//    }()
//
//    let numberOfQuestionsLabel: UILabel = {
//        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .footnote), true, false)
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.accessoryType = .disclosureIndicator
        
        let arrangedSubviews = [
            nameLabel,
            startDateLabel,
            endDateLabel,
            differenceLabel,
//            numberOfParticipantsLabel,
//            numberOfQuestionsLabel
        ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 5
        
        contentView.addSubview(stackView)
        stackView.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: Quiz) {
        nameLabel.text = "Name: \(element.name)"
        let startDate = DateFormatter.localizedString(from: element.start, dateStyle: .medium, timeStyle: .medium)
        startDateLabel.text = "Starts: \(startDate)"
        
        let endDate = DateFormatter.localizedString(from: element.end, dateStyle: .medium, timeStyle: .medium)
        endDateLabel.text = "Ends: \(endDate)"
        
        let interval = element.end.timeIntervalSince(element.start)
        differenceLabel.text = "\(interval.stringTime)"
        
//        numberOfParticipantsLabel.text = "Number of Participants: \(element.participants.count)"
//        numberOfQuestionsLabel.text = "Number of Questions: \(element.questions.count)"
    }
}

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}