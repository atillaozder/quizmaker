import UIKit
import RxSwift

class RegisterViewController: UIViewController, KeyboardHandler {
    
    private let viewModel = RegisterViewModel()
    private let disposeBag = DisposeBag()
    
    private let userTypes: [UserType] = [.normal, .instructor, .student]
    
    let scrollView: UIScrollView = UIScrollView()
    let contentView: UIView = UIView()
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    private lazy var usernameErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: usernameErrorLabel)
    }()
    
    private lazy var usernameErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.tag = 1
        return tf
    }()
    
    private lazy var emailErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: emailErrorLabel)
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "First Name"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 2
        return tf
    }()
    
    private lazy var firstNameErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: firstNameErrorLabel)
    }()
    
    private lazy var firstNameErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let lastNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Last Name"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 3
        return tf
    }()
    
    private lazy var lastNameErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: lastNameErrorLabel)
    }()
    
    private lazy var lastNameErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 4
        return tf
    }()
    
    private lazy var passwordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: passwordErrorLabel)
    }()
    
    private lazy var passwordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let studentIdTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Student ID"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.tag = 5
        tf.isHidden = true
        return tf
    }()
    
    private var selectedRow: Int = 0 {
        willSet {
            if userTypes[newValue] == .student {
                studentIdTextField.isHidden = false
            } else {
                studentIdTextField.isHidden = true
            }
            
            pickerButton.setTitle("User Type: \(userTypes[newValue].description)", for: .normal)
        }
    }
    
    private var textField: UITextField = {
        let tf = UITextField()
        tf.tag = 6
        return tf
    }()
    
    private lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.dataSource = self
        pv.delegate = self
        pv.showsSelectionIndicator = true
        pv.backgroundColor = .white
        return pv
    }()
    
    private lazy var pickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("User Type: Normal", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openPickerView), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var studentIdErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: studentIdErrorLabel)
    }()
    
    private lazy var studentIdErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let registerButton: IndicatorButton = {
        let button = IndicatorButton(title: "Sign Up")
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        registerButton.layoutIfNeeded()
        registerButton.roundCorners(.allCorners, radius: registerButton.frame.size.height / 2)
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(red: 59, green: 89, blue: 152)
        setupPickerView()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        setupViews()
        scrollView.showsVerticalScrollIndicator = false
        
        let loginRedirectLabel = UILabel()
        loginRedirectLabel.text = "Return Login"
        loginRedirectLabel.font = UIFont.boldSystemFont(ofSize: 18)
        loginRedirectLabel.textColor = UIColor.white
        loginRedirectLabel.textAlignment = .center
        loginRedirectLabel.isUserInteractionEnabled = true
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.text = "Register"
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        
        contentView.addSubview(titleLabel)
        titleLabel.setAnchors(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 30, bottom: 0, right: -30))
        
        let subviews = [
            usernameTextField,
            usernameErrorWrapper,
            emailTextField,
            emailErrorWrapper,
            firstNameTextField,
            firstNameErrorWrapper,
            lastNameTextField,
            lastNameErrorWrapper,
            passwordTextField,
            passwordErrorWrapper,
            studentIdTextField,
            studentIdErrorWrapper,
            pickerButton,
            registerButton,
        ]
        
        let stackView = UIView.uiStackView(arrangedSubviews: subviews, .fill, .center, .vertical, 20)
        
        registerButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: titleLabel.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 0, left: 20, bottom: 0, right: -20))
        stackView.setCenter()
        
        NSLayoutConstraint.activate([
            usernameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            firstNameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            lastNameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            emailTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            studentIdTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            pickerButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            registerButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3/4),
            usernameTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            emailTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            firstNameTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            lastNameTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            studentIdTextField.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            pickerButton.heightAnchor.constraint(equalTo: registerButton.heightAnchor),
            usernameErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            emailErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            passwordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            studentIdErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            firstNameErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            lastNameErrorWrapper.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        contentView.addSubview(loginRedirectLabel)
        loginRedirectLabel.setAnchors(top: stackView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 30, left: 20, bottom: 0, right: -20))
        
        loginRedirectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginRedirect(_:))))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    private func setupPickerView() {
        textField.isHidden = true
        view.addSubview(textField)
        let toolbar = UIToolbar()
        toolbar.setBackgroundImage(nil, forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.barTintColor = .white
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closePickerView))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolbar
        textField.inputAccessoryView?.backgroundColor = .white
    }
    
    private func bindUI() {
        usernameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        firstNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.firstName)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.lastName)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text
            .orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        studentIdTextField.rx.text
            .orEmpty
            .bind(to: viewModel.studentId)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.username.asObservable(), viewModel.password.asObservable(), viewModel.email.asObservable(), viewModel.studentId.asObservable())
            .map { (username, password, email, studentId) -> Bool in

                if self.userTypes[self.selectedRow] == .student {
                    if let id = studentId {
                        if id.isEmpty {
                            return false
                        }
                    } else {
                        return false
                    }
                }
                
                return !username.isEmpty && !password.isEmpty && !email.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.registerButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .flatMap({ [unowned self] (_) -> Observable<Void> in
                if !self.viewModel.validEmail {
                    self.emailErrorLabel.text = "Please enter a valid email address"
                    self.emailErrorWrapper.isHidden = false
                    return .empty()
                } else {
                    self.emailErrorLabel.text = ""
                    self.emailErrorWrapper.isHidden = true
                    return .just(())
                }
            })
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
                self.registerButton.showLoading()
            })
            .bind(to: viewModel.registerTrigger)
            .disposed(by: disposeBag)
        
        viewModel.registerSuccess = { [unowned self] (signUp) in
            self.registerButton.hideLoading()
            self.clearFields()
            self.dismiss(animated: false, completion: nil)
        }
        
        viewModel.error = { [unowned self] (error) in
            print(error.localizedDescription)
            self.registerButton.hideLoading()
            switch error {
            case .auth(.register(let response)):
                self.handleError(response)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    @objc
    private func openPickerView() {
        textField.becomeFirstResponder()
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    @objc
    private func closePickerView() {
        selectedRow = self.pickerView.selectedRow(inComponent: 0)
        viewModel.userType.accept(userTypes[selectedRow])
        textField.resignFirstResponder()
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        viewModel.userType.accept(userTypes[selectedRow])
        self.view.endEditing(true)
    }
    
    @objc
    private func loginRedirect(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    private func handleError(_ response: RegisterErrorResponse) {
        
        if let username = response.username?.first {
            usernameErrorLabel.text = username
            usernameErrorWrapper.isHidden = false
        }
        
        if let password = response.password?.first {
            passwordErrorLabel.text = password
            passwordErrorWrapper.isHidden = false
        }
        
        if let firstName = response.firstName?.first {
            firstNameErrorLabel.text = firstName
            firstNameErrorWrapper.isHidden = false
        }
        
        if let lastName = response.lastName?.first {
            lastNameErrorLabel.text = lastName
            lastNameErrorWrapper.isHidden = false
        }
        
        if let email = response.email?.first {
            emailErrorLabel.text = email
            emailErrorWrapper.isHidden = false
        }
        
        if let student = response.studentId?.first {
            studentIdErrorLabel.text = student
            studentIdErrorWrapper.isHidden = false
        }
    }
    
    private func clearFields() {
        selectedRow = 0
        studentIdTextField.isHidden = true

        usernameTextField.text = ""
        usernameErrorLabel.text = ""
        emailTextField.text = ""
        emailErrorLabel.text = ""
        passwordTextField.text = ""
        passwordErrorLabel.text = ""
        firstNameTextField.text = ""
        firstNameErrorLabel.text = ""
        lastNameTextField.text = ""
        lastNameErrorLabel.text = ""
        studentIdTextField.text = ""
        studentIdErrorLabel.text = ""
        
        usernameErrorWrapper.isHidden = true
        passwordErrorWrapper.isHidden = true
        emailErrorWrapper.isHidden = true
        firstNameErrorWrapper.isHidden = true
        lastNameErrorWrapper.isHidden = true
        studentIdErrorWrapper.isHidden = true
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstNameTextField { return true }
        if string == " " { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, !nextField.isHidden {
            DispatchQueue.main.async {
                nextField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
            registerButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}

// MARK: Picker View Data Source
extension RegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userTypes.count
    }
}

// MARK: Picker View Delegate
extension RegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userTypes[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}