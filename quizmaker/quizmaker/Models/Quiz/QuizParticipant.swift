
import Foundation

public struct QuizParticipant: Codable {
    let id: Int
    let participant: Participant?
    let grade: Int
    let completion: Double
    let finishedIn: String?
    let quiz: Int
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, participant, grade, completion
        case finishedIn = "finished_in"
        case quiz
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        grade = try container.decode(Int.self, forKey: .grade)
        completion = try container.decode(Double.self, forKey: .completion)
        quiz = try container.decode(Int.self, forKey: .quiz)
        finishedIn = try container.decodeIfPresent(String.self, forKey: .finishedIn)
    }
}
