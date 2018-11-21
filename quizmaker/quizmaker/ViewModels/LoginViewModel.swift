import Foundation
import RxCocoa
import RxSwift

class LoginViewModel {
    
    let username: BehaviorRelay<String>
    let password: BehaviorRelay<String>
    
    var forgotPassword: ((String) -> Void)?
    var loginSuccess: ((SignUp) -> Void)?
    var error: ((NetworkError) -> Void)?
    
    let forgotPasswordTrigger: PublishSubject<String>
    let loginTrigger: PublishSubject<Void>
    
    let disposeBag = DisposeBag()
    
    init() {
        username = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        
        forgotPasswordTrigger = PublishSubject()
        loginTrigger = PublishSubject()
        
        subscribeForgotPassword()
        subscribeLogin()
    }
    
    private func subscribeLogin() {
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
    
    private func subscribeForgotPassword() {
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