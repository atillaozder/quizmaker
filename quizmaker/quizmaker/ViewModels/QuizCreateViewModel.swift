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
    let courses: PublishSubject<[Course]>
    
    init() {
        percentage = BehaviorRelay(value: nil)
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
        
        var quizModel = Quiz(name: name.value, start: start, end: end, beGraded: beGraded.value, questions: [], courseID: course.value, percentage: percentage.value, description: desc.value)
        
        if let q = self.quiz {
            quizModel.id = q.id
            updateQuiz(quizModel)
        } else {
            let endpoint = QuizEndpoint.create(quiz: quizModel)
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
                        if strongSelf.questions.value.count > 0 {
                            strongSelf.createQuestions(quizID: id)
                        } else {
                            strongSelf.success.onNext(())
                        }
                    }
                case .failure(let error):
                    strongSelf.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
    
    private func updateQuiz(_ quiz: Quiz) {
        var created: [Question] = []
        var updated: [Question] = []
        var deleted: [Question] = []
        
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
        
        created.forEach { (c) in
            let endpoint = QuestionEndpoint.create(question: c)
            NetworkManager.shared.requestJSON(endpoint)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }).disposed(by: disposeBag)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            updated.forEach { (u) in
                let endpoint = QuestionEndpoint.update(question: u)
                NetworkManager.shared.requestJSON(endpoint)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }).disposed(by: self.disposeBag)
            }
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let endpoint = QuizEndpoint.update(quiz: quiz)
            NetworkManager.shared.requestJSON(endpoint, .quizCreate)
                .flatMap({ [weak self] (result) -> Observable<Void> in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        self?.failure.onNext(error)
                    }
                    return .just(())
                }).subscribe(onNext: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    if deleted.count > 0 {
                        deleted.forEach { (d) in
                            let endpoint = QuestionEndpoint.delete(id: d.id)
                            NetworkManager.shared.requestJSON(endpoint)
                                .subscribe(onNext: { (result) in
                                    switch result {
                                    case .success:
                                        strongSelf.success.onNext(())
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        break
                                    }
                                }).disposed(by: strongSelf.disposeBag)
                        }
                    } else {
                        strongSelf.success.onNext(())
                    }
                }).disposed(by: self.disposeBag)
        }
    }
    
    private func createQuestions(quizID: Int) {
        var qs = questions.value
        var count = 0
        
        for (index, _) in qs.enumerated() {
            qs[index].quizId = quizID
            let endpoint = QuestionEndpoint.create(question: qs[index])
            NetworkManager.shared.requestJSON(endpoint)
                .flatMap({ (result) -> Observable<Int> in
                    count += 1
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                    
                    return .just(count)
                }).subscribe(onNext: { [unowned self] (count) in
                    if count == self.questions.value.count {
                        self.success.onNext(())
                    }
                }).disposed(by: disposeBag)
        }
    }
}