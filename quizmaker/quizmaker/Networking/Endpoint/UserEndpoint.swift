
import Foundation

/// An endpoint provider to communicate with the API for performing user tasks such as retrieve, create, update or delete.
public enum UserEndpoint {
    
    /**
     Updates the given user.
     
     - Parameters:
        - user: The user instance.
     
     - Precondition: `user` must be non-nil
     
     - Postcondition:
     Given user will be updated and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `EditProfile`
     */
    case update(user: EditProfile)
    
    /**
     Changes the password of logged user.
     
     - Parameters:
        - model: The change password instance that holds old and new password.
     
     - Precondition: `model` must be non-nil
     
     - Postcondition:
     Logged user's password will be changed and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `ChangePassword`
     */
    case changePassword(model: ChangePassword)
    
    /**
     Request for retrieving students who registered into the system.
     
     - Precondition: Must be called by only the instructors.
     
     - Postcondition:
     API returns an array of students if any otherwise, an empty error will return.
     */
    case students
}

/// :nodoc:
extension UserEndpoint: EndpointType {
    public var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/accounts/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .changePassword:
            return "change/password"
        case .update:
            return "update"
        case .students:
            return "students"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .changePassword:
            return .put
        case .update:
            return .put
        case .students:
            return .get
        }
    }
    
    public var task: HTTPTask {
        switch self {
        case .changePassword(let model):
            let parameters = [
                "old_password": model.oldPassword,
                "new_password": model.newPassword,
                "confirm_password": model.confirmPassword,
                ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .update(let user):
            let parameters = [
                "first_name": user.firstName,
                "last_name": user.lastName,
                "email": user.email,
                "gender": user.gender
            ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .students:
            return .request
        }
    }
    
    public var headers: HTTPHeaders? {
        guard let username = UserDefaults.standard.getUsername() else { return nil }
        guard let password = UserDefaults.standard.getPassword() else { return nil }
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return ["Authorization": "Basic \(base64LoginString)"]
    }
}
