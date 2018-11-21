
import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum EncoderError: String, Error {
    case missingParameters  = "Parameters was nil."
    case encodingFailed     = "Parameter encoding was failed."
    case missingURL         = "URL was nil."
}

public enum ParameterEncoding {
    case urlEncoding
    case bodyEncoding
    case bothEncoding
    
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

