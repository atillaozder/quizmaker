
import Foundation

public enum CourseEndpoint {
    case owner
    case appendStudent(courseID: Int, students: [User])
}

extension CourseEndpoint: EndpointType {
    var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/course/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .owner:
            return "owner"
        case .appendStudent(let courseID, _):
            return "update/\(courseID)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .owner:
            return .get
        case .appendStudent:
            return .put
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .owner:
            return .request
        case .appendStudent(_, let students):
            var arrayOfStudents: [[String: Int]] = []
            students.forEach { (student) in
                arrayOfStudents.append(["id": student.id])
            }
            
            let parameters = [
                "students": arrayOfStudents
            ]
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
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