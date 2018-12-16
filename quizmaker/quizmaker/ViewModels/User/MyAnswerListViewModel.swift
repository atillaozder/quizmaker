
import Foundation
import RxSwift
import RxCocoa

/**
 The MyAnswerListViewModel is a canonical representation of the MyAnswerListView. That is, the MyAnswerListViewModel provides a set of interfaces, each of which represents a UI component in the MyAnswerListView.
 */
public class MyAnswerListViewModel {
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    /// :nodoc:
    let answers: BehaviorRelay<[ParticipantAnswer]>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - quizID: The identifier of quiz that helps fetching the objects.
     
     - Precondition: `quizID` must be non-nil.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init(quizID: Int) {
        answers = BehaviorRelay(value: [])
        loadPageTrigger = PublishSubject()
        failure = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap({ [weak self] (_) -> Observable<[ParticipantAnswer]> in
                guard let strongSelf = self else { return .empty() }
                let endpoint = QuizEndpoint.participantAnswer(quizID: quizID)
                return strongSelf.fetch(endpoint)
            }).bind(to: answers)
            .disposed(by: disposeBag)
    }
    
    /**
     Fires an HTTP GET API request to the given endpoint. Response will be converted to observable of needed object.
     
     - Parameters:
        - endpoint: An `EndpointType` instance.
     
     - Precondition: `endpoint` must be non-nil.
     - Postcondition:
     API request will be send and after getting response, it will be returned. If an error occupied, error event will be fired.
     
     - Returns: Observable<[ParticipantAnswer]>
     */
    public func fetch(_ endpoint: QuizEndpoint) -> Observable<[ParticipantAnswer]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            NetworkManager.shared.request(endpoint, [ParticipantAnswer].self, .apiMessage)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let object):
                        observer.onNext(object)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
}
