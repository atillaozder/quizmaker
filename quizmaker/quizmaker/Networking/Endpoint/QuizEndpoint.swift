
import Foundation

public enum QuizEndpoint {
    case course(id: Int)
    case detail(quizID: Int)
    case delete(quizID: Int)
    case participants(quizID: Int)
    case create(quiz: Quiz)
    case update(quiz: Quiz)
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
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .course:
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
        }
    }
    
    var task: HTTPTask {
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
            
            if quiz.beGraded, let perc = Double(quiz.percentage) {
                parameters["percentage"] = perc
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
            
            if quiz.beGraded, let perc = Double(quiz.percentage) {
                parameters["percentage"] = perc
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
