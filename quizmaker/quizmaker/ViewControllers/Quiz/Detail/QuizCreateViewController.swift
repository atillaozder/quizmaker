
import UIKit
import RxSwift
import RxCocoa

protocol UpdateQuizDelegate: class {
    func updateQuiz(q: Quiz)
}

private let quizCreateQuestionCellId = "quizCreateQuestionCellId"

public class QuizCreateViewController: UIViewController, KeyboardHandler {
    
    private let disposeBag = DisposeBag()
    private var viewModel = QuizCreateViewModel()
    
    var courses: [Course] = [] {
        didSet {
            coursePickerView.reloadAllComponents()
            if let q = viewModel.quiz, let course = q.courseID {
                if let tuple = courses.enumerated().first(where: { $1.id == course }) {
                    coursePickerView.selectRow(tuple.offset, inComponent: 0, animated: false)
                    coursePickerButton.setTitle("Course: \(tuple.element.name)", for: .normal)
                }
            }
        }
    }
    
    public let scrollView = UIScrollView()
    public let contentView = UIView()
    
    let quizNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name*"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .default
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    let quizDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.keyboardType = .default
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.returnKeyType = .next
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.tag = 0
        return tv
    }()
    
    let coursePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Course*", for: .normal)
        button.backgroundColor = UIColor.AppColors.complementary.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let coursePickerTextField: UITextField = UITextField()
    lazy var coursePickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    let courseErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var courseErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: courseErrorLabel)
    }()
    
    let startDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Start*", for: .normal)
        button.backgroundColor = UIColor.AppColors.complementary.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let startDateTextField: UITextField = UITextField()
    let startDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .dateAndTime
        dp.date = Date()
        return dp
    }()
    
    let endDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select End*", for: .normal)
        button.backgroundColor = UIColor.AppColors.complementary.rawValue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let endDateTextField: UITextField = UITextField()
    let endDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .dateAndTime
        dp.date = Date()
        return dp
    }()
    
    let beGradedButton: CheckBox = {
        let button = CheckBox()
        button.setTitle("Will Be Graded", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    let stackView: UIStackView = {
        return UIStackView.uiStackView(arrangedSubviews: [], .fill, .fill, .vertical, 15)
    }()
    
    let nameErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var nameErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: nameErrorLabel)
    }()
    
    let startErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var startErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: startErrorLabel)
    }()
    
    let endErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var endErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: endErrorLabel)
    }()
    
    let percentageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Percentage* Ex: '15.25'"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .decimalPad
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    let percentageErrorLabel: UILabel = {
        return UILabel.uiErrorLabel()
    }()
    
    lazy var percentageErrorWrapper: UIView = {
        return UIView.errorWrapperView(forLabel: percentageErrorLabel)
    }()
    
    lazy var createButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.sectionHeaderHeight = 0
        tv.sectionHeaderHeight = 0
        tv.bounces = false
        tv.showsVerticalScrollIndicator = true
        tv.backgroundColor = .white
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        return tv
    }()
    
    weak var delegate: UpdateQuizDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Create Quiz"
    }
    
    convenience init(quiz: Quiz) {
        self.init()
        viewModel = QuizCreateViewModel(quiz: quiz)
        self.navigationItem.title = "Update Quiz"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        coursePickerButton.roundCorners(.allCorners, radius: 10)
        startDateButton.roundCorners(.allCorners, radius: 10)
        endDateButton.roundCorners(.allCorners, radius: 10)
        updateContent()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindUI()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        self.navigationItem.setRightBarButton(createButton, animated: true)
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        quizNameTextField.delegate = self
        quizDescriptionTextView.delegate = self
        percentageTextField.delegate = self
        
        var frame = CGRect.zero
        frame.size.height = CGFloat.leastNonzeroMagnitude
        tableView.tableFooterView = UIView(frame: frame)
        
        setupViews()
        
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        
        let startDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneStartDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let startCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closePicker))
        
        startToolbar.setItems([startCancel, spaceButton, startDone], animated: false)
        
        startDateTextField.inputAccessoryView = startToolbar
        startDateTextField.inputView = startDatePicker
        
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        
        let endDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEndDatePicker))
        let endCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closePicker))
        
        endToolbar.setItems([endCancel, spaceButton, endDone], animated: false)
        
        endDateTextField.inputAccessoryView = endToolbar
        endDateTextField.inputView = endDatePicker
        
        let courseToolbar = UIToolbar()
        courseToolbar.sizeToFit()
        
        let courseDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneCoursePicker))
        let courseCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closePicker))
        
        courseToolbar.setItems([courseCancel, spaceButton, courseDone], animated: false)
        
        coursePickerTextField.inputAccessoryView = courseToolbar
        coursePickerTextField.inputView = coursePickerView
        
        beGradedButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        coursePickerButton.addTarget(self, action: #selector(openCoursePicker), for: .touchUpInside)
        
        startDateButton.addTarget(self, action: #selector(openStartDatePicker), for: .touchUpInside)
        
        endDateButton.addTarget(self, action: #selector(openEndDatePicker), for: .touchUpInside)
        
        percentageTextField.isHidden = true
        if UserDefaults.standard.getUserType() == UserType.instructor.rawValue {
            coursePickerView.isHidden = false
            coursePickerButton.isHidden = false
            beGradedButton.isHidden = false
        } else {
            coursePickerButton.isHidden = true
            coursePickerView.isHidden = true
            beGradedButton.isHidden = true
        }
        
        endDateTextField.isHidden = true
        startDateTextField.isHidden = true
        coursePickerTextField.isHidden = true
        
        view.addSubview(endDateTextField)
        view.addSubview(startDateTextField)
        view.addSubview(coursePickerTextField)
        
        let label = UILabel()
        label.text = "Description (Optional):"
        label.textColor = .gray
        
        let addQuestionButton = UIButton(type: .system)
        addQuestionButton.setTitleColor(.black, for: .normal)
        addQuestionButton.setTitle("Add Question (+)", for: .normal)
        addQuestionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        addQuestionButton.contentHorizontalAlignment = .left
        addQuestionButton.addTarget(self, action: #selector(appendQuestion), for: .touchUpInside)
        
        tableView.register(QuizCreateQuestionTableCell.self, forCellReuseIdentifier: quizCreateQuestionCellId)
        
        [quizNameTextField,
         nameErrorWrapper,
         label,
         quizDescriptionTextView,
         coursePickerButton,
         courseErrorWrapper,
         startDateButton,
         startErrorWrapper,
         endDateButton,
         endErrorWrapper,
         beGradedButton,
         percentageTextField,
         percentageErrorWrapper,
         addQuestionButton,
         tableView].forEach { (subview) in
            stackView.addArrangedSubview(subview)
        }
        
        contentView.addSubview(stackView)
        stackView.setAnchors(top: nil, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, spacing: .init(top: 20, left: 20, bottom: 0, right: -20))
        stackView.setCenter()
        let width = self.view.frame.width - 40
        stackView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            quizNameTextField.heightAnchor.constraint(equalToConstant: 40),
            nameErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            label.heightAnchor.constraint(equalToConstant: 20),
            quizDescriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            coursePickerButton.heightAnchor.constraint(equalToConstant: 40),
            courseErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            startDateButton.heightAnchor.constraint(equalToConstant: 40),
            startErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            endDateButton.heightAnchor.constraint(equalToConstant: 40),
            endErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            beGradedButton.heightAnchor.constraint(equalToConstant: 40),
            percentageTextField.heightAnchor.constraint(equalToConstant: 40),
            percentageErrorWrapper.heightAnchor.constraint(equalToConstant: 20),
            addQuestionButton.heightAnchor.constraint(equalToConstant: 40),
            tableView.heightAnchor.constraint(equalToConstant: 200),
            ])
        
        beGradedButton.isChecked = false
        
        
        if let q = viewModel.quiz {
            quizNameTextField.text = q.name
            quizDescriptionTextView.text = q.description
            startDatePicker.date = q.start
            let start = DateFormatter.localizedString(from: q.start, dateStyle: .medium, timeStyle: .medium)
            startDateButton.setTitle(start, for: .normal)
            endDatePicker.date = q.end
            let end = DateFormatter.localizedString(from: q.end, dateStyle: .medium, timeStyle: .medium)
            endDateButton.setTitle(end, for: .normal)
            beGradedButton.isChecked = q.beGraded
            percentageTextField.text = q.percentage
        }
    }
    
    private func bindUI() {
        viewModel.loadPageTrigger.onNext(())
        
        quizNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        quizDescriptionTextView.rx.text
            .orEmpty
            .bind(to: viewModel.desc)
            .disposed(by: disposeBag)
        
        percentageTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .map { [unowned self] (text) -> Double in
                
                if var percentage = Double(text) {
                    
                    if floor(percentage) != percentage {
                        percentage = (percentage * 100).rounded() / 100
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    if percentage == 0 {
                        percentage = 1
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    if percentage > 100 {
                        percentage = 100
                        self.percentageTextField.text = "\(percentage)"
                    }
                    
                    return percentage
                }
                
                self.percentageTextField.text = ""
                return -1
            }.bind(to: viewModel.percentage)
            .disposed(by: disposeBag)
        
        let set = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ0123456789 ")
        
        Observable.combineLatest(viewModel.name.asObservable(), viewModel.course.asObservable(), viewModel.start.asObservable(), viewModel.end.asObservable(), viewModel.beGraded.asObservable(), viewModel.percentage.asObservable())
            .map { [unowned self] (name, courseID, startDate, endDate, beGraded, percentage) -> Bool in
                
                if name.isEmpty {
                    self.nameErrorLabel.text = "Quiz name cannot be empty"
                    self.nameErrorWrapper.isHidden = false
                    return false
                } else {
                    if name.rangeOfCharacter(from: set.inverted) != nil {
                        self.nameErrorLabel.text = "Quiz name can contains only letters and numbers"
                        self.nameErrorWrapper.isHidden = false
                        return false
                    } else {
                        self.nameErrorLabel.text = ""
                        self.nameErrorWrapper.isHidden = true
                    }
                }
                
                if UserDefaults.standard.getUserType() == UserType.instructor.rawValue {
                    if courseID == nil {
                        self.courseErrorWrapper.isHidden = false
                        self.courseErrorLabel.text = "Course cannot be empty"
                        return false
                    } else {
                        self.courseErrorWrapper.isHidden = true
                        self.courseErrorLabel.text = ""
                    }
                }
                
                guard let start = startDate else {
                    self.startErrorLabel.text = "Start Date cannot be empty"
                    self.startErrorWrapper.isHidden = false
                    return false
                }
                
                self.startErrorLabel.text = ""
                self.startErrorWrapper.isHidden = true
                
                guard let end = endDate else {
                    self.endErrorLabel.text = "End Date cannot be empty"
                    self.endErrorWrapper.isHidden = false
                    return false
                }
                
                self.endErrorLabel.text = ""
                self.endErrorWrapper.isHidden = true
                
                let today = Date()
                if start < today {
                    self.startErrorLabel.text = "Start Date should be set after now"
                    self.startErrorWrapper.isHidden = false
                    return false
                } else {
                    self.startErrorLabel.text = ""
                    self.startErrorWrapper.isHidden = true
                }
                
                if end < today {
                    self.endErrorLabel.text = "End Date should be set after now"
                    self.endErrorWrapper.isHidden = false
                    return false
                } else {
                    self.endErrorLabel.text = ""
                    self.endErrorWrapper.isHidden = true
                }
                
                if end <= start {
                    self.endErrorLabel.text = "End Date should be set after start date"
                    self.endErrorWrapper.isHidden = false
                    return false
                } else {
                    self.endErrorLabel.text = ""
                    self.endErrorWrapper.isHidden = true
                }
                
                if beGraded, percentage == nil {
                    self.percentageErrorLabel.text = "Percentage cannot be empty."
                    self.percentageErrorWrapper.isHidden = false
                    return false
                } else {
                    self.percentageErrorLabel.text = ""
                    self.percentageErrorWrapper.isHidden = true
                }
                
                return true
            }.bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
            }).subscribe(onNext: { [unowned self] (_) in
                let title = (self.viewModel.quiz != nil) ? "Update Quiz" : "Create Quiz"
                let alertController = UIAlertController(title: "Are you sure?", message: "This operation cannot be undo", preferredStyle: .alert)
                let ok = UIAlertAction(title: title, style: .default, handler: { (_) in
                    self.createButton.isEnabled = false
                    self.viewModel.createTrigger.onNext(())
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alertController.addAction(cancel)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.courses.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (courses) in
                self.courses = courses
            }).disposed(by: disposeBag)
        
        viewModel.failure.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                self.createButton.isEnabled = true
                print(error.localizedDescription)
                switch error {
                case .quiz(.create(let response)):
                    self.handleError(response)
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        viewModel.success.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let title = (self.viewModel.quiz == nil) ? "Quiz has successfully created." : "Quiz has successfully updated."
                self.showDismissAlert(title)
            }).disposed(by: disposeBag)
        
        viewModel.questions.asDriver()
            .drive(tableView.rx.items(cellIdentifier: quizCreateQuestionCellId, cellType: QuizCreateQuestionTableCell.self)) { (row, element, cell) in
                cell.configure(element)
            }.disposed(by: disposeBag)
        
        viewModel.updated.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (q) in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.updateQuiz(q: q)
            }).disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Question.self))
            .subscribe(onNext: { [weak self] (indexPath, item) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
                let viewController = QuestionCreateViewController(question: item, questionCount: indexPath.row + 1)
                viewController.delegate = self
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func handleError(_ response: QuizCreateErrorResponse) {
        if let start = response.start {
            startErrorLabel.text = start.first
            startErrorWrapper.isHidden = false
        } else {
            startErrorLabel.text = ""
            startErrorWrapper.isHidden = true
        }
        
        if let end = response.end {
            endErrorLabel.text = end.first
            endErrorWrapper.isHidden = false
        } else {
            endErrorLabel.text = ""
            endErrorWrapper.isHidden = true
        }
        
        if let name = response.name {
            nameErrorLabel.text = name.first
            nameErrorWrapper.isHidden = false
        } else {
            nameErrorLabel.text = ""
            nameErrorWrapper.isHidden = true
        }
        
        if let percentage = response.percentage {
            percentageErrorLabel.text = percentage.first
            percentageErrorWrapper.isHidden = false
        } else {
            percentageErrorLabel.text = ""
            percentageErrorWrapper.isHidden = true
        }
        
        if let course = response.course {
            courseErrorLabel.text = course.first
            courseErrorWrapper.isHidden = false
        } else {
            courseErrorLabel.text = ""
            courseErrorWrapper.isHidden = true
        }
    }
    
    public func keyboardWillShow(notification: Notification) {}
    
    public func keyboardWillHide(notification: Notification) {}
    
    @objc
    private func appendQuestion() {
        viewModel.currentIndex += 1
        let viewController = QuestionCreateViewController(id: viewModel.currentIndex)
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func dismissKeyboard() {
        self.view.endEditing(true)
        updateContent()
    }
    
    @objc
    func checkboxTapped(_ sender: UIButton) {
        beGradedButton.isChecked = !beGradedButton.isChecked
        percentageTextField.isHidden = !beGradedButton.isChecked
        viewModel.beGraded.accept(beGradedButton.isChecked)
        updateContent()
    }
    
    @objc
    private func openCoursePicker() {
        dismissKeyboard()
        DispatchQueue.main.async {
            self.coursePickerTextField.becomeFirstResponder()
        }
    }
    
    @objc
    private func openStartDatePicker() {
        dismissKeyboard()
        DispatchQueue.main.async {
            self.startDateTextField.becomeFirstResponder()
        }
    }
    
    @objc
    private func openEndDatePicker() {
        dismissKeyboard()
        DispatchQueue.main.async {
            self.endDateTextField.becomeFirstResponder()
        }
    }
    
    @objc
    private func doneCoursePicker() {
        let selectedRow = coursePickerView.selectedRow(inComponent: 0)
        coursePickerButton.setTitle("Course: \(courses[selectedRow].name)", for: .normal)
        viewModel.course.accept(courses[selectedRow].id)
        dismissKeyboard()
    }
    
    @objc
    private func doneStartDatePicker() {
        let str = DateFormatter.localizedString(from: startDatePicker.date, dateStyle: .medium, timeStyle: .medium)
        startDateButton.setTitle("Start: \(str)", for: .normal)
        viewModel.start.accept(startDatePicker.date)
        dismissKeyboard()
    }
    
    @objc
    private func doneEndDatePicker() {
        let str = DateFormatter.localizedString(from: endDatePicker.date, dateStyle: .medium, timeStyle: .medium)
        endDateButton.setTitle("Until: \(str)", for: .normal)
        viewModel.end.accept(endDatePicker.date)
        dismissKeyboard()
    }
    
    @objc
    private func closePicker() {
        dismissKeyboard()
    }
    
    private func deleteTapped(_ indexPath: IndexPath) {
        guard indexPath.row < viewModel.questions.value.count else { return }
        var values = viewModel.questions.value
        values.remove(at: indexPath.row)
        viewModel.questions.accept(values)
    }
}

extension QuizCreateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row].name
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

extension QuizCreateViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateContent()
        return true
    }
}

extension QuizCreateViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        updateContent()
        return true
    }
}

extension QuizCreateViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            self.deleteTapped(indexPath)
        }
        
        delete.backgroundColor = .red
        return [delete]
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (_, _, _) in
            self.deleteTapped(indexPath)
        }
        
        delete.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

extension QuizCreateViewController: QuestionDelegate {
    func getQuestion(question: Question) {
        var value = viewModel.questions.value
        if value.contains(where: { $0.id == question.id }) {
            for (index, q) in value.enumerated() {
                if q.id == question.id {
                    value.remove(at: index)
                    value.insert(question, at: index)
                }
            }
        } else {
            value.append(question)
        }
        
        viewModel.questions.accept(value)
    }
}
