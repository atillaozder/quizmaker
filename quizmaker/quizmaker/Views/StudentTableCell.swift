import UIKit

class StudentTableCell: UITableViewCell {
    
    var selectedBefore = false {
        willSet {
            self.contentView.backgroundColor = newValue ? .groupTableViewBackground : .clear
        }
    }
    
    let usernameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let firstLastNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let emailLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    let studentIdLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        
        let arrangedSubviews = [
            usernameLabel,
            firstLastNameLabel,
            emailLabel,
            studentIdLabel
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

    func configure(_ element: User) {
        usernameLabel.text = "Username: \(element.username)"
        firstLastNameLabel.text = "Name: \(element.firstName) \(element.lastName)"
        emailLabel.text = "Email: \(element.email)"
        
        if let studentId = element.studentID {
            studentIdLabel.text = "Student ID: \(studentId)"
        }
    }
}