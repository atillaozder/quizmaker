
import UIKit

public class InstructorViewController: HomeViewController {
    
    let myCoursesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("My Courses", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        return button
    }()
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myCoursesButton.roundCorners(.allCorners, radius: 5)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func setupViews() {
        super.setupViews()
        
        view.addSubview(lastStackView)
        lastStackView.addArrangedSubview(editProfileButton)
        lastStackView.addArrangedSubview(myCoursesButton)
        lastStackView.setAnchors(top: createQuizButton.bottomAnchor, bottom: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, spacing: .init(top: 10, left: 10, bottom: 0, right: -10), size: .init(width: 0, height: 50))
        
        myCoursesButton.addTarget(self, action: #selector(coursesTapped), for: .touchUpInside)
    }
    
    @objc
    private func coursesTapped() {
        let viewController = CourseViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
