
import RxCocoa
import RxSwift
import Foundation

/// :nodoc:
protocol AnswerDelegate: class {
    func setAnswer(_ answer: Answer)
}

/**
 The AnswerQuestionsViewModel is a canonical representation of the QuestionListView. That is, the AnswerQuestionsViewModel provides a set of interfaces, each of which represents a UI component in the QuestionListView.
 */
public class AnswerQuestionsViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents the quiz identifier.
    let quizID: Int
    
    /// Holds the user's answers.
    var answers: [Answer]
    
    /// Represents array of questions.
    let questions: BehaviorRelay<[Question]>
    
    /// :nodoc:
    let items: BehaviorRelay<[QuestionDetailSectionModel]>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - quiz: Instance of quiz helps to get questions and show them.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` start date must be smaller than end date.
     - Precondition: `quiz` start date must be bigger than today's date.
     - Precondition: `quiz.id` must be greater than 0.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    public init(quiz: Quiz) {
        self.quizID = quiz.id
        self.answers = []
        self.questions = BehaviorRelay(value: quiz.questions)
        
        var sections: [QuestionDetailSectionModel] = []
        quiz.questions.forEach { (q) in
            if let type = QuestionType(rawValue: q.questionType) {
                switch type {
                case .multichoice:
                    sections.append(.multichoice(item: .multichoice(item: q)))
                case .text:
                    sections.append(.text(item: .text(item: q)))
                case .truefalse:
                    sections.append(.truefalse(item: .truefalse(item: q)))
                }
            }
        }
        
        self.items = BehaviorRelay(value: sections)
        self.success = PublishSubject()
        self.failure = PublishSubject()
    }
    
    /**
     Append given answer to the participant answer array.
     
     - Parameters:
        - answer: The participant answer.
     
     - Precondition: `answer` must be non-nil.
     - Precondition: `answer.questionID` must be non-nil.
     - Precondition: quiz must not be ended.
     
     - Invariant: `answers` reference will change during the execution of this method.
     
     - Postcondition:
     Participant's answer will be added to the `answers` array if it is not in the array, otherwise it will be changed.
     */
    func setAnswer(_ answer: Answer) {
        if answers.contains(where: { $0.questionID == answer.questionID }) {
            for (index, a) in answers.enumerated() {
                if a.questionID == answer.questionID {
                    if !answer.answer.isEmpty {
                        answers[index].answer = answer.answer
                    }
                }
            }
        } else {
            answers.append(answer)
        }
    }
    
    /**
     Performs creation of answers for the participant. It sends the current answer to the server and save them to validate later.
     
     - Parameters:
        - time: How much time did user spend on this quiz.
     
     - Precondition: time must be non-nil.
     - Precondition: time must not contains special characters.
     - Precondition: time must be positive.
     - Precondition: quiz must not be ended.
     
     - Invariant: `answers` reference will not change during the execution of this method.
     
     - Postcondition:
     Participant's answers will be saved.
     */
    func sendAnswers(time: String) {
        questions.value.forEach { (q) in
            if !answers.contains(where: { $0.questionID == q.id }) {
                answers.append(Answer(answer: "", questionID: q.id))
            }
        }
        
        let endpoint = QuestionEndpoint.answer(id: quizID, finishedIn: time, answers: answers)
        NetworkManager.shared.requestJSON(endpoint)
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
     If and only if called when the quiz is finished while user trying to answer some questions. It takes the current answers of the participant, freeze the system for a while then performs creation of answers for the participant. It sends the current answer to the server and save them to validate later.
     
     - Parameters:
        - time: How much time did user spend on this quiz.
     
     - Precondition: time must be non-nil.
     - Precondition: time must not contains special characters.
     - Precondition: time must be positive.
     - Precondition: quiz must be ended so that methods can be called by the system.
     
     - Invariant: `answers` reference will not change during the execution of this method.
     
     - Postcondition:
     Participant's answers will be saved. System will be available again.
     */
    func timeIsUp(time: String) {
        questions.value.forEach { (q) in
            if !answers.contains(where: { $0.questionID == q.id }) {
                answers.append(Answer(answer: "", questionID: q.id))
            }
        }
        
        let endpoint = QuestionEndpoint.answer(id: quizID, finishedIn: time, answers: answers)
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe().disposed(by: disposeBag)
    }
}
