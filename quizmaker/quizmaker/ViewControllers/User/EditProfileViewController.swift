
import UIKit
import RxSwift

public class EditProfileViewController: UIViewController, KeyboardHandler {
    
    private let viewModel = EditProfileViewModel()
    private let disposeBag = DisposeBag()
    
    private let genderTypes: [Gender] = [.unspecified, .male, .female]
    
    public let scrollView: UIScrollView = UIScrollView()
    public let contentView: UIView = UIView()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.tag = 0
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "email").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
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
        tf.placeholder = "First Name*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 1
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "name").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        
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
        tf.placeholder = "Last Name*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 2
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        icon.image = UIImage(imageLiteralResourceName: "name").withRenderingMode(.alwaysTemplate)
        icon.tintColor = .lightGray
        icon.contentMode = .right
        tf.leftViewMode = .always
        tf.leftView = icon
        
        return tf
    }()
    
    private lazy var lastNameErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: lastNameErrorLabel)
    }()
    
    private lazy var lastNameErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private var selectedRow: Int = 0 {
        willSet {
            pickerButton.setTitle("Gender: \(genderTypes[newValue].description)", for: .normal)
        }
    }
    
    private var textField: UITextField = {
        let tf = UITextField()
        tf.tag = 3
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
        button.setTitle("Gender: Unspecified", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openPickerView), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private lazy var genderErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: genderErrorLabel)
    }()
    
    private lazy var genderErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    private let updateButton: IndicatorButton = {
        let button = IndicatorButton(title: "Update")
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        return button
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Password", for: .normal)
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.bindUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        updateButton.layoutIfNeeded()
        updateButton.roundCorners(.allCorners, radius: updateButton.frame.size.height / 2)
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        setupPickerView()
        emailTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        if #available(iOS 12, *) {
            emailTextField.textContentType = .oneTimeCode
            firstNameTextField.textContentType = .oneTimeCode
            lastNameTextField.textContentType = .oneTimeCode
        } else {
            emailTextField.textContentType = .init(rawValue: "")
            firstNameTextField.textContentType = .init(rawValue: "")
            lastNameTextField.textContentType = .init(rawValue: "")
        }
        
        emailTextField.text = UserDefaults.standard.getEmail()
        firstNameTextField.text = UserDefaults.standard.getFirstname()
        lastNameTextField.text = UserDefaults.standard.getLastname()
        
        if let gender = UserDefaults.standard.getGender(), let genderType = Gender(rawValue: gender) {
            switch genderType {
            case .unspecified:
                selectedRow = 0
            case .male:
                selectedRow = 1
            case .female:
                selectedRow = 2
            }
        }
        
        setupViews()
        scrollView.showsVerticalScrollIndicator = false
        
        self.navigationItem.title = "Update Profile"
        
        let subviews = [
            emailTextField,
            emailErrorWrapper,
            firstNameTextField,
            firstNameErrorWrapper,
            lastNameTextField,
            lastNameErrorWrapper,
            pickerButton,
            genderErrorWrapper,
            updateButton,
            changePasswordButton
        ]
        
        let stackView = UIView.uiStackView(arrangedSubviews: subviews, .fill, .center, .vertical, 20)
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: contentView.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        
        updateButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        NSLayoutConstraint.activate([
            firstNameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            lastNameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            emailTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            pickerButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            changePasswordButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            updateButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3/4),
            emailTextField.heightAnchor.constraint(equalTo: updateButton.heightAnchor),
            firstNameTextField.heightAnchor.constraint(equalTo: updateButton.heightAnchor),
            lastNameTextField.heightAnchor.constraint(equalTo: updateButton.heightAnchor),
            pickerButton.heightAnchor.constraint(equalTo: updateButton.heightAnchor),
            changePasswordButton.heightAnchor.constraint(equalTo: updateButton.heightAnchor),
            emailErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            genderErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            firstNameErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            lastNameErrorWrapper.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
        
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
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
        firstNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.firstname)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.lastname)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text
            .orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.email.asObservable(), viewModel.gender.asObservable(), viewModel.firstname.asObservable(), viewModel.lastname.asObservable())
            .map { (email, _, fname, lname) -> Bool in
                return !email.isEmpty && !fname.isEmpty && !lname.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.updateButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: updateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        updateButton.rx.tap
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
                self.clearFields()
                self.view.endEditing(true)
                self.updateButton.showLoading()
            })
            .bind(to: viewModel.updateTrigger)
            .disposed(by: disposeBag)
        
        viewModel.success = { [unowned self] (response) in
            UserDefaults.standard.set(response)
            self.updateButton.hideLoading()
            self.clearFields()
            self.showDismissAlert("Profile has been successfully updated")
        }
        
        viewModel.failure = { [unowned self] (error) in
            print(error.localizedDescription)
            self.updateButton.hideLoading()
            switch error {
            case .update(.editProfile(let response)):
                self.handleError(response)
            default:
                self.showErrorAlert()
            }
        }
    }
    
    @objc
    private func changePasswordTapped() {
        self.navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
    }
    
    @objc
    private func openPickerView() {
        textField.becomeFirstResponder()
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    @objc
    private func closePickerView() {
        selectedRow = self.pickerView.selectedRow(inComponent: 0)
        viewModel.gender.accept(genderTypes[selectedRow])
        textField.resignFirstResponder()
    }
    
    @objc
    private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        viewModel.gender.accept(genderTypes[selectedRow])
        self.view.endEditing(true)
    }
    
    private func handleError(_ response: EditProfileErrorResponse) {
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
        
        if let gender = response.gender?.first {
            genderErrorLabel.text = gender
            genderErrorWrapper.isHidden = false
        }
    }
    
    private func clearFields() {
        selectedRow = 0
        emailErrorLabel.text = ""
        firstNameErrorLabel.text = ""
        lastNameErrorLabel.text = ""
        emailErrorWrapper.isHidden = true
        firstNameErrorWrapper.isHidden = true
        lastNameErrorWrapper.isHidden = true
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstNameTextField || textField == lastNameTextField {
            if string.isNumeric {
                return false
            }
        }
        
        if string == " " { return false }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, !nextField.isHidden {
            DispatchQueue.main.async {
                nextField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
            updateButton.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}

// MARK: Picker View Data Source
extension EditProfileViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderTypes.count
    }
}

// MARK: Picker View Delegate
extension EditProfileViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderTypes[row].description
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}
