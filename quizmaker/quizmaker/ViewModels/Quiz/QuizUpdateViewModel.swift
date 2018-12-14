
import Foundation
import RxSwift
import RxCocoa

public class QuizUpdateViewModel {
    
    var quiz: Quiz
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    let percentage: BehaviorRelay<Double>
    
    /// :nodoc:
    let updateTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
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
