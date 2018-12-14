
import Foundation

public enum UserEndpoint {
    case update(user: EditProfile)
    case changePassword(model: ChangePassword)
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
