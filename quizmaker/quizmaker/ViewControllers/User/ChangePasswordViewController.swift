
import UIKit
import RxSwift

import RxCocoa
class ChangePasswordViewModel {
    
    private let disposeBag = DisposeBag()
    let oldPassword: BehaviorRelay<String>
    let newPassword: BehaviorRelay<String>
    let confirmPassword: BehaviorRelay<String>
    
    var success: (() -> Void)?
    var failure: ((NetworkError) -> Void)?
    
    let changePasswordTrigger: PublishSubject<Void>
    
    init() {
        oldPassword = BehaviorRelay(value: "")
        newPassword = BehaviorRelay(value: "")
        confirmPassword = BehaviorRelay(value: "")
        
        changePasswordTrigger = PublishSubject()
        changePasswordTrigger.asObservable()
            .subscribe(onNext: { [unowned self] () in
                
                let model = ChangePassword(old: self.oldPassword.value, new: self.newPassword.value, confirm: self.confirmPassword.value)
                
                let endpoint = UserEndpoint.changePassword(model: model)
                NetworkManager.shared.requestJSON(endpoint, .changePassword)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success:
                            UserDefaults.standard.setPassword(password: self.newPassword.value)
                            self.success?()
                        case .failure(let error):
                            self.failure?(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
}

class ChangePasswordViewController: UIViewController, KeyboardHandler {
    
    private let viewModel = ChangePasswordViewModel()
    private let disposeBag = DisposeBag()
    
    let scrollView: UIScrollView = UIScrollView()
    let contentView: UIView = UIView()

    private let oldPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Old Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    private lazy var oldPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: oldPasswordErrorLabel)
    }()
    
    private lazy var oldPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 1
        return tf
    }()
    
    private lazy var newPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: newPasswordErrorLabel)
    }()
    
    private lazy var newPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.textContentType = UITextContentType(rawValue: "")
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 2
        return tf
    }()
    
    private lazy var confirmPasswordErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: confirmPasswordErrorLabel)
    }()
    
    private lazy var confirmPasswordErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let changePasswordButton: IndicatorButton = {
        let button = IndicatorButton(title: "Change Password")
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor.AppColors.main.rawValue
        button.setTitleColor(.white, for: .normal)
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
        changePasswordButton.layoutIfNeeded()
        changePasswordButton.roundCorners(.allCorners, radius: changePasswordButton.frame.size.height / 2)
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        setupViews()
        scrollView.showsVerticalScrollIndicator = false
        
        self.navigationItem.title = "Change Password"
        
        if #available(iOS 12, *) {
            oldPasswordTextField.textContentType = .oneTimeCode
            newPasswordTextField.textContentType = .oneTimeCode
            confirmPasswordTextField.textContentType = .oneTimeCode
        } else {
            oldPasswordTextField.textContentType = .init(rawValue: "")
            newPasswordTextField.textContentType = .init(rawValue: "")
            confirmPasswordTextField.textContentType = .init(rawValue: "")
        }
        
        let subviews = [
            oldPasswordTextField,
            oldPasswordErrorWrapper,
            newPasswordTextField,
            newPasswordErrorWrapper,
            confirmPasswordTextField,
            confirmPasswordErrorWrapper,
            changePasswordButton
        ]
        
        let stackView = UIView.uiStackView(arrangedSubviews: subviews, .fill, .center, .vertical, 20)
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: contentView.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        
        changePasswordButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        NSLayoutConstraint.activate([
            oldPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            newPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            confirmPasswordTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            changePasswordButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3/4),
            
            oldPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),
            newPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalTo: changePasswordButton.heightAnchor),

            oldPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            newPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            confirmPasswordErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            ])
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
    private func bindUI() {
        oldPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.oldPassword)
            .disposed(by: disposeBag)
        
        newPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.newPassword)
            .disposed(by: disposeBag)
        
        confirmPasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.confirmPassword)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.oldPassword.asObservable(), viewModel.newPassword.asObservable(), viewModel.confirmPassword.asObservable())
            .map { (old, new, confirm) -> Bool in
                return !old.isEmpty && !new.isEmpty && !confirm.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.changePasswordButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: changePasswordButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
                self.clearFields()
                self.changePasswordButton.showLoading()
            })
            .bind(to: viewModel.changePasswordTrigger)
            .disposed(by: disposeBag)
        
        viewModel.success = { [unowned self] () in
            self.changePasswordButton.hideLoading()
            self.showDismissAlert("Password has been successfully changed")
        }
        
        viewModel.failure = { [unowned self] (error) in
            print(error.localizedDescription)
            self.changePasswordButton.hideLoading()
            switch error {
            case .update(.changePassword(let response)):
                self.handleError(response)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func handleError(_ response: ChangePasswordErrorResponse) {
        if let old = response.oldPassword?.first {
            oldPasswordErrorLabel.text = old
            oldPasswordErrorWrapper.isHidden = false
        }
        
        if let new = response.newPassword?.first {
            newPasswordErrorLabel.text = new
            newPasswordErrorWrapper.isHidden = false
        }
    }
    
    private func clearFields() {
        oldPasswordErrorLabel.text = ""
        oldPasswordErrorWrapper.isHidden = true
        newPasswordErrorLabel.text = ""
        newPasswordErrorWrapper.isHidden = true
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, !nextField.isHidden {
            DispatchQueue.main.async {
                nextField.becomeFirstResponder()
            }
        } else {
            changePasswordButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}