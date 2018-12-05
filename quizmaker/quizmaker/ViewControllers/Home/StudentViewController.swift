import UIKit

class StudentViewController: UserViewController {
    
    let lectureQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lecture Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lectureQuizzesButton.roundCorners(.allCorners, radius: 5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lectureQuizzesButton.addTarget(self, action: #selector(lectureQuizzesTapped), for: .touchUpInside)
    }
    
    override func setupViews() {
        super.setupViews()
        lastStackView.addArrangedSubview(lectureQuizzesButton)
    }
    
    @objc
    private func lectureQuizzesTapped() {
        let viewController = MyLecturesViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}