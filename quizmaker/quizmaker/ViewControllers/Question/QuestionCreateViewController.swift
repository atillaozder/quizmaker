
import UIKit
import RxSwift

/// :nodoc:
protocol QuestionDelegate: class {
    func getQuestion(question: Question)
}

public class QuestionCreateViewController: UIViewController, KeyboardHandler {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    /// :nodoc:
    weak var delegate: QuestionDelegate?
    
    /// :nodoc:
    var question: Question?
    
    /// :nodoc:
    var questionID = 0
    
    /// :nodoc:
    public let scrollView: UIScrollView = UIScrollView()
    
    /// :nodoc:
    public let contentView: UIView = UIView()
    
    /// :nodoc:
    var qTypes: [QuestionType] = [.multichoice, .truefalse]
    
    /// :nodoc:
    var currentType: QuestionType = .multichoice {
        didSet {
            self.answerTextView.text = ""
            self.answerErrorLabel.text = ""
            self.answerErrorWrapper.isHidden = true
            
            if currentType == .multichoice {
                abcdStackView.isHidden = false
            } else {
                abcdStackView.isHidden = true
            }
            
            questionTypePickerButton.setTitle("Question Type: \(currentType.description)", for: .normal)
        }
    }
    
    /// :nodoc:
    let stackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [], .fill, .fill, .vertical, 15)
    }()
    
    /// :nodoc:
    let questionTextView: UITextView = {
        let tv = UITextView()
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.keyboardType = .default
        tv.returnKeyType = .next
        tv.layer.borderWidth = 0.5
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.tag = 0
        return tv
    }()
    
    /// :nodoc:
    let answerTextView: UITextView = {
        let tv = UITextView()
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.keyboardType = .default
        tv.returnKeyType = .next
        tv.layer.borderWidth = 0.5
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.tag = 0
        return tv
    }()
    
    /// :nodoc:
    let answerErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    let aTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "A*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    /// :nodoc:
    let aErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var aErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: aErrorLabel)
    }()
    
    /// :nodoc:
    let bTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "B*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    /// :nodoc:
    let bErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var bErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: bErrorLabel)
    }()
    
    /// :nodoc:
    let cTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "C*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    /// :nodoc:
    let cErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var cErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: cErrorLabel)
    }()
    
    /// :nodoc:
    let dTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "D*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    /// :nodoc:
    let dErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var dErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: dErrorLabel)
    }()
    
    /// :nodoc:
    lazy var abcdStackView: UIStackView = {
        return UIView.uiStackView(arrangedSubviews: [aTextField, bTextField, cTextField, dTextField], .fillEqually, .fill, .vertical, 4)
    }()
    
    /// :nodoc:
    lazy var answerErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: answerErrorLabel)
    }()
    
    /// :nodoc:
    lazy var questionTypePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Question Type: \(currentType.description)", for: .normal)
        button.backgroundColor = UIColor.AppColors.complementary.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    /// :nodoc:
    let questionTypePickerTextField: UITextField = UITextField()
    
    /// :nodoc:
    lazy var questionTypePickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    /// :nodoc:
    let questionTypeErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var questionTypeErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: questionTypeErrorLabel)
    }()
    
    /// :nodoc:
    let pointTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Point*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .numberPad
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    /// :nodoc:
    let createQuestionButton: IndicatorButton = {
        return IndicatorButton(title: "Create")
    }()
    
    /// :nodoc:
    let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Question*"
        return lbl
    }()
    
    /// :nodoc:
    let answerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Answer*"
        return lbl
    }()
    
    /// :nodoc:
    let pointErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    /// :nodoc:
    lazy var pointErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: pointErrorLabel)
    }()
    
    init(id: Int) {
        super.init(nibName: nil, bundle: nil)
        self.questionID = id
        self.navigationItem.title = "Question"
    }
    
    /// :nodoc:
    convenience init(question: Question) {
        self.init(id: question.id)
        self.question = question
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setup()
        bindUI()
    }
    
    /// :nodoc:
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        questionTypePickerButton.roundCorners(.allCorners, radius: 10)
        createQuestionButton.roundCorners(.allCorners, radius: 10)
    }
    
    /// :nodoc:
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    /// :nodoc:
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    public func setup() {
        // setupViews()
        view.addSubview(scrollView)
        scrollView.fillSafeArea()
        scrollView.addSubview(contentView)
        contentView.fillSuperView()
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        if UserDefaults.standard.getUserType() == UserType.instructor.rawValue {
            qTypes.append(.text)
        }
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        questionTypePickerButton.addTarget(self, action: #selector(openPickerView), for: .touchUpInside)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePickerView))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closePickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancel, spaceButton, done], animated: false)
        
        questionTypePickerTextField.inputAccessoryView = toolbar
        questionTypePickerTextField.inputView = questionTypePickerView
        
        [questionTypePickerButton, questionLabel, questionTextView, abcdStackView, answerLabel, answerTextView, answerErrorWrapper, pointTextField, pointErrorWrapper, createQuestionButton].forEach { (subview) in
            stackView.addArrangedSubview(subview)
        }
        
        let wrapper = UIView()
        wrapper.addSubview(stackView)
        
        stackView.setAnchors(top: wrapper.topAnchor, bottom: nil, leading: wrapper.leadingAnchor, trailing: wrapper.trailingAnchor)
        
        let heightConstraint = stackView.heightAnchor.constraint(lessThanOrEqualTo: wrapper.heightAnchor, multiplier: 1)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true
    
        contentView.addSubview(wrapper)
        wrapper.fillSuperView(spacing: .init(top: 20, left: 16, bottom: 0, right: -16), size: .zero)
        
        questionTypePickerTextField.isHidden = true
        view.addSubview(questionTypePickerTextField)
        
        NSLayoutConstraint.activate([
            questionTypePickerButton.heightAnchor.constraint(equalToConstant: 40),
            questionTextView.heightAnchor.constraint(equalToConstant: 100),
            answerTextView.heightAnchor.constraint(equalToConstant: 100),
            answerLabel.heightAnchor.constraint(equalToConstant: 20),
            questionLabel.heightAnchor.constraint(equalToConstant: 20),
            answerErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            pointErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            pointTextField.heightAnchor.constraint(equalToConstant: 40),
            questionTypeErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            createQuestionButton.heightAnchor.constraint(equalToConstant: 40),
            aTextField.heightAnchor.constraint(equalToConstant: 40),
            ])
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        if let q = question {
            if let type = QuestionType(rawValue: q.questionType) {
                self.currentType = type
            }
            
            self.answerTextView.text = q.answer
            self.questionTextView.text = q.question
            if let point = q.point {
                self.pointTextField.text = "\(point)"
            }
            
            self.aTextField.text = q.A
            self.bTextField.text = q.B
            self.cTextField.text = q.C
            self.dTextField.text = q.D
            self.createQuestionButton.setTitle("Update", for: .normal)
        }
    }
    
    public func bindUI() {
        let point = pointTextField.rx.text.orEmpty
        let question = questionTextView.rx.text.orEmpty
        let answer = answerTextView.rx.text.orEmpty
        let a = aTextField.rx.text.orEmpty
        let b = bTextField.rx.text.orEmpty
        let c = cTextField.rx.text.orEmpty
        let d = dTextField.rx.text.orEmpty
        
        Observable.combineLatest(question.asObservable(), answer.asObservable(), point.asObservable(), a.asObservable(), b.asObservable(), c.asObservable(), d.asObservable())
            .map { [unowned self] (question, answer, pointStr, a, b, c, d) -> Bool in
                var point = pointStr
                if let p = Int(pointStr) {
                    if p == 0 {
                        self.pointTextField.text = "\(1)"
                    }
                    
                    if p > 100 {
                        self.pointTextField.text = "\(100)"
                    }
                } else {
                    self.pointTextField.text = ""
                    point = ""
                }
                
                self.answerErrorLabel.text = ""
                self.answerErrorWrapper.isHidden = true
                
                switch self.currentType {
                case .multichoice:
                    var wrong = true
                    if answer.lowercased() == "a" || answer.lowercased() == "b" || answer.lowercased() == "c" || answer.lowercased() == "d" {
                        wrong = false
                    }

                    if wrong {
                        self.answerTextView.text = ""
                        self.answerErrorLabel.text = "Answer must be A, B, C or D"
                        self.answerErrorWrapper.isHidden = false
                        return false
                    } else {
                        self.answerErrorLabel.text = ""
                        self.answerErrorWrapper.isHidden = true
                        
                        if a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty {
                            return false
                        }
                    }
                case .truefalse:
                    if answer.lowercased() == "t" || answer.lowercased() == "f" {
                        self.answerErrorLabel.text = ""
                        self.answerErrorWrapper.isHidden = true
                    } else {
                        self.answerTextView.text = ""
                        self.answerErrorLabel.text = "Answer must be T or F"
                        self.answerErrorWrapper.isHidden = false
                        return false
                    }
                default:
                    break
                }
                
                return !question.isEmpty && !answer.isEmpty && !point.isEmpty
            }.do(onNext: { [unowned self] (enabled) in
                self.createQuestionButton.alpha = enabled ? 1.0 : 0.5
            }).bind(to: createQuestionButton.rx.isEnabled)
            .disposed(by: disposeBag)

        createQuestionButton.rx.tap
            .do(onNext: { [unowned self] (_) in
                self.view.endEditing(true)
                self.createQuestionButton.showLoading()
            }).map({ [unowned self] (_) -> Question in
                
                var question = Question()
                question.id = self.questionID
                question.questionType = self.currentType.rawValue
                
                if let q = self.questionTextView.text, !q.isEmpty {
                    question.question = q
                }
                
                if let a = self.answerTextView.text, !a.isEmpty {
                    question.answer = a
                }
                
                if let p = self.pointTextField.text, !p.isEmpty {
                    question.point = Int(p)
                }
                
                if self.currentType == .multichoice {
                    if let a = self.aTextField.text, !a.isEmpty {
                        question.A = a
                    }
                    
                    if let b = self.bTextField.text, !b.isEmpty {
                        question.B = b
                    }
                    
                    if let c = self.cTextField.text, !c.isEmpty {
                        question.C = c
                    }
                    
                    if let d = self.dTextField.text, !d.isEmpty {
                        question.D = d
                    }
                }
                
                return question
            }).subscribe(onNext: { [unowned self] (question) in
                
                self.delegate?.getQuestion(question: question)
                self.navigationController?.popViewController(animated: true)
                
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// :nodoc:
    public func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            var frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        frame.size.height -= additionalSafeAreaInsets.bottom
        var contentInset: UIEdgeInsets = .zero
        contentInset.bottom = frame.size.height
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    /// :nodoc:
    public func keyboardWillHide(notification: Notification) {
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = 16
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = .zero
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    /// :nodoc:
    @objc
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    /// :nodoc:
    @objc
    private func openPickerView() {
        DispatchQueue.main.async {
            self.questionTypePickerTextField.becomeFirstResponder()
        }
    }
    
    /// :nodoc:
    @objc
    private func donePickerView() {
        let selectedRow = questionTypePickerView.selectedRow(inComponent: 0)
        currentType = qTypes[selectedRow]
        view.endEditing(true)
    }
    
    /// :nodoc:
    @objc
    private func closePickerView() {
        view.endEditing(true)
    }
}

/// :nodoc:
extension QuestionCreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return qTypes.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return qTypes[row].description
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}
