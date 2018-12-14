
import Foundation
import RxCocoa
import RxSwift

public class ChangePasswordViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    let oldPassword: BehaviorRelay<String>
    let newPassword: BehaviorRelay<String>
    let confirmPassword: BehaviorRelay<String>
    
    /// :nodoc:
    var success: (() -> Void)?
    
    /// :nodoc:
    var failure: ((NetworkError) -> Void)?
    
    /// :nodoc:
    let changePasswordTrigger: PublishSubject<Void>
    
    init() {
        oldPassword = BehaviorRelay(value: "")
        newPassword = BehaviorRelay(value: "")
        confirmPassword = BehaviorRelay(value: "")
        
        changePasswordTrigger = PublishSubject()
        changePasswordTrigger.asObservable()
            .subscribe(onNext: { [unowned self] () in
                self.changePassword()
            }).disposed(by: disposeBag)
    }
    
    public func changePassword() {
        let model = ChangePassword(old: self.oldPassword.value, new: self.newPassword.value, confirm: self.confirmPassword.value)
        
        let endpoint = UserEndpoint.changePassword(model: model)
        NetworkManager.shared.requestJSON(endpoint, .changePassword)
            .subscribe(onNext: { (result) in
                switch result {
                case .success:
                    UserDefaults.standard.setPassword(password: self.newPassword.value)
                    self.success?()
                case .failure(let error):
                    self.failure?(error)
                }
            }).disposed(by: self.disposeBag)
    }
}
