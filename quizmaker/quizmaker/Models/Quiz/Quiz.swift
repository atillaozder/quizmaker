
import Foundation

/// A struct that holds quiz informations.
public struct Quiz: Codable {
    
    /// Holds the identifier of the quiz owner.
    let ownerID: Int
    
    /// Holds the identifier of the quiz.
    var id: Int
    
    /// Holds the name of the quiz.
    var name: String
    
    /// Holds the owner name of the quiz.
    var ownerName: String
    
    /// Holds the descriptions of the quiz if any.
    let description: String?
    
    /// Holds the course name of the quiz if any.
    let courseName: String?
    
    /// Holds the start date of the quiz.
    let start: Date
    
    /// Holds the end date of the quiz.
    let end: Date
    
    /// Holds the information about quiz will be graded or not.
    let beGraded: Bool
    
    /// Holds the percentage of the quiz.
    var percentage: Double
    
    /// Holds the information about quiz is private or not.
    let isPrivate: Bool
    
    /// Holds the participants of the quiz.
    let participants: [User]
    
    /// Holds the questions of the quiz.
    var questions: [Question]
    
    /// Holds the course id of the quiz if any.
    let courseID: Int?
    
    /// :nodoc:
    var startStr: String {
        return convertDateString(date: start)
    }
    
    /// :nodoc:
    var endStr: String {
        return convertDateString(date: end)
    }
    
    /**
    Converts given date to string.
     
     - Parameters:
        - date: Date that need to be converted.
     
     - Precondition: `date` must be non-nil.
     - Postcondition: Date will be converted to string.
     - Returns:
        String representation of the date.
     */
    func convertDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: date)
    }
    
    /**
     Constructor of the class
     
     - Parameters:
        - name: Name of the quiz.
        - start: Start date of the quiz.
        - end: End date of the quiz.
        - beGraded: Specify whether quiz will be graded or not.
        - questions: An array of questions.
        - courseID: Course identifier.
        - percentage: Percentage of the quiz.
        - description: Description of the quiz.
     
     - Precondition: `beGraded` must be non-nil.
     - Precondition: `end` must be non-nil.
     - Precondition: `start` must be non-nil.
     - Precondition: `name` must be non-nil.
     - Precondition: `questions` must be non-nil.
     - Precondition: `questions` size must be greater than 0.
     
     - Postcondition: An object will be created.
     */
    init(name: String, start: Date, end: Date, beGraded: Bool, questions: [Question], courseID: Int?, percentage: Double?, description: String?) {
        self.name = name
        self.start = start
        self.end = end
        self.beGraded = beGraded
        self.questions = questions
        self.courseID = courseID
        self.percentage = percentage ?? 1
        self.description = description
        
        self.ownerID = -1
        self.id = -1
        self.courseName = nil
        self.isPrivate = false
        self.participants = []
        self.ownerName = ""
    }
    
    /// :nodoc:
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
        case courseID = "course"
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        ownerID = try container.decode(Int.self, forKey: .ownerID)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        courseName = try container.decodeIfPresent(String.self, forKey: .courseName)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        beGraded = try container.decode(Bool.self, forKey: .beGraded)
        percentage = try container.decode(Double.self, forKey: .percentage)
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
