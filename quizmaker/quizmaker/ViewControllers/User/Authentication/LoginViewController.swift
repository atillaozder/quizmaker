
import UIKit
import RxSwift

/// Provider to login to the system.
public class LoginViewController: UIViewController, KeyboardHandler {
    
    /// View model that binding occurs when setup done. Provides a set of interfaces for the controller and view.
    let viewModel = LoginViewModel()
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    public let scrollView: UIScrollView = UIScrollView()
    
    /// :nodoc:
    public let contentView: UIView = UIView()
    
    /// :nodoc:
    private let usernameOrEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username or Email*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.tag = 0
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "profile").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        return tf
    }()
    
    /// :nodoc:
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.textContentType = UITextContentType(rawValue: "")
        tf.returnKeyType = .done
        tf.tag = 1
        tf.clearButtonMode = .never
        let button = UIButton(image: "show-password")
        button.addTarget(self, action: #selector(showPasswordButtonTapped(_:)), for: .touchUpInside)
        tf.rightView = button
        tf.rightViewMode = .always
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "password").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        return tf
    }()
    
    /// :nodoc:
    private let resetPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    /// :nodoc:
    private let loginButton: IndicatorButton = {
        let button = IndicatorButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        return button
    }()
    
    /// :nodoc:
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = .white
        return button
    }()
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindUI()
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    /// :nodoc:
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usernameOrEmailTextField.text = ""
        passwordTextField.text = ""
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        removeObservers()
    }
    
    /// :nodoc:
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        loginButton.layoutIfNeeded()
        loginButton.roundCorners(.allCorners, radius: 5)
        registerButton.layoutIfNeeded()
        registerButton.roundCorners(.allCorners, radius: 5)
    }
    
    /**
     Helps to initializes the UI with components. Adds them to the view as child and sets their position.
     
     - Postcondition:
     User Interface will be set and ready to use.
     */
    public func setup() {
        self.view.backgroundColor = UIColor(red: 59, green: 136, blue: 152)
        usernameOrEmailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupViews()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        
        if #available(iOS 12, *) {
            usernameOrEmailTextField.textContentType = .oneTimeCode
            passwordTextField.textContentType = .oneTimeCode
        } else {
            usernameOrEmailTextField.textContentType = .init(rawValue: "")
            passwordTextField.textContentType = .init(rawValue: "")
        }
        
        let subviews = [
            usernameOrEmailTextField,
            passwordTextField,
            loginButton
        ]
        
        let stackView = UIView.uiStackView(arrangedSubviews: subviews, .fillEqually, .center, .vertical, 20)
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: nil, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        stackView.setCenter()
        
        loginButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        NSLayoutConstraint.activate([
            usernameOrEmailTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            ])
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.text = "LOGIN"
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        
        contentView.addSubview(titleLabel)
        titleLabel.setAnchors(top: nil, bottom: stackView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 0, left: 30, bottom: -30, right: -30))
        
        let orLabel = UILabel()
        orLabel.textColor = UIColor.white
        orLabel.font = UIFont.boldSystemFont(ofSize: 18)
        orLabel.text = "OR"
        orLabel.numberOfLines = 1
        orLabel.lineBreakMode = .byWordWrapping
        orLabel.textAlignment = .center
        
        contentView.addSubview(orLabel)
        orLabel.setAnchors(top: stackView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 10, left: 20, bottom: 0, right: -20))
        
        contentView.addSubview(registerButton)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10).isActive = true
        registerButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        contentView.addSubview(resetPasswordLabel)
        resetPasswordLabel.setAnchors(top: registerButton.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 30, left: 20, bottom: 0, right: -20))
        
        resetPasswordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetPassword(_:))))
        registerButton.addTarget(self, action: #selector(registerTapped(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    /**
     Initializes the binding between controller and `viewModel`. After this method runs, UIComponents will bind to the some `viewModel` attributes and likewise `viewModel` attributes bind to some UIComponents. It is also called as two way binding
     
     - Postcondition:
     UIComponents will be binded to `viewModel` and some `viewModel` attributes will be binded to UIComponents.
     */
    public func bindUI() {
        usernameOrEmailTextField.rx.text
            .orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.username.asObservable(), viewModel.password.asObservable()).map { (username, password) -> Bool in
            return !username.isEmpty && !password.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.loginButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .do(onNext: { [unowned self] (_) in
                self.view.endEditing(true)
                self.loginButton.showLoading()
            }).bind(to: viewModel.loginTrigger)
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess = { [unowned self] (signUp) in
            self.loginButton.hideLoading()
            UserDefaults.standard.set(signUp)
            
            let viewController: UIViewController
            switch signUp.userType {
            case .admin:
                viewController = AdminViewController()
            case .instructor:
                viewController = InstructorViewController()
            case .normal:
                viewController = UserViewController()
            case .student:
                viewController = StudentViewController()
            }
            
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: false, completion: nil)
        }
        
        viewModel.forgotPassword = { [unowned self] (message) in
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
        
        viewModel.error = { [unowned self] (error) in
            print(error.localizedDescription)
            if self.loginButton.isLoading {
                self.loginButton.hideLoading()
            }
            
            switch error {
            case .auth(.login(let response)):
                self.showErrorAlert(message: response.fieldError?.first)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    /// :nodoc:
    private func getErrorLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
    /// :nodoc:
    @objc
    private func showPasswordButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        sender.tintColor = passwordTextField.isSecureTextEntry ? .lightGray : UIColor.AppColors.main.rawValue
    }
    
    /// :nodoc:
    @objc
    private func resetPassword(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: "Please enter your registered email address. We will send you an information mail.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.returnKeyType = .done
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        
        let sendEmail = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            if let email = alertController.textFields?.first?.text {
                self.viewModel.forgotPasswordTrigger.onNext(email)
            }
            alertController.dismiss(animated: true, completion:  nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(sendEmail)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// :nodoc:
    @objc
    private func registerTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        
        let viewController = RegisterViewController()
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
    
    /// :nodoc:
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

/// :nodoc:
extension LoginViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateContent()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " { return false }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            DispatchQueue.main.async {
                nextField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
            loginButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}
