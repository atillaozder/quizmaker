import Foundation
import RxCocoa
import RxSwift

class MyLecturesViewModel {
    
    private let disposeBag = DisposeBag()
    let items: BehaviorRelay<[Course]>
    let failure: PublishSubject<NetworkError>
    let loadPageTrigger: PublishSubject<Void>
    
    init() {
        items = BehaviorRelay(value: [])
        failure = PublishSubject()
        loadPageTrigger = PublishSubject()
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[Course]> in
                return self.fetch()
            }.bind(to: items)
            .disposed(by: disposeBag)
    }
    
    private func fetch() -> Observable<[Course]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let endpoint = CourseEndpoint.myLectures
            NetworkManager.shared.request(endpoint, [Course].self, .apiMessage)
                .subscribe(onNext: { (result) in
                    switch result {
                    case .success(let object):
                        observer.onNext(object)
                    case .failure(let error):
                        strongSelf.failure.onNext(error)
                    }
                    
                    observer.onCompleted()
                }).disposed(by: strongSelf.disposeBag)
            return Disposables.create()
        })
    }
}