
import RxSwift
import RxCocoa

/**
 The EditProfileViewModel is a canonical representation of the EditProfileView. That is, the EditProfileViewModel provides a set of interfaces, each of which represents a UI component in the EditProfileView.
 */
public class EditProfileViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    /// Represents a firstname that changes over time.
    let firstname: BehaviorRelay<String>
    
    /// Represents a lastname that changes over time.
    let lastname: BehaviorRelay<String>
    
    /// Represents an email that changes over time.
    let email: BehaviorRelay<String>
    
    /// Represents a gender that changes over time.
    let gender: BehaviorRelay<Gender>
    
    /// :nodoc:
    let updateTrigger: PublishSubject<Void>
    
    /// :nodoc:
    var success: ((EditProfile) -> Void)?
    
    /// :nodoc:
    var failure: ((NetworkError) -> Void)?
    
    /**
     Validates `email` by using an email regular expression. Set itself true or not according to that.
    */
    var validEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: email.value)
    }
    
    /**
     Constructor of viewmodel. Initializes all attributes, subscriptions, observables etc.
     
     - Postcondition:
     ViewModel object will be initialized. Subscriptions, triggers and subjects will be created.
     */
    init() {
        firstname = BehaviorRelay(value: "")
        lastname = BehaviorRelay(value: "")
        email = BehaviorRelay(value: "")
        gender = BehaviorRelay(value: .unspecified)
        
        updateTrigger = PublishSubject()
        
        updateTrigger.asObservable()
            .subscribe(onNext: { [unowned self] (_) in
                self.update()
            }).disposed(by: disposeBag)
    }
    
    /**
     Fires a update profile request to the API.
     
     - Precondition: `email` must be valid.
     - Precondition: `email` must be non-nil.
     - Precondition: `firstname` must be non-nil.
     - Precondition: `firstname` must contain only characters.
     - Precondition: `lastname` must contain only characters.
     - Precondition: `lastname` must be non-nil.
     - Precondition: `gender` must be non-nil.
     
     - Invariant: `email` reference will not change during the execution of this method.
     - Invariant: `firstname` reference will not change during the execution of this method.
     - Invariant: `lastname` reference will not change during the execution of this method.
     - Invariant: `gender` reference will not change during the execution of this method.

     - Postcondition:
     API request will be send and after getting response, it will be returned to the controller. If an error occupied, error event will be fired. User will update his profile.
     */
    public func update() {
        let user = EditProfile(firstname: self.firstname.value,
                               lastname: self.lastname.value,
                               email: self.email.value,
                               gender: self.gender.value.rawValue)
        
        let endpoint = UserEndpoint.update(user: user)
        
        NetworkManager.shared.request(endpoint, EditProfile.self, .editProfile)
            .subscribe(onNext: { (result) in
                
                switch result {
                case .success(let user):
                    self.success?(user)
                    UserDefaults.standard.setGender(gender: user.gender)
                case .failure(let error):
                    self.failure?(error)
                }
                
            }).disposed(by: self.disposeBag)
    }
}
