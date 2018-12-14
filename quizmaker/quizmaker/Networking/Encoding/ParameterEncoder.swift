
import Foundation

/**
 A dictionary could be used encoding both in url encoding or body encoding.
 */
public typealias Parameters = [String: Any]

/**
 An interface helps the communication between API and the client.
 */
public protocol ParameterEncoder {
    /**
     Encodes the given parameters dictionary to corresponding urlRequest. It does not returns the urlRequest back because it is given as inout parameter which means that modifying the local variable will also modify the passed-in parameters.
     
     - Parameters:
        - urlRequest: An URLRequest instance helps the communication over URLSession.
        - parameters: A dictionary holds body or url objects.
     
     - Throws: `EncoderError`
     
     - Precondition: `urlRequest` must be non-nil.
     - Precondition: `parameters` could be an empty dictionary but must be non-nil.
     
     - Postcondition:
     After completing this method url request will be set with parameters and be ready to communicate with corresponding endpoint in API.
     */
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

/**
 A custom error enumeration helps to identify which error was occuring while encoding function is running.
 */
public enum EncoderError: String, Error {
    
    /// A case that parameters was nil.
    case missingParameters  = "Parameters was nil."
    
    /// A case that something went wrong while trying to encode.
    case encodingFailed     = "Parameter encoding was failed."
    
    /// A case that urlRequest was nil.
    case missingURL         = "URL was nil."
}

/**
 An enumeration for encoding and for preparing urlRequest to be ready to communicate.
 */
public enum ParameterEncoding {
    
    /// For URL Encoding such as .com/api?q='search'
    case urlEncoding
    
    /// For Body JSON Encoding for HTTPMethods post, put, patch etc.
    case bodyEncoding
    
    /// For both URL and Body Encoding
    case bothEncoding
    
    /**
     Encodes the given parameters dictionary to corresponding urlRequest. It does not returns the urlRequest back because it is given as inout parameter which means that modifying the local variable will also modify the passed-in parameters.
     
     - Parameters:
        - urlRequest: An URLRequest instance helps the communication over URLSession.
        - bodyParameters: A dictionary holds body parameters.
        - urlParameters: A dictionary holds url parameters.
     
     - Throws: `EncoderError`
     
     - Precondition: `urlRequest` must be non-nil.
     - Precondition: `bodyParameters` could be an empty dictionary but must be non-nil.
     - Precondition: `urlParameters` could be an empty dictionary but must be non-nil.
     
     - Postcondition:
     After completing this method url request will be set with parameters and be ready to communicate with corresponding endpoint in API.
     */
    public func encode(urlRequest: inout URLRequest, bodyParameters: Parameters?, urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let parameters = urlParameters else { return }
                try UrlParameterEncoder().encode(urlRequest: &urlRequest, with: parameters)
            case .bodyEncoding:
                guard let parameters = bodyParameters else { return }
                try BodyParameterEncoder().encode(urlRequest: &urlRequest, with: parameters)
            case .bothEncoding:
                guard let bodyParams = bodyParameters, let urlParams = urlParameters else { return }
                try UrlParameterEncoder().encode(urlRequest: &urlRequest, with: urlParams)
                try BodyParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParams)
            }
        } catch {
            throw EncoderError.missingParameters
        }
    }
}

