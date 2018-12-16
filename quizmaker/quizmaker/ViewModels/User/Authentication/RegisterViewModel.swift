
import Foundation
import RxCocoa
import RxSwift

/**
 The RegisterViewModel is a canonical representation of the RegisterView. That is, the RegisterViewModel provides a set of interfaces, each of which represents a UI component in the RegisterView.
 */
public class RegisterViewModel {
    
    /// Represents a username that changes over time.
    let username: BehaviorRelay<String>
    
    /// Represents a password that changes over time.
    let password: BehaviorRelay<String>
    
    /// Represents an email that changes over time.
    let email: BehaviorRelay<String>
    
    /// Represents a first name that changes over time.
    let firstName: BehaviorRelay<String>
    
    /// Represents a user type that changes over time.
    let userType: BehaviorRelay<UserType>
    
    /// Represents a last name that changes over time.
    let lastName: BehaviorRelay<String>
    
    /// Represents a student id that changes over time. Optional
    let studentId: BehaviorRelay<String?>
    
    /**
     Validates `email` by using an email regular expression. Set itself true or not according to that.
     */
    var validEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: email.value)
    }
    
    /// :nodoc:
    var registerSuccess: ((SignUp) -> Void)?
    
    /// :nodoc:
    var error: ((NetworkError) -> Void)?
    
    /// :nodoc:
    let registerTrigger: PublishSubject<Void>
    
    /// :nodoc:
    let disposeBag = DisposeBag()
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init() {
        username = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        email = BehaviorRelay(value: "")
        firstName = BehaviorRelay(value: "")
        lastName = BehaviorRelay(value: "")
        studentId = BehaviorRelay(value: nil)
        userType = BehaviorRelay(value: .normal)
        
        registerTrigger = PublishSubject()
        register()
    }
    
    /**
     Fires a register request to the API.
     
     - Precondition: `username` must be valid.
     - Precondition: `email` must be valid.
     - Precondition: `username` must be non-nil.
     - Precondition: `email` must be non-nil.
     - Precondition: `firstName` must be non-nil.
     - Precondition: `firstName` must contain only characters.
     - Precondition: `lastName` must contain only characters.
     - Precondition: `lastName` must be non-nil.
     - Precondition: `password` must be non-nil.
     - Precondition: `userType` must be non-nil.
     
     - Invariant: `username` reference will not change during the execution of this method.
     - Invariant: `email` reference will not change during the execution of this method.
     - Invariant: `lastName` reference will not change during the execution of this method.
     - Invariant: `firstName` reference will not change during the execution of this method.
     - Invariant: `password` reference will not change during the execution of this method.
     - Invariant: `userType` reference will not change during the execution of this method.

     - Postcondition:
     API request will be send and after getting response, it will be returned to the controller. If an error occupied, error event will be fired. User will register to the system.
     */
    public func register() {
        registerTrigger.asObservable()
            .subscribe(onNext: { [unowned self] () in
                let signUp = SignUp(username: self.username.value, firstName: self.firstName.value, lastName: self.lastName.value, email: self.email.value, password: self.password.value, userType: self.userType.value, studentId: self.studentId.value)
                
                let endpoint = AuthenticationEndpoint.register(user: signUp)
                NetworkManager.shared.request(endpoint, SignUp.self, ErrorType.register)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success(let signUp):
                            self.registerSuccess?(signUp)
                        case .failure(let error):
                            self.error?(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
