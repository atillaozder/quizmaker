
import Foundation

/// :nodoc:
public enum ErrorType {
    case api
    case apiMessage
    case login
    case register
    case changePassword
    case editProfile
    case quizCreate
    case answerValidate
}

/**
 Result of the API Request. If response status code is in between 199 and 300 success case will be used otherwise failure case will be used.
 */
public enum Result<T, U> where U: Error {
    /**
     Represents request was successfull.
     
     - Parameters: `T` a generic response. Could be JSON or any object.
     */
    case success(T)
    
    /**
     Represents request was fail.
     
     - Parameters: `U` a generic response where must be an instance of Error class.
     */
    case failure(U)
}

/**
 Custom error enumeration used in API calls inherits from Swift.Error class.
 */
public enum NetworkError: Error {
    
    /// Request was failed.
    case requestFailed
    
    /// Data from API was invalid.
    case invalidData
    
    /// Response was unsuccessfull.
    case responseUnsuccessfull
    
    /// Logged user should logs out immediately.
    case shouldLogout
    
    /// An error occupied request should retry.
    case shouldRetry
    
    /// :nodoc:
    case client(ClientError)
    
    /// :nodoc:
    case api(response: APIErrorResponse)
    
    /// :nodoc:
    case apiMessage(response: ErrorMessage)
    
    /// :nodoc:
    case auth(AuthAPIError)
    
    /// :nodoc:
    case update(UpdateAPIError)
    
    /// :nodoc:
    case quiz(QuizAPIError)
    
    /// Indicates an error occupied from the client side.
    public enum ClientError: Error {
        
        /// Data could not be decoded into the Codable object.
        case jsonDecodingFailure
        
        /// Response did not serialize into JSON.
        case jsonSerializationFailure
        
        /// Casting from JSON object was fail.
        case jsonCastingFailure
    }
    
    /// Custom authentication error response.
    public enum AuthAPIError: Error {
        
        /**
         Login request was fail.
         - Parameters:
            - response: login error response.
         */
        case login(response: FieldErrorResponse)
        
        /**
         Register request was fail.
         - Parameters:
            - response: register error response.
         */
        case register(response: RegisterErrorResponse)
    }
    
    /// Custom quiz error response
    public enum QuizAPIError: Error {
        /**
         Create quiz request was fail.
         - Parameters:
            - response: create quiz error response.
         */
        case create(response: QuizCreateErrorResponse)
        
        /**
         Validate quiz answers request was fail.
         - Parameters:
            - response: validate quiz error response.
         */
        case validate(response: GradeErrorResponse)
    }
    
    /// Custom update user error response.
    public enum UpdateAPIError: Error {
        
        /**
         Change password request was fail.
         - Parameters:
            - response: change password error response.
         */
        case changePassword(response: ChangePasswordErrorResponse)
        
        /**
         Edit profile request was fail.
         - Parameters:
            - response: edit profile error response.
         */
        case editProfile(response: EditProfileErrorResponse)
    }
    
    /// :nodoc:
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
        case .quiz(.validate): return "Quiz Validate Error"
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
