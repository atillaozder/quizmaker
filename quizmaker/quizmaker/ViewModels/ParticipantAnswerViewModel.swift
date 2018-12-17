
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
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /// :nodoc:
    var points: [Answer]
    
    /// :nodoc:
    let quizID: Int
    
    /// :nodoc:
    let userID: Int
    
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
        self.quizID = quizID
        self.userID = userID
        
        answers = BehaviorRelay(value: [])
        loadPageTrigger = PublishSubject()
        failure = PublishSubject()
        success = PublishSubject()
        
        points = []
        
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
    
    /**
     Performs update of participant's answers. It sends the given points of the questions to the server and save them.
     
     - Precondition: participants current answers must be non-nil.
     - Precondition: `points` size must be greater than 0.
     - Precondition: given `point` must be numeric.
     - Precondition: given `point` must be greater than 0.
     - Precondition: quiz must be ended.
     
     - Invariant: `points` reference will not change during the execution of this method.
     
     - Postcondition:
     Participant's points will be updated.
     */
    public func validateAndGrade() {
        let endpoint = QuestionEndpoint.validate(quizID: quizID, userID: userID, answers: points)
        NetworkManager.shared.requestJSON(endpoint, .answerValidate)
            .subscribe(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success:
                    strongSelf.success.onNext(())
                case .failure(let error):
                    strongSelf.failure.onNext(error)
                }
                
            }).disposed(by: disposeBag)
    }
    
    /**
     Append given point to the participant scores array.
     
     - Parameters:
        - point: The participant score.
     
     - Precondition: `point` must be non-nil.
     - Precondition: `point.questionID` must be non-nil.
     - Precondition: quiz must be ended.
     
     - Invariant: `points` reference will change during the execution of this method.
     
     - Postcondition:
     Participant's scores will be added to the `points` array if it is not in the array, otherwise it will be changed.
     */
    func setPoints(point: Answer) {
        if points.contains(where: { $0.questionID == point.questionID }) {
            for (index, a) in points.enumerated() {
                if a.questionID == point.questionID {
                    points[index].point = point.point
                }
            }
        } else {
            points.append(point)
        }
    }
}
