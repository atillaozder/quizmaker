import Foundation

struct Question: Codable {
    let id: Int
    let question, questionType, answer: String
    
    enum CodingKeys: String, CodingKey {
        case id, question
        case questionType = "question_type"
        case answer
    }
}