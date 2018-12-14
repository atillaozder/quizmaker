
import UIKit

/// :nodoc:
public class StudentTableCell: UITableViewCell {
    
    var selectedBefore = false {
        willSet {
            self.contentView.backgroundColor = newValue ? .groupTableViewBackground : .clear
        }
    }
    
    let customImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(imageLiteralResourceName: "user_profile"))
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let usernameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let firstLastNameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    let emailLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 15), true, false)
    }()
    
    let studentIdLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 15), true, false)
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        customImageView.layoutIfNeeded()
        customImageView.roundCorners(.allCorners, radius: customImageView.frame.size.height / 2)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        
        let arrangedSubviews = [
            firstLastNameLabel,
            studentIdLabel,
            emailLabel,
//            usernameLabel
        ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let horizontalStack = UIStackView(arrangedSubviews: [customImageView, stackView])
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        
        contentView.addSubview(horizontalStack)
        horizontalStack.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
        
        customImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        customImageView.setHeightConstraint(constant: 40, priority: 999)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: User) {
//        usernameLabel.text = "Username: \(element.username)"
        firstLastNameLabel.text = "Name: \(element.firstName) \(element.lastName)"
        emailLabel.text = "Email: \(element.email)"
        
        if let studentId = element.studentID {
            studentIdLabel.text = "Student ID: \(studentId)"
        }
    }
}
