
import Foundation
import RxCocoa
import RxSwift

/**
 The CourseListViewModel is a canonical representation of the CourseListView. That is, the CourseListViewModel provides a set of interfaces, each of which represents a UI component in the CourseListView.
 */
public class CourseListViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents array of course that changes over time.
    let items: BehaviorRelay<[Course]>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscribtions, triggers and subjects will be created.
     */
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
    
    /**
     Fires an HTTP GET API request to the given endpoint. Response will be converted to observable of needed object.
     
     - Postcondition:
     API request will be send and after getting response, it will be returned. If an error occupied, error event will be fired.
     
     - Returns: Observable<[Course]>
     */
    public func fetch() -> Observable<[Course]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let endpoint = CourseEndpoint.owner
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
