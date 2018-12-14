
import RxSwift
import RxCocoa

public class EditProfileViewModel {
    
    /// :nodoc:
    private let disposeBag = DisposeBag()
    
    let firstname: BehaviorRelay<String>
    let lastname: BehaviorRelay<String>
    let email: BehaviorRelay<String>
    let gender: BehaviorRelay<Gender>
    
    /// :nodoc:
    let updateTrigger: PublishSubject<Void>
    
    /// :nodoc:
    var success: ((EditProfile) -> Void)?
    
    /// :nodoc:
    var failure: ((NetworkError) -> Void)?
    
    var validEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: email.value)
    }
    
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
                case .failure(let error):
                    self.failure?(error)
                }
                
            }).disposed(by: self.disposeBag)
    }
}
