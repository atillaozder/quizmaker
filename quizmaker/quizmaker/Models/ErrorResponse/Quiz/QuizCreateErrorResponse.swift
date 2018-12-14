
import Foundation

/// :nodoc:
public struct QuizCreateErrorResponse: Codable {
    let start: [String]?
    let end: [String]?
    let name: [String]?
    let course: [String]?
    let percentage: [String]?
}
