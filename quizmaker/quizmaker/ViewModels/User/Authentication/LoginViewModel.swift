
import Foundation
import RxCocoa
import RxSwift

public class LoginViewModel {
    
    let username: BehaviorRelay<String>
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
    
    init() {
        username = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        
        forgotPasswordTrigger = PublishSubject()
        loginTrigger = PublishSubject()
        
        forgetPassword()
        login()
    }
    
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
