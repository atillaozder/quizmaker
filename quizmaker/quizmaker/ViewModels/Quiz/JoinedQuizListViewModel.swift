
import RxSwift
import RxCocoa

/**
 The JoinedQuizListViewModel is a canonical representation of the JoinedQuizListView. That is, the JoinedQuizListViewModel provides a set of interfaces, each of which represents a UI component in the JoinedQuizListView.
 */
public class JoinedQuizListViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents a value that changes over time.
    let items: BehaviorRelay<[QuizSectionModel]>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    var waiting: Bool = false
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - waiting: If true fetch request will be send waiting quizzes otherwise end quizzes will be fetched.
     
     - Precondition: `waiting` must be non-nil.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init(waiting: Bool) {
        self.waiting = waiting
        items = BehaviorRelay(value: [])
        failure = PublishSubject()
        loadPageTrigger = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[QuizSectionModel]> in
                let endpoint: QuizEndpoint = waiting ? .participantWaiting : .participantEnd
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
                        
                        observer.onNext(sectionModel)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
}
