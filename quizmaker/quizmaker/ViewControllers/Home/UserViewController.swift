
import UIKit

/// :nodoc:
public class UserViewController: HomeViewController {
    
    let showPublicQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Public Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    let showJoinedQuizzesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Joined Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        showJoinedQuizzesButton.addTarget(self, action: #selector(showJoinedQuizzes), for: .touchUpInside)
        showPublicQuizzesButton.addTarget(self, action: #selector(showPublicQuizzes), for: .touchUpInside)
    }
    
    override public func setupViews() {
        super.setupViews()
        
        let stackView = UIStackView(arrangedSubviews: [showJoinedQuizzesButton, showPublicQuizzesButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        
//        view.addSubview(stackView)
//        stackView.setAnchors(top: createQuizButton.bottomAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
//        view.addSubview(lastStackView)
//        lastStackView.setAnchors(top: stackView.bottomAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
        lastStackView.addArrangedSubview(editProfileButton)
        
        rootStackView.addArrangedSubview(stackView)
        rootStackView.addArrangedSubview(lastStackView)
        
        showJoinedQuizzesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        showPublicQuizzesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    @objc
    private func showJoinedQuizzes() {
        let viewController = JoinedQuizzesChoiceViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func showPublicQuizzes() {
        let viewController = PublicQuizListViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
