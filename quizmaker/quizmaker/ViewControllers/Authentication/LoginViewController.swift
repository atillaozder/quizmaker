import UIKit
import RxSwift

class LoginViewController: UIViewController, KeyboardHandler {
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    let scrollView: UIScrollView = UIScrollView()
    let contentView: UIView = UIView()
    
    private let usernameOrEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username or Email"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.textContentType = UITextContentType(rawValue: "")
        tf.returnKeyType = .done
        tf.tag = 1
        return tf
    }()
    
    private let resetPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let loginButton: IndicatorButton = {
        let button = IndicatorButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usernameOrEmailTextField.text = ""
        passwordTextField.text = ""
        removeObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        loginButton.layoutIfNeeded()
        loginButton.roundCorners(.allCorners, radius: loginButton.frame.size.height / 2)
        registerButton.layoutIfNeeded()
        registerButton.roundCorners(.allCorners, radius: registerButton.frame.size.height / 2)
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(red: 59, green: 89, blue: 152)
        usernameOrEmailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupViews()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        
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
            loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3/4)
            ])
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.text = "Login"
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
    
    private func bindUI() {
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
            self.loginButton.hideLoading()
            switch error {
            case .auth(.login(let response)):
                self.showErrorAlert(message: response.fieldError?.first)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    private func getErrorLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
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
    
    @objc
    private func registerTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            NetworkManager.shared.cancel()
            self.loginButton.hideLoading()
        }
        
        let viewController = RegisterViewController()
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateContent()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
