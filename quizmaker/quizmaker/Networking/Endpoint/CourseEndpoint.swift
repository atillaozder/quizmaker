
import Foundation

/// An endpoint provider to communicate with the API for performing course tasks such as retrieve, create, update or delete.
public enum CourseEndpoint {
    /**
     Requests for retrieving courses which is owned by logged instructor.
     
     - Precondition: Must be called by instructor.
     
     - Postcondition:
     API returns an array that contains courses of the logged instructor.
     */
    case owner
    
    /**
     Requests for retrieving courses which is owned by logged instructor.
     
     - Parameters:
        - courseID: The identifier of the course instance.
        - students: An user array who represents that students who will be added to the course.
     
     - Precondition: Must be called by instructor.
     - Precondition: `students` must be non-nil and the size must be greater than 0.
     - Precondition: `courseID` must be non-nil and greater than 0.
     
     - Postcondition:
     Given students will be added to the course if they are valid.
     */
    case appendStudent(courseID: Int, students: [User])
    
    /**
     Requests for retrieving all courses which contains logged student.
     
     - Precondition: Must be called by student.
     
     - Postcondition:
     API returns either an empty array or an array that contains courses.
     */
    case myLectures
}

/// :nodoc:
extension CourseEndpoint: EndpointType {
    public var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/course/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .owner:
            return "owner"
        case .appendStudent(let courseID, _):
            return "update/\(courseID)"
        case .myLectures:
            return "participator"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .owner, .myLectures:
            return .get
        case .appendStudent:
            return .put
        }
    }
    
    public var task: HTTPTask {
        switch self {
        case .owner, .myLectures:
            return .request
        case .appendStudent(_, let students):
            var arrayOfStudents: [Int] = []
            students.forEach { (student) in
                arrayOfStudents.append(student.id)
            }
            
            let parameters = [
                "students": arrayOfStudents
            ]
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
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
