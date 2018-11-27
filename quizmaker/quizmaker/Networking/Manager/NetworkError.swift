
import Foundation

public enum ErrorType {
    case api
    case apiMessage
    case login
    case register
    case changePassword
    case editProfile
    case quizCreate
}

public enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}

public enum NetworkError: Error {
    case requestFailed
    case invalidData
    case responseUnsuccessfull
    case shouldLogout
    case shouldRetry
    case client(ClientError)
    case api(response: APIErrorResponse)
    case apiMessage(response: ErrorMessage)
    case auth(AuthAPIError)
    case update(UpdateAPIError)
    case quiz(QuizAPIError)
    
    public enum ClientError: Error {
        case jsonDecodingFailure
        case jsonSerializationFailure
        case jsonCastingFailure
    }
    
    public enum AuthAPIError: Error {
        case login(response: FieldErrorResponse)
        case register(response: RegisterErrorResponse)
    }
    
    public enum QuizAPIError: Error {
        case create(response: QuizCreateErrorResponse)
    }
    
    public enum UpdateAPIError: Error {
        case changePassword(response: ChangePasswordErrorResponse)
        case editProfile(response: EditProfileErrorResponse)
    }
    
    var localizedDescription: String {
        switch self {
        case .invalidData: return "Invalid Data"
        case .requestFailed: return "Request Failed"
        case .responseUnsuccessfull: return "Response Unsuccessfull"
        case .shouldRetry: return "Authorization Failure Should Retry Request"
        case .shouldLogout: return "403 or 401 Error Response Should Logout Immediately"
        case .api(let response): return response.errorDesc
        case .apiMessage(let response): return response.message
        case .quiz(.create): return "Quiz Create Error"
        case .auth(.register): return "Register Request Failed"
        case .auth(.login): return "Login Request Failed"
        case .update(.changePassword): return "Update Password Request Failure"
        case .update(.editProfile): return "Update Profile Request Failure"
        case .client(.jsonDecodingFailure): return "JSON Decoding Failure"
        case .client(.jsonSerializationFailure): return "JSON Serialization Failure"
        case .client(.jsonCastingFailure): return "JSON Casting Failure"
        }
    }
}
