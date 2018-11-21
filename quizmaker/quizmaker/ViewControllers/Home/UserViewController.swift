import UIKit

class UserViewController: HomeViewController {
    
    let showPublicQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Public Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    let showJoinedQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Joined Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showPublicQuizzesButton.roundCorners(.allCorners, radius: 5)
        showJoinedQuizzesButton.roundCorners(.allCorners, radius: 5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViews() {
        super.setupViews()
        
        let stackView = UIStackView(arrangedSubviews: [showJoinedQuizzesButton, showPublicQuizzesButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.setAnchors(top: createQuizButton.bottomAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
        view.addSubview(lastStackView)
        lastStackView.addArrangedSubview(editProfileButton)
        lastStackView.setAnchors(top: stackView.bottomAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
    }
}