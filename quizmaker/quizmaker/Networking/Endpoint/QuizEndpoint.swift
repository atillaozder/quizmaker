
import Foundation

/// An endpoint provider to communicate with the API for performing quiz tasks such as retrieve, create, update or delete.
public enum QuizEndpoint {
    /**
     Requests for retrieving public quizzes.
     
     - Postcondition:
     API returns an array that contains public quizzes.
     */
    case all
    
    /**
     Requests for retrieving quizzes for specific course.
     
     - Parameters:
        - id: The identifier of the course.
     
     - Precondition: Must be called by either instructor or student.
     - Precondition: `id` must be non-nil and greater than 0.
     
     - Postcondition:
     API returns an array that contains quizzes.
     */
    case course(id: Int)
    
    /**
     Requests for retrieving specific quiz.
     
     - Parameters:
        - quizID: The identifier of the quiz.
     
     - Precondition: `quizID` must be non-nil and greater than 0.
     
     - Postcondition:
     API returns the quiz detail.
     */
    case detail(quizID: Int)
    
    /**
     Requests for deleting specific quiz.
     
     - Parameters:
        - quizID: The identifier of the quiz.
     
     - Precondition: Must be called by only the user who owns that quiz.
     - Precondition: `id` must be non-nil and greater than 0.
     
     - Postcondition:
     API will delete the quiz if it is not started or finished. Otherwise, API returns HTTP400 Bad Request.
     */
    case delete(quizID: Int)
    
    /**
     Requests for retrieving participants of the specified quiz.
     
     - Parameters:
        - quizID: The identifier of the quiz.
     
     - Precondition: Must be called by only the user who owns that quiz.
     - Precondition: `id` must be non-nil and greater than 0.
     
     - Postcondition:
     API will returns an array of participants.
     */
    case participants(quizID: Int)
    
    /**
     Performs creation of given quiz instance.
     
     - Parameters:
        - quiz: The quiz instance.
     
     - Precondition: `quiz` must be non-nil
     
     - Postcondition:
     Given quiz will be created and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `Quiz`
     */
    case create(quiz: Quiz)
    
    /**
     Updates the given quiz.
     
     - Parameters:
        - quiz: The quiz instance.
     
     - Precondition: `quiz` must be non-nil
     
     - Postcondition:
     Given quiz will be updated and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `Quiz`
     */
    case update(quiz: Quiz)
    
    /**
     Requests for retrieving quizzes that was created by logged user.
     
     - Postcondition:
     API returns an array of quizzes if user has any. Otherwise, an empty array will be returned.
     */
    case owner
    
    /**
     Requests for retrieving quizzes that was appended earlier and finished.
     
     - Postcondition:
     API returns an array of quizzes.
     */
    case participantEnd
    
    /**
     Requests for retrieving quizzes that was appended earlier and still waiting to be finished.
     
     - Postcondition:
     API returns an array of quizzes.
     */
    case participantWaiting
    
    /**
     Requests for retrieving answers of logged user for specified quiz.
     
     - Parameters:
        - quizID: The identifier of the quiz.
     
     - Precondition: `quizID` must be non-nil and greater than 0.
     - Precondition: `quiz` must be finished.
     
     - Postcondition:
     API returns an array of answers.
     */
    case participantAnswer(quizID: Int)
    
    /**
     Requests for retrieving answers of the specified user for specified quiz.
     
     - Parameters:
        - quizID: The identifier of the quiz.
        - userID: The identifier of the user.
     
     - Precondition: `quizID` must be non-nil and greater than 0.
     - Precondition: `userID` must be non-nil and greater than 0.
     - Precondition: `quiz` must be finished.
     
     - Postcondition:
     API returns an array of answers.
     */
    case ownerParticipantAnswer(quizID: Int, userID: Int)
    
    /**
     Requests for appending a quiz if it is not private and not finished yet.
     
     - Parameters:
        - quizID: The identifier of the quiz.
     
     - Precondition: `quizID` must be non-nil and greater than 0.
     - Precondition: `quiz` must not be finished.
     
     - Postcondition:
     Logged user will append the quiz if it is valid. Otherwise an error will be returned.
     */
    case append(quizID: Int)
}

/// :nodoc:
extension QuizEndpoint: EndpointType {
    public var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/quiz/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .all:
            return ""
        case .course:
            return ""
        case .create:
            return "create"
        case .delete(let quizID):
            return "delete/\(quizID)"
        case .detail(let quizID):
            return "\(quizID)"
        case .update(let quiz):
            return "update/\(quiz.id)"
        case .participants:
            return "participants"
        case .owner:
            return "owner"
        case .participantWaiting:
            return "participator/waiting"
        case .participantEnd:
            return "participator/end"
        case .participantAnswer:
            return "participator/answers"
        case .ownerParticipantAnswer:
            return "owner/answers"
        case .append(let quizID):
            return "append/\(quizID)"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .course:
            return .get
        case .participantAnswer:
            return .get
        case .ownerParticipantAnswer:
            return .get
        case .all:
            return .get
        case .create:
            return .post
        case .detail:
            return .get
        case .owner:
            return .get
        case .delete:
            return .post
        case .update:
            return .put
        case .participants:
            return .get
        case .participantEnd:
            return .get
        case .participantWaiting:
            return .get
        case .append:
            return .put
        }
    }
    
    public var task: HTTPTask {
        switch self {
        case .course(let id):
            let parameters = [
                "course_id": id
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        case .create(let quiz):
            var questions: [Int] = []
            quiz.questions.forEach { (question) in
                questions.append(question.id)
            }
            
            var parameters: [String: Any] = [
                "name": quiz.name,
                "start": quiz.startStr,
                "end": quiz.endStr,
                "be_graded": quiz.beGraded,
                ]
            
            if questions.count > 0 {
                parameters["questions"] = questions
            }
            
            if let desc = quiz.description {
                parameters["description"] = desc
            }
            
            if quiz.beGraded {
                parameters["percentage"] = quiz.percentage
            }
            
            if let course = quiz.courseID {
                parameters["course"] = course
            }
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .update(let quiz):
            var questions: [Int] = []
            quiz.questions.forEach { (question) in
                questions.append(question.id)
            }
            
            var parameters: [String: Any] = [
                "name": quiz.name,
                "start": quiz.startStr,
                "end": quiz.endStr,
                "be_graded": quiz.beGraded,
                ]
            
            if questions.count > 0 {
                parameters["questions"] = questions
            }
            
            if let desc = quiz.description {
                parameters["description"] = desc
            }
            
            if quiz.beGraded {
                parameters["percentage"] = quiz.percentage
            }
            
            if let course = quiz.courseID {
                parameters["course"] = course
            }
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .participants(let quizID):
            let parameters = [
                "quiz_id": quizID
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        case .ownerParticipantAnswer(let quizID, let userID):
            let parameters = [
                "quiz_id": quizID,
                "user_id": userID
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        case .participantAnswer(let quizID):
            let parameters = [
                "quiz_id": quizID
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        default:
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
