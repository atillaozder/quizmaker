
import UIKit

/// :nodoc:
public class AdminViewController: HomeViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func setupViews() {
        self.navigationItem.title = "Home"
        let logoutBarButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(logoutTapped(_:)))
        self.navigationItem.setRightBarButton(logoutBarButton, animated: false)
        
        let label = UILabel()
        let username = UserDefaults.standard.getUsername()
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        label.text = "Welcome again, \(username ?? ""). You are an admin and this app was not designed to serve you. Please go to your dashboard and stick around there."
        
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(label)
        label.setCenter()
        label.fillSafeArea(spacing: .init(top: 0, left: 16, bottom: 0, right: -16))
    }
}
