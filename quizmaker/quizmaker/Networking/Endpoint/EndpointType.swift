
import Foundation

/// An interface to helps endpoints to define BaseURL, path of the url, HTTPMethod, HTTPTask and Header Information of the request.
public protocol EndpointType {
    /**
     Returns a base URL to identify where will be the destination of the request.
     
     - Example: http:\\example.com
     */
    var baseURL: URL { get }
    
    /**
     Returns a path to identify what comes after base URL.
     
     - Example: .com/api/test/
     */
    var path: String { get }
    
    /**
     Returns an HTTP Method that will be used from urlRequest.
     
     - Example: POST, PUT, GET
     
     - SeeAlso:
     `HTTPMethod`
     */
    var httpMethod: HTTPMethod { get }
    
    /**
     A helper that returns which encoding style will be used.
     
     - SeeAlso:
     `ParameterEncoder`
     */
    var task: HTTPTask { get }
    
    /**
     A helper that returns the header informations if any, if not returns nil.
     
     - Example: ['Content-Type': 'application/json']
     
     - SeeAlso:
     `HTTPHeaders`
     */
    var headers: HTTPHeaders? { get }
}
