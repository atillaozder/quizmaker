
import Foundation

public struct Quiz: Codable {
    let ownerID: Int
    let id: Int
    let name, ownerName: String
    let description: String?
    let courseName: String?
    let start, end: Date
    let beGraded: Bool
    let percentage: String
    let isPrivate: Bool
    let participants: [User]
    let questions: [Question]
    let courseID: Int?
    
    var startStr: String {
        return convertDateString(date: start)
    }
    
    var endStr: String {
        return convertDateString(date: end)
    }
    
    private func convertDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: date)
    }
    
    init(name: String, start: Date, end: Date, beGraded: Bool, questions: [Question], courseID: Int?, percentage: Double?, description: String?) {
        self.name = name
        self.start = start
        self.end = end
        self.beGraded = beGraded
        self.questions = questions
        self.courseID = courseID
        self.percentage = "\(percentage ?? 0)"
        self.description = description
        
        self.ownerID = -1
        self.id = -1
        self.courseName = nil
        self.isPrivate = false
        self.participants = []
        self.ownerName = ""
    }
    
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
        case courseID = "course_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        ownerID = try container.decode(Int.self, forKey: .ownerID)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        courseName = try container.decodeIfPresent(String.self, forKey: .courseName)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        beGraded = try container.decode(Bool.self, forKey: .beGraded)
        percentage = try container.decode(String.self, forKey: .percentage)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        participants = try container.decode([User].self, forKey: .participants)
        questions = try container.decode([Question].self, forKey: .questions)
        courseID = try container.decodeIfPresent(Int.self, forKey: .courseID)
        
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
