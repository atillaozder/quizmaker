
import Foundation

public enum AuthenticationEndpoint {
    case login(username: String, password: String)
    case register(signUp: SignUp)
    case forgotPassword(email: String)
}

extension AuthenticationEndpoint: EndpointType {
    var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/accounts/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .register:
            return "register"
        case .forgotPassword:
            return "reset/password"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var task: HTTPTask {
        var parameters: Parameters = [:]
        let additional: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Cache-Control": "no-cache"
        ]
        
        switch self {
        case .register(let signUp):
            parameters = [
                "username": signUp.username,
                "password": signUp.password,
                "first_name": signUp.firstName,
                "last_name": signUp.lastName,
                "email": signUp.email,
                "user_type": signUp.userType.rawValue
            ]
            
            if let studentId = signUp.studentId {
                parameters["student_id"] = studentId
            }
            
        case .login(let username, let password):
            parameters = [
                "username": username,
                "password": password
            ]
        case .forgotPassword(let email):
            parameters["email"] = email
        }
        
        return .requestParametersAndHeaders(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil, additionalHeaders: additional)
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
