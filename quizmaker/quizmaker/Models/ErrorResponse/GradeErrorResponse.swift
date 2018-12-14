
import Foundation

/// :nodoc:
public struct GradeErrorResponse {
    var message: String
    var questionID: Int
    var questionPoint: Int
    var point: Int
}

/// :nodoc:
extension GradeErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
        case questionID = "question_id"
        case questionPoint = "question_point"
        case point
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        questionID = try container.decode(Int.self, forKey: .questionID)
        questionPoint = try container.decode(Int.self, forKey: .questionPoint)
        point = try container.decode(Int.self, forKey: .point)
    }
}
