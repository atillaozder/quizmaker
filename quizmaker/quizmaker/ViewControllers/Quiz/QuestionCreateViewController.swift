import UIKit
import RxSwift

protocol QuestionDelegate: class {
    func getQuestion(question: Question)
}

class QuestionCreateViewController: UIViewController, KeyboardHandler {
    
    private let disposeBag = DisposeBag()
    weak var delegate: QuestionDelegate?
    var question: Question?
    var questionID = 0
    
    let scrollView: UIScrollView = UIScrollView()
    let contentView: UIView = UIView()
    
    var qTypes: [QuestionType] = [.multichoice, .truefalse]
    var currentType: QuestionType = .multichoice {
        didSet {
            self.answerTextView.text = ""
            self.answerErrorLabel.text = ""
            self.answerErrorWrapper.isHidden = true
            questionTypePickerButton.setTitle("Question Type: \(currentType.description)", for: .normal)
        }
    }
    
    let stackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [], .fill, .fill, .vertical, 15)
    }()
    
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
    
    let answerErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var answerErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: answerErrorLabel)
    }()
    
    lazy var questionTypePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Question Type: \(currentType.description)", for: .normal)
        button.backgroundColor = UIColor.AppColors.complementary.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let questionTypePickerTextField: UITextField = UITextField()
    lazy var questionTypePickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    let questionTypeErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var questionTypeErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: questionTypeErrorLabel)
    }()
    
    let pointTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Point"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .numberPad
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    let createQuestionButton: IndicatorButton = {
        return IndicatorButton(title: "Create")
    }()
    
    let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Question"
        return lbl
    }()
    
    let answerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Answer"
        return lbl
    }()
    
    let pointErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var pointErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: pointErrorLabel)
    }()
    
    init(id: Int) {
        super.init(nibName: nil, bundle: nil)
        self.questionID = id
        self.navigationItem.title = "Question"
    }
    
    convenience init(question: Question, questionCount: Int) {
        self.init(id: question.id)
        self.question = question
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setup()
        bindUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
        questionTypePickerButton.roundCorners(.allCorners, radius: 10)
        createQuestionButton.roundCorners(.allCorners, radius: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func setup() {
        setupViews()
        if UserDefaults.standard.getUserType() == UserType.instructor.rawValue {
            qTypes.append(.text)
        }
        
        questionTypePickerButton.addTarget(self, action: #selector(openPickerView), for: .touchUpInside)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePickerView))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closePickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancel, spaceButton, done], animated: false)
        
        questionTypePickerTextField.inputAccessoryView = toolbar
        questionTypePickerTextField.inputView = questionTypePickerView
        
        [questionTypePickerButton, questionLabel, questionTextView, answerLabel, answerTextView, answerErrorWrapper, pointTextField, pointErrorWrapper, createQuestionButton].forEach { (subview) in
            stackView.addArrangedSubview(subview)
        }
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: nil, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        stackView.setCenter()
        let width = self.view.frame.width - 40
        stackView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
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
            createQuestionButton.heightAnchor.constraint(equalToConstant: 40)
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
            
            self.createQuestionButton.setTitle("Update", for: .normal)
        }
    }
    
    private func bindUI() {
        let point = pointTextField.rx.text.orEmpty
        let question = questionTextView.rx.text.orEmpty
        let answer = answerTextView.rx.text.orEmpty
        
        Observable.combineLatest(question.asObservable(), answer.asObservable(), point.asObservable())
            .map { [unowned self] (question, answer, pointStr) -> Bool in
                var point = pointStr
                if let p = Int(pointStr) {
                    if p == 0 {
                        self.pointTextField.text = "\(0)"
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
                let q = self.questionTextView.text!
                let a = self.answerTextView.text!
                
                question.id = self.questionID
                question.question = q
                question.answer = a
                question.questionType = self.currentType.rawValue
                
                if let p = self.pointTextField.text, !p.isEmpty {
                    question.point = Int(p)
                }
                
                return question
            }).subscribe(onNext: { [unowned self] (question) in
                
                self.delegate?.getQuestion(question: question)
                self.navigationController?.popViewController(animated: true)
                
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc
    private func openPickerView() {
        DispatchQueue.main.async {
            self.questionTypePickerTextField.becomeFirstResponder()
        }
    }
    
    @objc
    private func donePickerView() {
        let selectedRow = questionTypePickerView.selectedRow(inComponent: 0)
        currentType = qTypes[selectedRow]
        view.endEditing(true)
    }
    
    @objc
    private func closePickerView() {
        view.endEditing(true)
    }
}

extension QuestionCreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return qTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return qTypes[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}