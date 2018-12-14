
import Foundation

/// A struct that holds quiz participant extra informations.
public struct QuizParticipant: Codable {
    
    /// Holds the identifier of the participant.
    let id: Int
    
    /// Holds the participant informations.
    /// - SeeAlso:
    /// `Participant`
    let participant: Participant?
    
    /// Holds the grade of the participant for quiz.
    let grade: Int
    
    /// Holds the completion of the participant for quiz.
    let completion: Double
    
    /// Holds the time completion of the participant for quiz.
    let finishedIn: String?
    
    /// Holds the quiz that was appended by this participant.
    let quiz: Int
    
    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case id, participant, grade, completion
        case finishedIn = "finished_in"
        case quiz
    }
    
    /// :nodoc:
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
