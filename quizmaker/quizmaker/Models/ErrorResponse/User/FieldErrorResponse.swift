
import Foundation

/// :nodoc:
public struct FieldErrorResponse {
    let fieldError: [String]?
}

/// :nodoc:
extension FieldErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case fieldError = "non_field_errors"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fieldError = try container.decodeIfPresent([String].self, forKey: .fieldError)
    }
}
