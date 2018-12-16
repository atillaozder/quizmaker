
import Foundation
import RxSwift
import RxCocoa

/**
 The ParticipantAnswerViewModel is a canonical representation of the ParticipantAnswerView. That is, the ParticipantAnswerViewModel provides a set of interfaces, each of which represents a UI component in the ParticipantAnswerView.
 */
public class ParticipantAnswerViewModel {
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    /// Represents array of answers that changes over time.
    let answers: BehaviorRelay<[ParticipantAnswer]>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - quizID: Quiz Identifier
        - userID: User identifier.
     
     - Precondition: `quizID` must be non-nil.
     - Precondition: `quizID` must be greater than 0.
     - Precondition: `userID` must be non-nil.
     - Precondition: `userID` must be greater than 0.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init(quizID: Int, userID: Int) {
        
        answers = BehaviorRelay(value: [])
        loadPageTrigger = PublishSubject()
        failure = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap({ [weak self] (_) -> Observable<[ParticipantAnswer]> in
                guard let strongSelf = self else { return .empty() }
                let endpoint = QuizEndpoint.ownerParticipantAnswer(quizID: quizID, userID: userID)
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
