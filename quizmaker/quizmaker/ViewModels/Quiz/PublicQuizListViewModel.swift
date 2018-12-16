
import RxSwift
import RxCocoa

/**
 The PublicQuizListViewModel is a canonical representation of the PublicQuizListView. That is, the PublicQuizListViewModel provides a set of interfaces, each of which represents a UI component in the PublicQuizListView.
 */
public class PublicQuizListViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents a value that changes over time.
    let items: BehaviorRelay<[QuizSectionModel]>
    
    /// :nodoc:
    let filtered: BehaviorRelay<[QuizSectionModel]>
    
    /// :nodoc:
    let success: PublishSubject<Quiz>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init() {
        items = BehaviorRelay(value: [])
        filtered = BehaviorRelay(value: [])
        failure = PublishSubject()
        success = PublishSubject()
        loadPageTrigger = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[QuizSectionModel]> in
                let endpoint: QuizEndpoint = .all
                return self.fetch(endpoint)
            }.bind(to: items)
            .disposed(by: disposeBag)
    }
    
    /**
     Fires an HTTP GET API request to the given endpoint. Response will be converted to observable of needed object.
     
     - Parameters:
        - endpoint: An `EndpointType` instance.
     
     - Precondition: `endpoint` must be non-nil.
     - Postcondition:
     API request will be send and after getting response, it will be returned. If an error occupied, error event will be fired.
     
     - Returns: Observable<[QuizSectionModel]>
     */
    public func fetch(_ endpoint: QuizEndpoint) -> Observable<[QuizSectionModel]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            NetworkManager.shared.request(endpoint, [Quiz].self)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let object):
                        var sectionModel: [QuizSectionModel] = []
                        object.forEach({ (quiz) in
                            sectionModel.append(.quiz(item: quiz))
                        })
                        
                        strongSelf.filtered.accept(sectionModel)
                        observer.onNext(sectionModel)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
    
    /**
     Fires a API request. If the given quiz id will found in the system it will be validated. If validation is ok then logged user will append to the quiz.
     
     - Parameters:
        - quiz: The quiz instance.
     
     - Precondition: `id` must be non-nil.
     - Precondition: `id` must be greater than 0.
     - Precondition: `quiz` must not be started.
     - Precondition: `quiz` must not be private.
     - Precondition: `quiz` must not be created by logged user.
     - Precondition: logged user must not be instructor.
     - Precondition: logged user must not be in the list of participants of `quiz`.
     
     - Invariant: `quiz` reference will change during the execution of this method.
     
     - Postcondition:
     If the given quiz id will found in the system it will be validated. If validation is ok then logged user will append to the quiz and feedback event will be fired. Otherwise, error event will fired.
     */
    public func append(_ quiz: Quiz) {
        let endpoint = QuizEndpoint.append(quizID: quiz.id)
        NetworkManager.shared.requestJSON(endpoint, .apiMessage)
            .subscribe(onNext: { [weak self] (result) in
                switch result {
                case .success:
                    self?.success.onNext(quiz)
                case .failure(let error):
                    self?.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
}
