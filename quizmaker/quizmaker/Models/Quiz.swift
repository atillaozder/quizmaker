import Foundation

public struct Quiz: Codable {
    let ownerID: Int
    let id: Int
    let name, ownerName, description: String
    let courseName: String?
    let start, end: Date
    let beGraded: Bool
    let percentage: String
    let isPrivate: Bool
    let participants: [User]
    let questions: [Question]
    
    enum CodingKeys: String, CodingKey {
        case ownerID = "owner_id"
        case id
        case ownerName = "owner_name"
        case courseName = "course_name"
        case description, name, start, end
        case beGraded = "be_graded"
        case percentage
        case isPrivate = "is_private"
        case participants, questions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        ownerID = try container.decode(Int.self, forKey: .ownerID)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        courseName = try container.decodeIfPresent(String.self, forKey: .courseName)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        beGraded = try container.decode(Bool.self, forKey: .beGraded)
        percentage = try container.decode(String.self, forKey: .percentage)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        participants = try container.decode([User].self, forKey: .participants)
        questions = try container.decode([Question].self, forKey: .questions)
        
        let startDateString = try container.decode(String.self, forKey: .start)
        if let date = DateFormatter.iso8601Full.date(from: startDateString) {
            start = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .start,
                                                   in: container,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        
        let endDateString = try container.decode(String.self, forKey: .end)
        if let date = DateFormatter.iso8601Full.date(from: endDateString) {
            end = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .end,
                                                   in: container,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
    }
}