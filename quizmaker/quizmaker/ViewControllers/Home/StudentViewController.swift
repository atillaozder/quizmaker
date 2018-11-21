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
    }
    
    override func setupViews() {
        super.setupViews()
        lastStackView.addArrangedSubview(lectureQuizzesButton)
    }
}