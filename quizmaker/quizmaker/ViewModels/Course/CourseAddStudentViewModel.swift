
import Foundation
import RxCocoa
import RxSwift

public class CourseAddStudentViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    let students: BehaviorRelay<[User]>
    
    /// :nodoc:
    let filteredStudents: BehaviorRelay<[User]>
    
    /// :nodoc:
    let selectedStudents: BehaviorRelay<[User]>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let appendStudentsTrigger: PublishSubject<Void>
    
    init(courseID: Int) {
        success = PublishSubject()
        failure = PublishSubject()
        loadPageTrigger = PublishSubject()
        appendStudentsTrigger = PublishSubject()
        filteredStudents = BehaviorRelay(value: [])
        students = BehaviorRelay(value: [])
        selectedStudents = BehaviorRelay(value: [])
        
        loadPageTrigger.asObservable()
            .flatMap { [unowned self] (_) -> Observable<[User]> in
                let endpoint = UserEndpoint.students
                return self.fetch(endpoint)
            }.bind(to: students)
            .disposed(by: disposeBag)
        
        appendStudentsTrigger.asObservable()
            .filter { [unowned self] (_) -> Bool in
                return self.selectedStudents.value.count > 0
            }.subscribe(onNext: { [unowned self] (_) in
                let endpoint = CourseEndpoint.appendStudent(courseID: courseID, students: self.selectedStudents.value)
                self.addStudents(endpoint)
            }).disposed(by: disposeBag)
    }
    
    public func fetch(_ endpoint: UserEndpoint) -> Observable<[User]> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            NetworkManager.shared.request(endpoint, [User].self)
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
    
    public func addStudents(_ endpoint: CourseEndpoint) {
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (result) in
                switch result {
                case .success:
                    self.success.onNext(())
                case .failure(let error):
                    self.failure.onNext(error)
                }
            }).disposed(by: self.disposeBag)
    }
    
}
