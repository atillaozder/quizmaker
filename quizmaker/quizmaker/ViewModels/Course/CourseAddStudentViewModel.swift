
import Foundation
import RxCocoa
import RxSwift

/**
 The CourseAddStudentViewModel is a canonical representation of the CourseAddStudentView. That is, the CourseAddStudentViewModel provides a set of interfaces, each of which represents a UI component in the CourseAddStudentView.
 */
public class CourseAddStudentViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents array of students that changes over time.
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
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - courseID: Identifier of course helps to request to API when we add students to it.
     
     - Precondition: `courseID` must be non-nil and greater than 0.
     
     - Postcondition:
     ViewModel object will be initialized. Subscribtions, triggers and subjects will be created.
     */
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
    
    /**
     Fires an HTTP GET API request to the given endpoint. Response will be converted to observable of needed object.
     
     - Parameters:
        - endpoint: An `EndpointType` instance.
     
     - Precondition: `endpoint` must be non-nil.
     - Postcondition:
     API request will be send and after getting response, it will be returned. If an error occupied, error event will be fired.
     
     - Returns: Observable<[User]>
     */
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
    
    /**
     Adds the `students` to the course.
     
     - Parameters:
        - endpoint: CourseEndpoint instance.
     
     - Precondition: `students` must be non-nil.
     - Precondition: `endpoint` must be non-nil.
     - Precondition: `students` size must be greater than 0.
     - Precondition: `students` must not be in the list of course students.
     
     - Postcondition:
     If the request will be successfully done, `students` will be added to the course.
     */
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
