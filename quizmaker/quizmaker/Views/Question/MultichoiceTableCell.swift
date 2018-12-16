
import UIKit

/// :nodoc:
class MultichoiceTableCell: UITableViewCell {
    
    var question: Question?
    
    weak var delegate: AnswerDelegate?
    
    let questionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .boldSystemFont(ofSize: 15), false, false)
    }()
    
    let aLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "A-", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let aQuestionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    lazy var aStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [aLabel, aQuestionLabel], .fill, .top, .horizontal, 5)
    }()
    
    let aWrapper = UIView()
    
    let bLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "B-", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let bQuestionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    lazy var bStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [bLabel, bQuestionLabel], .fill, .top, .horizontal, 5)
    }()
    
    let bWrapper = UIView()
    
    let cLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "C-", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let cQuestionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let cWrapper = UIView()
    
    lazy var cStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [cLabel, cQuestionLabel], .fill, .top, .horizontal, 5)
    }()
    
    let dLabel: UILabel = {
        return UILabel.uiLabel(1, .byWordWrapping, "D-", .center, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let dQuestionLabel: UILabel = {
        return UILabel.uiLabel(0, .byWordWrapping, "", .left, .black, .systemFont(ofSize: 15), false, false)
    }()
    
    let dWrapper = UIView()
    
    lazy var dStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [dLabel, dQuestionLabel], .fill, .top, .horizontal, 5)
    }()
    
    let multichoiceWrapper: UIView = UIView()
    
    lazy var multichoiceStackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [aWrapper, bWrapper, cWrapper, dWrapper], .fill, .fill, .vertical, 10)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        contentView.addSubview(questionLabel)
        questionLabel.setAnchors(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: 0, right: -16))
        
        aWrapper.addSubview(aStackView)
        aStackView.fillSuperView()
        
        bWrapper.addSubview(bStackView)
        bStackView.fillSuperView()
        
        cWrapper.addSubview(cStackView)
        cStackView.fillSuperView()
        
        dWrapper.addSubview(dStackView)
        dStackView.fillSuperView()
        
        multichoiceWrapper.addSubview(multichoiceStackView)
        multichoiceStackView.fillSuperView()
        
        contentView.addSubview(multichoiceWrapper)
        multichoiceWrapper.setAnchors(top: questionLabel.bottomAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 16, left: 16, bottom: -16, right: -16))
        
        multichoiceWrapper.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        aLabel.setHeightConstraint(constant: 30, priority: 999)
        bLabel.setHeightConstraint(constant: 30, priority: 999)
        cLabel.setHeightConstraint(constant: 30, priority: 999)
        dLabel.setHeightConstraint(constant: 30, priority: 999)
        
        aQuestionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        bQuestionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        cQuestionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        dQuestionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        aLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        bLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        dLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        addGestures()
    }
    
    private func addGestures() {
        aStackView.isUserInteractionEnabled = true
        aStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aTapped)))
        
        bStackView.isUserInteractionEnabled = true
        bStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bTapped)))
        
        cStackView.isUserInteractionEnabled = true
        cStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cTapped)))
        
        dStackView.isUserInteractionEnabled = true
        dStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dTapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func aTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "A", questionID: question.id)
        delegate?.setAnswer(answer)
        
        bLabel.layer.sublayers?.removeAll()
        cLabel.layer.sublayers?.removeAll()
        dLabel.layer.sublayers?.removeAll()
        aLabel.roundCorners(.allCorners, radius: 15, withBorder: true, borderColor: .red)
    }
    
    @objc
    private func bTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "B", questionID: question.id)
        delegate?.setAnswer(answer)
        
        aLabel.layer.sublayers?.removeAll()
        cLabel.layer.sublayers?.removeAll()
        dLabel.layer.sublayers?.removeAll()
        bLabel.roundCorners(.allCorners, radius: 15, withBorder: true, borderColor: .red)
    }
    
    @objc
    private func cTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "C", questionID: question.id)
        delegate?.setAnswer(answer)
        
        bLabel.layer.sublayers?.removeAll()
        aLabel.layer.sublayers?.removeAll()
        dLabel.layer.sublayers?.removeAll()
        cLabel.roundCorners(.allCorners, radius: 15, withBorder: true, borderColor: .red)
    }
    
    @objc
    private func dTapped() {
        guard let question = self.question else { return }
        let answer = Answer(answer: "D", questionID: question.id)
        delegate?.setAnswer(answer)
        
        bLabel.layer.sublayers?.removeAll()
        cLabel.layer.sublayers?.removeAll()
        aLabel.layer.sublayers?.removeAll()
        dLabel.roundCorners(.allCorners, radius: 15, withBorder: true, borderColor: .red)
    }
    
    func configure(_ element: Question, _ row: Int, answer: Answer?) {
        self.question = element
        questionLabel.text = "\(row + 1)- \(element.question)"
        
        aQuestionLabel.text = element.A
        bQuestionLabel.text = element.B
        cQuestionLabel.text = element.C
        dQuestionLabel.text = element.D
        
        if let a = answer {
            if a.answer == "A" {
                aTapped()
            } else if a.answer == "B" {
                bTapped()
            } else if a.answer == "C" {
                cTapped()
            } else if a.answer == "D" {
                dTapped()
            }
        } else {
            aLabel.layer.sublayers?.removeAll()
            bLabel.layer.sublayers?.removeAll()
            cLabel.layer.sublayers?.removeAll()
            dLabel.layer.sublayers?.removeAll()
        }
    }
}

