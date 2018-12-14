
import Foundation

/**
 A struct will be mapped to API error response.
 */
public struct ErrorMessage {
    
    /**
     A message that holds the error response.
     */
    var message: String
    
    /**
     Constructor of the class
     
     - Parameters:
        - message: Hold the description of the error.
     
     - Precondition: `message` must be non-nil.
     
     - Postcondition: An object will be created.
     */
    init(message: String) {
        self.message = message
    }
}

/// :nodoc:
extension ErrorMessage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
}
