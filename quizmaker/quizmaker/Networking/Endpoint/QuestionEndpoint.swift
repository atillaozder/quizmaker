
import Foundation

/// An endpoint provider to communicate with the API for performing question tasks such as create, update or delete.
public enum QuestionEndpoint {
    /**
     Performs creation of given question instance.
     
     - Parameters:
        - question: The question instance.
     
     - Precondition:
        - `question` must be non-nil
     
     - Postcondition:
     Given question will be created and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `Question`
     */
    case create(question: Question)
    /**
     Updates the given question.
     
     - Parameters:
        - question: The question instance.
     
     - Precondition:
        - `question` must be non-nil
     
     - Postcondition:
     Given question will be updated and saved if it is valid. Otherwise, API will return HTTP400 Bad Request.
     
     - SeeAlso:
     `Question`
     */
    case update(question: Question)
    /**
     Deletes the question.
     
     - Parameters:
        - id: Identifier of the question.
     
     - Precondition:
        - `id` must be greater than 0
     
     - Postcondition:
     Corresponding question will be deleted if it is found. Otherwise, API will return HTTP400 Bad Request.
     */
    case delete(id: Int)
    /**
     Performs creation of answers for corresponding questions after appending a quiz.
     
     - Parameters:
        - id: Identifier of quiz.
        - finishedIn: The completion time in quiz '5 min'.
        - answers: Array of answer instance.
        - completion: How many questions did participant answer.
     
     - Precondition:
        - `id` must be greater than 0
        - `finishedIn` must be non-nil
        - `completion` must be non-nil
        - `completion` must be greater than 0
     
     - Postcondition:
     Answers for given quiz will be saved and could be monitoring by owner of the quiz or owner of the quiz paper.
     
     - SeeAlso:
     `Answer`
     */
    case answer(id: Int, finishedIn: String, completion: Double, answers: [Answer])
    /**
     Performs validation of quiz questions for participant. It can be only done by instructor who owns the quiz instance.
     
     - Parameters:
        - quizID: Identifier of quiz.
        - userID: Identifier of participant.
        - answers: Array of answer instance.
     
     - Precondition:
        - `quizID` must be greater than 0
        - `userID` must be greater than 0
     
     - Postcondition:
     A grade will be set for corresponding user and quiz will be updated.
     
     - SeeAlso:
     `Answer`
     */
    case validate(quizID: Int, userID: Int, answers: [Answer])
}

/// :nodoc:
extension QuestionEndpoint: EndpointType {
    public var baseURL: URL {
        guard let url = URL(string: "http://127.0.0.1:8000/api/question/") else {
            fatalError("Base URL cannot be configured properly.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .create:
            return "create"
        case .update(let q):
            return "update/\(q.id)"
        case .delete(let id):
            return "delete/\(id)"
        case .answer:
            return "answers/create"
        case .validate:
            return "answers/validate"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        case .answer:
            return .post
        case .validate:
            return .post
        }
    }
    
    public var task: HTTPTask {
        switch self {
        case .create(let question):
            var parameters: [String: Any] = [
                "question_type": question.questionType,
                "question": question.question,
                "answer": question.answer
            ]
            
            if let qID = question.quizId {
                parameters["quiz_id"] = qID
            }
            
            if let point = question.point {
                parameters["point"] = point
            }
            
            if let number = question.questionNumber {
                parameters["question_number"] = number
            }
            
            if let type = QuestionType(rawValue: question.questionType), type == .multichoice {
                if let a = question.A {
                    parameters["A"] = a
                }
                
                if let b = question.B {
                    parameters["B"] = b
                }
                
                if let c = question.C {
                    parameters["C"] = c
                }
                
                if let d = question.D {
                    parameters["D"] = d
                }
            }
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .update(let question):
            var parameters: [String: Any] = [
                "question_type": question.questionType,
                "question": question.question,
                "answer": question.answer
            ]
            
            if let qID = question.quizId {
                parameters["quiz_id"] = qID
            }
            
            if let point = question.point {
                parameters["point"] = point
            }
            
            if let number = question.questionNumber {
                parameters["question_number"] = number
            }
            
            if let type = QuestionType(rawValue: question.questionType), type == .multichoice {
                if let a = question.A {
                    parameters["A"] = a
                }
                
                if let b = question.B {
                    parameters["B"] = b
                }
                
                if let c = question.C {
                    parameters["C"] = c
                }
                
                if let d = question.D {
                    parameters["D"] = d
                }
            }
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .answer(let quizID, let finishedIn, let completion, let answers):
            var dict: [String: Any] = [:]
            var array: [[String: Any]] = []
            
            answers.forEach { (a) in
                dict["answer"] = a.answer
                dict["question_id"] = a.questionID
                array.append(dict)
            }
            
            let parameters: [String: Any] = [
                "quiz_id": quizID,
                "finished_in": finishedIn,
                "completion": completion,
                "answers": array
            ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
        case .validate(let quizID, let userID, let answers):
            var dict: [String: Any] = [:]
            var array: [[String: Any]] = []
            
            answers.forEach { (a) in
                dict["point"] = a.point
                dict["question_id"] = a.questionID
                array.append(dict)
            }
            
            let parameters: [String: Any] = [
                "quiz_id": quizID,
                "participant_id": userID,
                "answers": array
            ]
            
            return .requestParameters(encoding: .bodyEncoding, bodyParameters: parameters, urlParameters: nil)
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
