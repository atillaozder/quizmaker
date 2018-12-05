import RxSwift
import RxCocoa

class JoinedQuizzesViewModel {
    private let disposeBag = DisposeBag()
    
    let items: BehaviorRelay<[QuizSectionModel]>
    let failure: PublishSubject<NetworkError>
    let loadPageTrigger: PublishSubject<Void>
    
    var waiting: Bool = false
    
    init(waiting: Bool) {
        self.waiting = waiting
        items = BehaviorRelay(value: [])
        failure = PublishSubject()
        loadPageTrigger = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[QuizSectionModel]> in
                let endpoint: QuizEndpoint = waiting ? .participantWaiting : .participantEnd
                return self.fetch(endpoint)
            }.bind(to: items)
            .disposed(by: disposeBag)
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
}