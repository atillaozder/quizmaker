import Foundation

/**
 A dictionary to specify header information of the request.
 
 - Precondition: Key and value must be both String.
 */
public typealias HTTPHeaders = [String: String]

/**
 A helper that returns which encoding style will be used.
 
 - SeeAlso:
 `ParameterEncoder`
 */
public enum HTTPTask {
    
    /// Default request contains no body parameter and no url parameter
    case request
    
    /**
     Requests with parameter could be both, url or body.
     
     - Parameters:
        - encoding: Specify which encoding strategy will be used.
        - bodyParameters: The body objects that will be put it into url request.
        - urlParameters: The url objects that will be put it into url request.
     
     - Precondition: `encoding` must be non-nil.
     */
    case requestParameters(encoding: ParameterEncoding, bodyParameters: Parameters?, urlParameters: Parameters?)
    
    /**
     Requests with parameter could be both, url or body and also one time additional headers.
     
     - Parameters:
        - encoding: Specify which encoding strategy will be used.
        - bodyParameters: The body objects that will be put it into url request.
        - urlParameters: The url objects that will be put it into url request.
        - additionalHeaders: Contains additional header information before sending url request.
     
     - Precondition: `encoding` must be non-nil.
     */
    case requestParametersAndHeaders(encoding: ParameterEncoding, bodyParameters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
}
