
import Foundation

public struct ChangePasswordErrorResponse {
    let oldPassword: [String]?
    let newPassword: [String]?
}

extension ChangePasswordErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case oldPassword = "old_password"
        case newPassword = "new_password"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        oldPassword = try container.decodeIfPresent([String].self, forKey: .oldPassword)
        newPassword = try container.decodeIfPresent([String].self, forKey: .newPassword)
    }
}
