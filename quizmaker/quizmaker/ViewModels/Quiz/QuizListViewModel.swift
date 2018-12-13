
import RxSwift
import RxCocoa

public class QuizListViewModel {
    
    private let disposeBag = DisposeBag()
    
    var courseID: Int?
    let items: BehaviorRelay<[QuizSectionModel]>
    let success: PublishSubject<Void>
    let failure: PublishSubject<NetworkError>
    let loadPageTrigger: PublishSubject<Void>
    
    init() {
        items = BehaviorRelay(value: [])
        failure = PublishSubject()
        success = PublishSubject()
        loadPageTrigger = PublishSubject()
        
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[QuizSectionModel]> in
                var endpoint: QuizEndpoint = .owner
                if let id = self.courseID {
                    endpoint = QuizEndpoint.course(id: id)
                }
                
                return self.fetch(endpoint)
            }.bind(to: items)
            .disposed(by: disposeBag)
    }
    
    convenience init(courseID: Int) {
        self.init()
        self.courseID = courseID
    }
    
    private func fetch(_ endpoint: QuizEndpoint) -> Observable<[QuizSectionModel]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            NetworkManager.shared.request(endpoint, [Quiz].self)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let object):
                        var sectionModel: [QuizSectionModel] = []
                        object.forEach({ (quiz) in
                            sectionModel.append(.quiz(item: quiz))
                        })
                        
                        observer.onNext(sectionModel)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
    
    func delete(_ quiz: Quiz) {
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
    
    func append(_ quizId: Int) {
        let endpoint = QuizEndpoint.append(quizID: quizId)
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
