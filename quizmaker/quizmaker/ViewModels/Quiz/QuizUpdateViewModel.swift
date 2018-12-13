
import Foundation
import RxSwift
import RxCocoa

public class QuizUpdateViewModel {
    
    var quiz: Quiz
    private let disposeBag = DisposeBag()
    let percentage: BehaviorRelay<Double>
    
    let createTrigger: PublishSubject<Void>
    let failure: PublishSubject<NetworkError>
    let success: PublishSubject<Void>
    
    init(quiz: Quiz) {
        self.quiz = quiz
        percentage = BehaviorRelay(value: -1)
        
        failure = PublishSubject()
        success = PublishSubject()
        createTrigger = PublishSubject()
        
        createTrigger.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.updateQuiz()
            }).disposed(by: disposeBag)
    }
    
    private func updateQuiz() {
        if percentage.value != -1 {
            quiz.percentage = percentage.value.description
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
