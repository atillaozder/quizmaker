
import Foundation
import RxCocoa
import RxSwift

/**
 The LoginViewModel is a canonical representation of the LoginView. That is, the LoginViewModel provides a set of interfaces, each of which represents a UI component in the LoginView.
 */
public class LoginViewModel {
    
    /// Represents a username that changes over time.
    let username: BehaviorRelay<String>
    
    /// Represents a password that changes over time.
    let password: BehaviorRelay<String>
    
    /// :nodoc:
    var forgotPassword: ((String) -> Void)?
    
    /// :nodoc:
    var loginSuccess: ((SignUp) -> Void)?
    
    /// :nodoc:
    var error: ((NetworkError) -> Void)?
    
    /// :nodoc:
    let forgotPasswordTrigger: PublishSubject<String>
    
    /// :nodoc:
    let loginTrigger: PublishSubject<Void>
    
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
        
        forgotPasswordTrigger = PublishSubject()
        loginTrigger = PublishSubject()
        
        forgetPassword()
        login()
    }
    
    /**
     Fires a login request to the API.
     
     - Precondition: `username` must be non-nil.
     - Precondition: `password` must be non-nil.

     - Invariant: `username` reference will not change during the execution of this method.
     - Invariant: `password` reference will not change during the execution of this method.

     - Postcondition:
     API request will be send and after getting response, it will be returned to the controller. If an error occupied, error event will be fired. User will log into the system.
     */
    public func login() {
        loginTrigger.asObservable()
            .subscribe(onNext: { [unowned self] () in
                let endpoint = AuthenticationEndpoint.login(username: self.username.value, password: self.password.value)
                NetworkManager.shared.request(endpoint, SignUp.self, ErrorType.login)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success(let signUp):
                            self.loginSuccess?(signUp)
                            UserDefaults.standard.setPassword(password: self.password.value)
                        case .failure(let error):
                            self.error?(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    /**
     Fires a forget password request to the API.
     
     - Precondition: email must be defined by user.
     - Precondition: email must be valid.
     - Precondition: email must be non-nil.
     
     - Invariant: `email` reference will not change during the execution of this method.

     - Postcondition:
     API request will be send and after getting response, it will be returned to the controller. If an error occupied, error event will be fired. User gets an email that contains a link to reset password.
     */
    public func forgetPassword() {
        forgotPasswordTrigger.asObservable()
            .subscribe(onNext: { [unowned self] (email) in
                let endpoint = AuthenticationEndpoint.forgotPassword(email: email)
                NetworkManager.shared.requestJSON(endpoint)
                    .subscribe(onNext: { (result) in
                        switch result {
                        case .success(let json):
                            if let message = json["message"] as? String {
                                self.forgotPassword?(message)
                            }
                        case .failure(let error):
                            self.error?(error)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
