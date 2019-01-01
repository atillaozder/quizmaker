
import Foundation
import RxSwift
import RxCocoa

/**
 The QuizCreateViewModel is a canonical representation of the QuizCreateView. That is, the QuizCreateViewModel provides a set of interfaces, each of which represents a UI component in the QuizCreateView.
 */
public class QuizCreateViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// :nodoc:
    var currentIndex = 10000
    
    /// :nodoc:
    var quiz: Quiz?
    
    /// :nodoc:
    let group = DispatchGroup()
    
    /// Represents a quiz name that changes over time.
    let name: BehaviorRelay<String>
    
    /// Represents a description that changes over time.
    let desc: BehaviorRelay<String>
    
    /// Represents a start date that changes over time.
    let start: BehaviorRelay<Date?>
    
    /// Represents an end date that changes over time.
    let end: BehaviorRelay<Date?>
    
    /// Represents is graded or not that changes over time.
    let beGraded: BehaviorRelay<Bool>
    
    /// Represents a course identifier that changes over time.
    let course: BehaviorRelay<Int?>
    
    /// Represents a percentage that changes over time.
    let percentage: BehaviorRelay<Double?>
    
    /// Represents array of questions that changes over time.
    let questions: BehaviorRelay<[Question]>
    
    /// :nodoc:
    let questionsBefore: BehaviorRelay<[Question]>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let createTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /// :nodoc:
    let updated: PublishSubject<Quiz>
    
    /// :nodoc:
    let courses: PublishSubject<[Course]>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init() {
        percentage = BehaviorRelay(value: nil)
        updated = PublishSubject()
        name = BehaviorRelay(value: "")
        desc = BehaviorRelay(value: "")
        start = BehaviorRelay(value: nil)
        end = BehaviorRelay(value: nil)
        course = BehaviorRelay(value: nil)
        beGraded = BehaviorRelay(value: false)
        questions = BehaviorRelay(value: [])
        questionsBefore = BehaviorRelay(value: [])
        
        failure = PublishSubject()
        success = PublishSubject()
        courses = PublishSubject()
        loadPageTrigger = PublishSubject()
        createTrigger = PublishSubject()
        
        if UserDefaults.standard.getUserType() == UserType.instructor.rawValue {
            loadPageTrigger.asObservable()
                .flatMap { (_) -> Observable<[Course]> in
                    return self.fetch()
                }.bind(to: courses)
                .disposed(by: disposeBag)
        }
        
        createTrigger.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.create()
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    convenience init(quiz: Quiz) {
        self.init()
        self.quiz = quiz
        
        self.beGraded.accept(quiz.beGraded)
        self.name.accept(quiz.name)
        if let desc = quiz.description {
            self.desc.accept(desc)
        }
        
        self.start.accept(quiz.start)
        self.end.accept(quiz.end)
        self.course.accept(quiz.courseID)
        self.percentage.accept(Double(quiz.percentage))
        self.questions.accept(quiz.questions)
        self.questionsBefore.accept(quiz.questions)
    }
    
    /**
     Fires an HTTP GET API request to the given endpoint. Response will be converted to observable of needed object.
     
     - Postcondition:
     API request will be send and after getting response, it will be returned. If an error occupied, error event will be fired.
     
     - Returns: Observable<[Course]>
     */
    public func fetch() -> Observable<[Course]> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let endpoint = CourseEndpoint.owner
            NetworkManager.shared.request(endpoint, [Course].self, .apiMessage)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let courses):
                        observer.onNext(courses)
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                    
                    observer.onCompleted()
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        }
    }
    
    /// :nodoc:
    private func create() {
        guard let start = start.value else { return }
        guard let end = end.value else { return }
        
        var model = Quiz(name: name.value, start: start, end: end, beGraded: beGraded.value, questions: [], courseID: course.value, percentage: percentage.value, description: desc.value)
        model.ownerName = UserDefaults.standard.getUsername() ?? ""
        
        if let q = self.quiz {
            model.id = q.id
            update(model)
        } else {
            let endpoint = QuizEndpoint.create(quiz: model)
            create(endpoint)
        }
    }
    
    /**
     Performs creation of the quiz if validations are ok.
     
     - Parameters:
        - endpoint: QuizEndpoint instance.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` name must not contains special characters.
     - Precondition: `quiz` start date must be smaller than end date.
     - Precondition: `quiz` start date must be bigger than today's date.
     - Precondition: If logged user is instructor `quiz` course must be non-nil.
     - Precondition: `quiz` percentage must be greater than or equal to 0.
     
     - Invariant: `name` reference will not change during the execution of this method.
     - Invariant: `desc` reference will not change during the execution of this method.
     - Invariant: `start` reference will not change during the execution of this method.
     - Invariant: `end` reference will not change during the execution of this method.
     - Invariant: `beGraded` reference will not change during the execution of this method.
     - Invariant: `percentage` reference will not change during the execution of this method.
     - Invariant: `questions` reference will not change during the execution of this method.
     - Invariant: `courseID` reference will not change during the execution of this method.

     - Postcondition:
     Quiz will be created if the request will be successfull.
     */
    public func create(_ endpoint: QuizEndpoint) {
        NetworkManager.shared.requestJSON(endpoint, .quizCreate)
            .subscribe(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let JSON):
                    if let id = JSON["id"] as? Int {
                        let qs = strongSelf.questions.value
                        if qs.count > 0 {
                            strongSelf.requestQuestion(qs, index: 0, id: id)
                        } else {
                            strongSelf.success.onNext(())
                        }
                    }
                case .failure(let error):
                    strongSelf.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
    
    /**
     Updates the given quiz if validations are ok.
     
     - Parameters:
        - quiz: Quiz instance that will be updated.
     
     - Precondition: `quiz` must be non-nil.
     - Precondition: `quiz` name must not contains special characters.
     - Precondition: `quiz` must not be started.
     - Precondition: `quiz` start date must be smaller than end date.
     - Precondition: `quiz` start date must be bigger than today's date.
     - Precondition: If logged user is instructor `quiz` course must be non-nil.
     - Precondition: `quiz` percentage must be greater than or equal to 0.

     - Invariant: 'quiz' reference will change during the execution of this method.

     - Postcondition:
     Quiz will be updated if the request will be successfull.
     */
    public func update(_ quiz: Quiz) {
        var created: [Question] = []
        var updated: [Question] = []
        var deleted: [Question] = []
        
        // Sets the updated and newly created questions
        questions.value.enumerated().forEach { (offset, q) in
            var copy = q
            copy.quizId = quiz.id
            copy.questionNumber = offset + 1
            if !questionsBefore.value.contains(where: { $0.id == q.id }) {
                created.append(copy)
            } else {
                updated.append(copy)
            }
        }
        
        questionsBefore.value.forEach { (q) in
            if !questions.value.contains(where: { $0.id == q.id }) {
                deleted.append(q)
            }
        }
        
        group.enter()
        requestQuestion(created, index: 0)
        
        group.notify(queue: .main) {
            self.group.enter()
            self.requestUpdateQuestion(updated, index: 0)
            
            self.group.notify(queue: .main, execute: {
                self.group.enter()
                self.requestDeleteQuestion(deleted, index: 0)
                
                self.group.notify(queue: .main, execute: {
                    self.requestQuiz(quiz)
                })
            })
        }
    }
    
    /// :nodoc:
    private func requestQuiz(_ q: Quiz) {
        let endpoint = QuizEndpoint.update(quiz: q)
        NetworkManager.shared.requestJSON(endpoint, .quizCreate)
            .subscribe(onNext: { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success:
                    strongSelf.success.onNext(())
                    var mutableCopy = q
                    mutableCopy.questions = strongSelf.questions.value
                    strongSelf.updated.onNext(mutableCopy)
                case .failure(let error):
                    strongSelf.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    private func requestQuestion(_ qs: [Question], index: Int) {
        if index == qs.count {
            group.leave()
            return
        }
        
        let endpoint = QuestionEndpoint.create(question: qs[index])
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (_) in
                self.requestQuestion(qs, index: index + 1)
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    private func requestUpdateQuestion(_ qs: [Question], index: Int) {
        if index == qs.count {
            group.leave()
            return
        }
        
        let endpoint = QuestionEndpoint.update(question: qs[index])
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (_) in
                self.requestUpdateQuestion(qs, index: index + 1)
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    private func requestDeleteQuestion(_ qs: [Question], index: Int) {
        if index == qs.count {
            group.leave()
            return
        }
        
        let endpoint = QuestionEndpoint.delete(id: qs[index].id)
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (_) in
                self.requestDeleteQuestion(qs, index: index + 1)
            }).disposed(by: disposeBag)
    }
    
    /// :nodoc:
    private func requestQuestion(_ qs: [Question], index: Int, id: Int) {
        if index == qs.count {
            self.success.onNext(())
            return
        }
        
        var q = qs[index]
        q.quizId = id
        q.questionNumber = index + 1
        let endpoint = QuestionEndpoint.create(question: q)
        
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (_) in
                self.requestQuestion(qs, index: index + 1, id: id)
            }).disposed(by: disposeBag)
    }
}
