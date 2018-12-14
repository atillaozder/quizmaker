
import UIKit

/// :nodoc:
public class StudentViewController: UserViewController {
    
    let lectureQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lecture Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lectureQuizzesButton.roundCorners(.allCorners, radius: 5)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        lectureQuizzesButton.addTarget(self, action: #selector(lectureQuizzesTapped), for: .touchUpInside)
    }
    
    override public func setupViews() {
        super.setupViews()
        lastStackView.addArrangedSubview(lectureQuizzesButton)
    }
    
    @objc
    private func lectureQuizzesTapped() {
        let viewController = MyLecturesViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
