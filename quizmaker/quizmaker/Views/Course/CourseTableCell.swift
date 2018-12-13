
import UIKit

public class CourseTableCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .boldSystemFont(ofSize: 14), true, false)
    }()
    
    let studentsLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 12), true, false)
    }()
    
    let quizzesLabel: UILabel = {
        return UILabel.uiLabel(1, .byTruncatingTail, "", .left, .black, .systemFont(ofSize: 12), true, false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.accessoryType = .disclosureIndicator
        
        let arrangedSubviews = [
            nameLabel,
            studentsLabel,
            quizzesLabel,
        ]
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(stackView)
        stackView.fillSafeArea(spacing: .init(top: 10, left: 16, bottom: -10, right: -16), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ element: Course) {
        nameLabel.text = element.name
        studentsLabel.text = "# of Students: \(element.students.count)"
        quizzesLabel.text = "# of Quizzes: \(element.quizzes.count)"
    }
}
