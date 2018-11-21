
import Foundation

public enum QuizEndpoint {
    case course(id: Int)
    case detail(quizID: Int)
    case delete(quizID: Int)
    case participants(quizID: Int)
    case update(quizID: Int)
    case owner
}

extension QuizEndpoint: EndpointType {
    var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/quiz/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .course:
            return ""
        case .delete(let quizID):
            return "delete/\(quizID)"
        case .detail(let quizID):
            return "\(quizID)"
        case .update(let quizID):
            return "update/\(quizID)"
        case .participants:
            return "participants"
        case .owner:
            return "owner"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .course:
            return .get
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
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .course(let id):
            let parameters = [
                "course_id": id
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        case .participants(let quizID):
            let parameters = [
                "quiz_id": quizID
            ]
            
            return .requestParameters(encoding: .urlEncoding, bodyParameters: nil, urlParameters: parameters)
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        guard let username = UserDefaults.standard.getUsername() else { return nil }
        guard let password = UserDefaults.standard.getPassword() else { return nil }
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return ["Authorization": "Basic \(base64LoginString)"]
    }
}
