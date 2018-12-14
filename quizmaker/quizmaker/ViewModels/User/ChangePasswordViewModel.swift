
import Foundation
import RxCocoa
import RxSwift

/**
 The ChangePasswordViewModel is a canonical representation of the ChangePasswordView. That is, the ChangePasswordViewModel provides a set of interfaces, each of which represents a UI component in the ChangePasswordView.
 */
public class ChangePasswordViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents a old password that changes over time.
    let oldPassword: BehaviorRelay<String>
    
    /// Represents a new password that changes over time.
    let newPassword: BehaviorRelay<String>
    
    /// Represents a confirm password that changes over time.
    let confirmPassword: BehaviorRelay<String>
    
    /// :nodoc:
    var success: (() -> Void)?
    
    /// :nodoc:
    var failure: ((NetworkError) -> Void)?
    
    /// :nodoc:
    let changePasswordTrigger: PublishSubject<Void>
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscribtions, triggers and subjects will be created.
     */
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
    
    /**
     Fires a change password request to the API.
     
     - Precondition: `oldPassword` must be valid.
     - Precondition: `oldPassword` must be non-nil.
     - Precondition: `newPassword` must be non-nil.
     - Precondition: `confirmPassword` must be non-nil.
     - Precondition: `confirmPassword`must equal to `newPassword`.
     
     - Postcondition:
     API request will be send and after getting response, it will be returned to the controller. If an error occupied, error event will be fired. User will change his password.
     */
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
