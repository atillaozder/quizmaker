
import Foundation

public struct Question: Codable {
    var id: Int
    var question, questionType, answer: String
    var point: Int?
    var quizId: Int?
    
    init() {
        id = 0
        question = ""
        questionType = ""
        answer = ""
        point = nil
        quizId = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, question
        case questionType = "question_type"
        case answer
        case point
    }
}
