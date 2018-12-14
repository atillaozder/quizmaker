
import RxSwift
import RxCocoa

/**
 The QuizDetailViewModel is a canonical representation of the QuizDetailView. That is, the QuizDetailViewModel provides a set of interfaces, each of which represents a UI component in the QuizDetailView.
 */
public class QuizDetailViewModel {
    
    /// Holds the quiz instance to display details.
    var quiz: Quiz
    
    /// Represents a value that changes over time.
    let items: BehaviorRelay<[DetailSectionModel]>
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let deleteTrigger: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - quiz: Instance of quiz helps to fetching response.
     
     - Precondition: `quiz` must be non-nil.
     
     - Postcondition:
     ViewModel object will be initialized. Subscribtions, triggers and subjects will be created.
     */
    init(quiz: Quiz) {
        self.quiz = quiz
        
        failure = PublishSubject()
        success = PublishSubject()
        items = BehaviorRelay(value: [])
        
        loadPageTrigger = PublishSubject()
        deleteTrigger = PublishSubject()
        
        deleteTrigger.asObservable()
            .subscribe(onNext: { [unowned self] (_) in
                self.delete()
            }).disposed(by: disposeBag)
        
        loadPageTrigger.asObservable()
            .flatMap { [weak self] (_) -> Observable<[DetailSectionModel]> in
                guard let strongSelf = self else { return .empty() }
                let endpoint = QuizEndpoint.participants(quizID: strongSelf.quiz.id)
                return strongSelf.fetch(endpoint)
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
     
     - Returns: Observable<[ParticipantAnswer]>
     */
    public func fetch(_ endpoint: QuizEndpoint) -> Observable<[DetailSectionModel]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let detailSection = QuizDetailSectionModel.detail(item: strongSelf.quiz)
            let questionSection = QuizDetailSectionModel.questions(item: strongSelf.quiz.questions)
            var sections: [DetailSectionModel] = [
                .detail(item: detailSection),
                ]
            
            NetworkManager.shared.request(endpoint, [QuizParticipant].self)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let participants):
                        
                        let participantSection = QuizDetailSectionModel.participants(item: participants)
                        sections.append(.participants(item: participantSection))
                        sections.append(.questions(item: questionSection))
                        
                        observer.onNext(sections)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                    
                    observer.onCompleted()
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
    
    /// :nodoc:
    func updateQuiz(quiz: Quiz) {
        self.quiz = quiz
        var currentSections = items.value
        currentSections.remove(at: 0)
        currentSections.insert(.detail(item: .detail(item: quiz)), at: 0)
        self.items.accept(currentSections)
    }
    
    /**
     Quiz object in this class will be updated if given quiz is valid. Otherwise update will not done. The goal of this method if the quiz object was updated outside of the controller the detail should have current value.
     
     - Parameters:
        - quiz: Quiz instance.
        - questions: Array of questions.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `questions` must be non-nil
     - Precondition: `quiz` must not be started or must be finished.
     - Precondition: `quiz` must be created by logged user.
     
     - Postcondition:
     Quiz will be updated if given quiz is valid. Otherwise update will not done.
     */
    public func updateQuiz(quiz: Quiz, questions: [Question]) {
        self.quiz = quiz
        var currentSections = items.value
        currentSections.remove(at: 0)
        currentSections.insert(.detail(item: .detail(item: quiz)), at: 0)
        currentSections.remove(at: 2)
        currentSections.insert(.questions(item: .questions(item: questions)), at: 2)
        self.items.accept(currentSections)
    }
    
    /**
     Fires a API request. If the given quiz will found in the system it will be validated. If validation is ok then quiz will be deleted.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` must not be started or must be finished.
     - Precondition: `quiz` must be created by logged user.
     
     - Postcondition:
     If the `quiz` will found in the system it will be validated. If validation is ok then logged user will append to the quiz and feedback event will be fired. Otherwise, error event will fired.
     */
    public func delete() {
        let endpoint = QuizEndpoint.delete(quizID: quiz.id)
        NetworkManager.shared.requestJSON(endpoint, .apiMessage)
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
