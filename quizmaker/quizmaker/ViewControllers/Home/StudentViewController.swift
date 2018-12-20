
import UIKit

/// :nodoc:
public class StudentViewController: UserViewController {
    
    let lectureQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lecture Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        lectureQuizzesButton.addTarget(self, action: #selector(lectureQuizzesTapped), for: .touchUpInside)
    }
    
    override public func setupViews() {
        super.setupViews()
        lastStackView.addArrangedSubview(lectureQuizzesButton)
        lectureQuizzesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    @objc
    private func lectureQuizzesTapped() {
        let viewController = MyLecturesViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
