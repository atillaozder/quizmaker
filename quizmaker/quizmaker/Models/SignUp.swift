import Foundation

public struct SignUp {
    var id: Int
    var username: String
    var password: String
    var firstName: String
    var lastName: String
    var studentId: String?
    var email: String
    var userType: UserType
    var isStaff: Bool
    
    init(username: String,
         firstName: String,
         lastName: String,
         email: String,
         password: String,
         userType: UserType,
         studentId: String?) {
        
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.userType = userType
        self.studentId = studentId
        
        self.isStaff = false
        self.id = 0
    }
}

extension SignUp: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case userType = "user_type"
        case studentId = "student_id"
        case email
        case isStaff = "is_staff"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        studentId = try container.decodeIfPresent(String.self, forKey: .studentId)
        isStaff = try container.decode(Bool.self, forKey: .isStaff)
        password = ""
        
        if isStaff {
            self.userType = UserType.admin
        } else {
            let type = try container.decode(String.self, forKey: .userType)
            if let userType = UserType(rawValue: type) {
                self.userType = userType
            } else {
                self.userType = UserType.admin
            }
        }
    }
}