
import Foundation

public enum QuestionEndpoint {
    case create(question: Question)
    case update(question: Question)
    case delete(id: Int)
}

extension QuestionEndpoint: EndpointType {
    var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/question/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .create:
            return "create"
        case .update(let q):
            return "update/\(q.id)"
        case .delete(let id):
            return "delete/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .create(let question):
            let parameters: [String: Any] = [
                "question_type": question.questionType,
                "question": question.question,
                "answer": question.answer,
                "quiz_id": question.quizId!,
                "point": question.point!
            ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .update(let question):
            let parameters: [String: Any] = [
                "question_type": question.questionType,
                "question": question.question,
                "answer": question.answer,
                "quiz_id": question.quizId!,
                "point": question.point!
            ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
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
