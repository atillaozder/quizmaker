
import Foundation

/// An endpoint provider to communicate with the API to perform authentication such as login, register or forgot password.
public enum AuthenticationEndpoint {
    /**
     Logs the user into system.
     
     - Parameters:
        - username: The users username.
        - password: The users password.
     
     - Precondition:
        - `username` must be non-nil
        - `password` must be non-nil
     
     */
    case login(username: String, password: String)
    
    /**
     Registers the visitor into system.
     
     - Parameters:
        - user: The user instance.
     
     - Precondition:
        - `user` must be non-nil
     
     - SeeAlso:
        [SignUp](https://example.com)
     */
    case register(user: SignUp)
    
    /**
     Calling this method will request for an email to reset the password.
     
     - Parameters:
        - email: The users email.
     
     - Precondition:
        - `email` must be non-nil
     */
    case forgotPassword(email: String)
}

/// :nodoc:
extension AuthenticationEndpoint: EndpointType {
    public var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/accounts/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .login:
            return "login"
        case .register:
            return "register"
        case .forgotPassword:
            return "reset/password"
        }
    }
    
    public var httpMethod: HTTPMethod {
        return .post
    }
    
    public var task: HTTPTask {
        var parameters: Parameters = [:]
        let additional: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Cache-Control": "no-cache"
        ]
        
        switch self {
        case .register(let user):
            parameters = [
                "username": user.username,
                "password": user.password,
                "first_name": user.firstName,
                "last_name": user.lastName,
                "email": user.email,
                "user_type": user.userType.rawValue
            ]
            
            if let studentId = user.studentId {
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
    
    public var headers: HTTPHeaders? {
        return nil
    }
}
