
import Foundation

public enum QuizEndpoint {
    case all
    case course(id: Int)
    case detail(quizID: Int)
    case delete(quizID: Int)
    case participants(quizID: Int)
    case create(quiz: Quiz)
    case update(quiz: Quiz)
    case owner
    case participantEnd
    case participantWaiting
    case participantAnswer(quizID: Int)
    case ownerParticipantAnswer(quizID: Int, userID: Int)
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
            return .delete
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
