
import Foundation
import RxSwift
import RxCocoa

/**
 The CourseRemoveStudentViewModel is a canonical representation of the CourseRemoveStudentView. That is, the CourseRemoveStudentViewModel provides a set of interfaces, each of which represents a UI component in the CourseRemoveStudentView.
 */
public class CourseRemoveStudentViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents array of students that changes over time.
    let students: BehaviorRelay<[User]>
    
    /// :nodoc:
    let filteredStudents: BehaviorRelay<[User]>
    
    /// :nodoc:
    let success: PublishSubject<Void>
    
    /// :nodoc:
    let failure: PublishSubject<NetworkError>
    
    /// :nodoc:
    let loadPageTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let removeStudentTrigger: PublishSubject<Int>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Parameters:
        - course: Instance of course helps to request to API when we remove students from it.
     
     - Precondition: `course` must be non-nil.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init(course: Course) {
        self.students = BehaviorRelay(value: course.students)
        success = PublishSubject()
        failure = PublishSubject()
        loadPageTrigger = PublishSubject()
        removeStudentTrigger = PublishSubject()
        filteredStudents = BehaviorRelay(value: [])
        
        removeStudentTrigger.asObservable()
            .subscribe(onNext: { [weak self] (id) in
                guard let strongSelf = self else { return }
                var array = strongSelf.students.value
                var index = -1
                array.enumerated().forEach({ (offset, element) in
                    if element.id == id {
                        index = offset
                    }
                })
                
                if index != -1 {
                    array.remove(at: index)
                    let endpoint = CourseEndpoint.appendStudent(courseID: course.id, students: array)
                    strongSelf.removeStudent(endpoint, students: array)
                } else {
                    strongSelf.failure.onNext(NetworkError.apiMessage(response: ErrorMessage(message: "Student could not found in the course")))
                }
            }).disposed(by: disposeBag)
    }
    
    /**
     Removes the given students from the course.
     
     - Parameters:
        - endpoint: CourseEndpoint instance.
        - students: An array of students.
     
     - Precondition: `students` must be non-nil.
     - Precondition: `endpoint` must be non-nil.
     - Precondition: `students` size must be greater than 0.
     - Precondition: `students` must be in the list of course students.

     - Invariant: `students` reference will not change during the execution of this method.

     - Postcondition:
     If the request will be successfully done, given students will be removed from the course.
     */
    func removeStudent(_ endpoint: CourseEndpoint, students: [User]) {
        NetworkManager.shared.requestJSON(endpoint)
            .subscribe(onNext: { (result) in
                switch result {
                case .success:
                    self.students.accept(students)
                    self.filteredStudents.accept(students)
                    self.success.onNext(())
                case .failure(let error):
                    self.failure.onNext(error)
                }
            }).disposed(by: disposeBag)
    }
}
