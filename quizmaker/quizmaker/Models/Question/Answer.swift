
import Foundation

public struct Answer {
    
    var answer: String
    var questionID: Int
    var point: Int
    
    init(answer: String, questionID: Int) {
        self.answer = answer
        self.point = 0
        self.questionID = questionID
    }
    
    init(point: Int, questionID: Int) {
        self.point = point
        self.questionID = questionID
        self.answer = ""
    }
}
