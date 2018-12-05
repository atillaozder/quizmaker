import UIKit

class JoinedQuizzesChoiceViewController: UIViewController {
    
    let finishedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ended Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    let waitingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Waiting Quizzes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        finishedButton.roundCorners(.allCorners, radius: 5)
        waitingButton.roundCorners(.allCorners, radius: 5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "Joined Quizzes"

        let stackView = UIStackView(arrangedSubviews: [finishedButton, waitingButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.setAnchors(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
        waitingButton.addTarget(self, action: #selector(waitingTapped), for: .touchUpInside)
        finishedButton.addTarget(self, action: #selector(finishedTapped), for: .touchUpInside)
    }
    
    @objc
    func finishedTapped() {
        let viewController = JoinedQuizzesViewController(waiting: false)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func waitingTapped() {
        let viewController = JoinedQuizzesViewController(waiting: true)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}