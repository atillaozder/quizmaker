

import Foundation

/// A struct that holds register information of the visitor if he/she request to register.
public struct SignUp {
    
    /// Holds identifier of the user.
    var id: Int
    
    /// Holds username of the user.
    var username: String
    
    /// Holds password of the user.
    var password: String
    
    /// Holds first name of the user.
    var firstName: String
    
    /// Holds last name of the user.
    var lastName: String
    
    /// Holds student id of the user.
    var studentId: String?
    
    /// Holds email of the user.
    var email: String
    
    /// Designated to understand the user type of the user.
    var userType: UserType
    
    /// Designated to understand if specified user is admin.
    var isStaff: Bool
    
    /**
     Constructor of the class
     
     - Parameters:
        - username: Username of the user.
        - firstName: First name of the user.
        - lastName: Last name of the user.
        - email: Email of the user.
        - password: Password of the user.
        - userType: The type of the user such as instructor.
        - studentId: If the user type is student, its his school id.
     
     - Precondition: `firstname` must be non-nil.
     - Precondition: `lastname` must be non-nil.
     - Precondition: `password` must be non-nil.
     - Precondition: `userType` must be non-nil.
     - Precondition: `username` must be non-nil.
     - Precondition: `email` must be non-nil.
     
     - Postcondition: An object will be created.
     */
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

/// :nodoc:
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
