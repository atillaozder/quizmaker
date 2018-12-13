
import UIKit
import RxSwift
import RxCocoa

protocol PercentageUpdateDelegate: class {
    func updateQuiz(quiz: Quiz)
}

class QuizPercentageUpdateViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel: QuizPercentageUpdateViewModel
    
    let percentageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Percentage Ex: '15.25'"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .decimalPad
        tf.returnKeyType = .next
        tf.tag = 0
        return tf
    }()
    
    lazy var createButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    }()
    
    weak var delegate: PercentageUpdateDelegate?
    
    init(quiz: Quiz) {
        viewModel = QuizPercentageUpdateViewModel(quiz: quiz)
        self.percentageTextField.text = quiz.percentage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.setRightBarButton(createButton, animated: true)
        self.navigationItem.title = "Quiz Update"
        
        view.addSubview(percentageTextField)
        percentageTextField.setAnchors(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, spacing: UIEdgeInsets.init(top: 10, left: 16, bottom: 0, right: -16))
        percentageTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
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
        
        createButton.rx.tap
            .do(onNext: { [unowned self] () in
                self.view.endEditing(true)
            }).subscribe(onNext: { [unowned self] (_) in
                let title = "Update Quiz"
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
        
        viewModel.failure.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (error) in
                self.createButton.isEnabled = true
                print(error.localizedDescription)
                switch error {
                case .quiz(.create(let response)):
                    self.showErrorAlert(message: response.percentage?.first ?? "An error occupied")
                default:
                    self.showErrorAlert()
                }
            }).disposed(by: disposeBag)
        
        viewModel.success.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let title = "Quiz has successfully updated."
                self.delegate?.updateQuiz(quiz: self.viewModel.quiz)
                self.showDismissAlert(title)
            }).disposed(by: disposeBag)
    }
}