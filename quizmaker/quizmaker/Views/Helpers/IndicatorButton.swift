
import UIKit

public class IndicatorButton: UIButton {
    
    var isLoading: Bool = false
    private var originalText: String?
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.AppColors.main.rawValue
        setTitleColor(.white, for: .normal)
    }
    
    convenience init(title: String) {
        self.init(type: .system)
        backgroundColor = UIColor.AppColors.main.rawValue
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showLoading() {
        isLoading = true
        originalText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        backgroundColor = .clear
        
        addSubview(activityIndicator)
        activityIndicator.setCenter()
        activityIndicator.startAnimating()
        isEnabled = false
    }
    
    func hideLoading() {
        isLoading = false
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        setTitle(originalText, for: .normal)
        backgroundColor = UIColor.AppColors.main.rawValue
        isEnabled = true
    }
}
