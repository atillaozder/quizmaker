
import Foundation

/**
 An enumeration specifies which HTTP method will be used in request.
 */
public enum HTTPMethod: String {
    
    /// GET HTTP Method
    case get    = "GET"
    
    /// POST HTTP Method
    case post   = "POST"
    
    /// PUT HTTP Method
    case put    = "PUT"
    
    /// PATCH HTTP Method
    case patch  = "PATCH"
    
    /// DELETE HTTP Method
    case delete = "DELETE"
}
