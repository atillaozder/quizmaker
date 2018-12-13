import Foundation
import RxSwift
import RxCocoa

class CourseRemoveStudentsViewModel {
    
    private let disposeBag = DisposeBag()
    let students: BehaviorRelay<[User]>
    let filteredStudents: BehaviorRelay<[User]>

    let success: PublishSubject<Void>
    let failure: PublishSubject<NetworkError>
    let loadPageTrigger: PublishSubject<Void>
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
                    
                    NetworkManager.shared.requestJSON(endpoint)
                        .subscribe(onNext: { (result) in
                            switch result {
                            case .success:
                                strongSelf.students.accept(array)
                                strongSelf.filteredStudents.accept(array)
                                strongSelf.success.onNext(())
                            case .failure(let error):
                                strongSelf.failure.onNext(error)
                            }
                        }).disposed(by: strongSelf.disposeBag)
                } else {
                    strongSelf.failure.onNext(NetworkError.apiMessage(response: ErrorMessage(message: "Student could not found in the course")))
                }
            }).disposed(by: disposeBag)
    }
    
    func removeStudent(id: Int) {
        self.removeStudentTrigger.onNext(id)
    }
}