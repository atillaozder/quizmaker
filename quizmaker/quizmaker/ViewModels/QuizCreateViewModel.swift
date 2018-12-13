import Foundation
import RxSwift
import RxCocoa

class QuizCreateViewModel {
    
    private let disposeBag = DisposeBag()
    var currentIndex = 10000
    var quiz: Quiz?
    
    let percentage: BehaviorRelay<Double?>
    let questions: BehaviorRelay<[Question]>
    let questionsBefore: BehaviorRelay<[Question]>
    let name: BehaviorRelay<String>
    let desc: BehaviorRelay<String>
    let start: BehaviorRelay<Date?>
    let end: BehaviorRelay<Date?>
    let beGraded: BehaviorRelay<Bool>
    let course: BehaviorRelay<Int?>
    
    let loadPageTrigger: PublishSubject<Void>
    let createTrigger: PublishSubject<Void>
    let failure: PublishSubject<NetworkError>
    let success: PublishSubject<Void>
    let updated: PublishSubject<Quiz>
    let courses: PublishSubject<[Course]>
    
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
    
    private func fetch() -> Observable<[Course]> {
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
    
    private func create() {
        guard let start = start.value else { return }
        guard let end = end.value else { return }
        
        var model = Quiz(name: name.value, start: start, end: end, beGraded: beGraded.value, questions: [], courseID: course.value, percentage: percentage.value, description: desc.value)
        model.ownerName = UserDefaults.standard.getUsername() ?? ""
        
        if let q = self.quiz {
            model.id = q.id
            updateQuiz(model)
        } else {
            let endpoint = QuizEndpoint.create(quiz: model)
            createQuiz(endpoint)
        }
    }
    
    private func createQuiz(_ endpoint: QuizEndpoint) {
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
    
    let group = DispatchGroup()

    private func updateQuiz(_ quiz: Quiz) {
        var created: [Question] = []
        var updated: [Question] = []
        var deleted: [Question] = []
        
        // Sets the updated and newly created questions
        questions.value.forEach { (q) in
            var copy = q
            copy.quizId = quiz.id
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
    
    private func requestQuestion(_ qs: [Question], index: Int, id: Int) {
        if index == qs.count {
            self.success.onNext(())
            return
        }
        
        var q = qs[index]
        q.quizId = id
        let endpoint = QuestionEndpoint.create(question: q)
        
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (_) in
                self.requestQuestion(qs, index: index + 1, id: id)
            }).disposed(by: disposeBag)
    }
}