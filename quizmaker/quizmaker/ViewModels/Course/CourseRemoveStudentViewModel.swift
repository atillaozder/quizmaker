
import Foundation
import RxSwift
import RxCocoa

public class CourseRemoveStudentViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
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
