
import Foundation
import RxCocoa
import RxSwift

public class CourseAddStudentViewModel {
    
    private let disposeBag = DisposeBag()
    let students: BehaviorRelay<[User]>
    let filteredStudents: BehaviorRelay<[User]>
    let selectedStudents: BehaviorRelay<[User]>
    let success: PublishSubject<Void>
    let failure: PublishSubject<NetworkError>
    let loadPageTrigger: PublishSubject<Void>
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
                NetworkManager.shared.requestJSON(endpoint)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success:
                            self.success.onNext(())
                        case .failure(let error):
                            self.failure.onNext(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    private func fetch(_ endpoint: UserEndpoint) -> Observable<[User]> {
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
    
}
