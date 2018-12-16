
import Foundation
import RxSwift
import RxCocoa

/**
 The QuizUpdateViewModel is a canonical representation of the QuizUpdateView. That is, the QuizUpdateViewModel provides a set of interfaces, each of which represents a UI component in the QuizUpdateView.
 */
public class QuizUpdateViewModel {
    
    /// Holds the quiz instance to be updated.
    var quiz: Quiz
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents a percentage that changes over time.
    let percentage: BehaviorRelay<Double>
    
    /// :nodoc:
    let updateTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - quiz: Instance of quiz helps to update.
     
     - Precondition: `quiz` must be non-nil.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init(quiz: Quiz) {
        self.quiz = quiz
        percentage = BehaviorRelay(value: -1)
        
        failure = PublishSubject()
        success = PublishSubject()
        updateTrigger = PublishSubject()
        
        updateTrigger.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.updateQuiz()
            }).disposed(by: disposeBag)
    }
    
    /**
     Updates the quiz only if it is finished. Instead of updating entire quiz, only percentage will be updated.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` must be finished.
     - Precondition: `quiz` must be created by logged user.
     - Precondition:  Logged user must be instructor.
     - Precondition: `percentage` must be a positive number.
     
     - Invariant: `percentage` reference will not change during the execution of this method.

     - Postcondition:
     Quiz percentage will be updated.
     */
    public func updateQuiz() {
        if percentage.value != -1 {
            quiz.percentage = percentage.value
            let endpoint = QuizEndpoint.update(quiz: quiz)
            NetworkManager.shared.requestJSON(endpoint, .quizCreate)
                .subscribe(onNext: { [weak self] (result) in
                    switch result {
                    case .success:
                        self?.success.onNext(())
                    case .failure(let error):
                        self?.failure.onNext(error)
                    }
                }).disposed(by: disposeBag)
        }
    }
    
}
