
import Foundation

/// A struct that holds answer informations of participant specific question.
public struct ParticipantAnswer: Codable {
    
    /// Holds the identifier of participant answer.
    let id: Int
    
    /// Holds the specific question.
    let question: Question
    
    /// Holds the answer.
    let answer: String
    
    /// Holds the participant identifier.
    let participantID: Int
    
    /// Holds the answer is correct or not.
    let isCorrect: Bool?
    
    /// Holds the answer is validated or not.
    let isValidated: Bool?
    
    /// Holds the point of answer.
    let point: Int?
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, question, answer
        case participantID = "participant_id"
        case isCorrect = "is_correct"
        case isValidated = "is_validated"
        case point = "point"
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        question = try container.decode(Question.self, forKey: .question)
        answer = try container.decode(String.self, forKey: .answer)
        participantID = try container.decode(Int.self, forKey: .participantID)
        isCorrect = try container.decodeIfPresent(Bool.self, forKey: .isCorrect)
        isValidated = try container.decodeIfPresent(Bool.self, forKey: .isValidated)
        point = try container.decodeIfPresent(Int.self, forKey: .point)
    }
}
