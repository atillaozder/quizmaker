
import Foundation

/// A struct that holds answer of the participant.
public struct Answer {
    
    /// Holds the answer.
    var answer: String
    
    /// Holds the question identifier.
    var questionID: Int
    
    /// Holds the point of answer.
    var point: Int?
    
    /**
     Constructor of the class.
     
     - Postcondition: An object will be created.
     */
    init() {
        answer = ""
        questionID = -1
        point = nil
    }
    
    /**
     Constructor of the class
     
     - Parameters:
        - answer: Answer of the question.
        - questionID: Defines corresponding question of the answer.
     
     - Precondition: `questionID` must be non-nil.
     
     - Postcondition: An object will be created.
     */
    init(answer: String, questionID: Int) {
        self.answer = answer
        self.point = nil
        self.questionID = questionID
    }
    
    /**
     Constructor of the class
     
     - Parameters:
         - point: How many point gained by this answer.
         - questionID: Defines corresponding question of the answer.
     
     - Precondition: `point` must be non-nil.
     - Precondition: `questionID` must be non-nil.
     - Precondition: `point` must be positive number.
     
     - Postcondition: An object will be created.
     */
    init(point: Int?, questionID: Int) {
        self.point = point
        self.questionID = questionID
        self.answer = ""
    }
}
