import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request
    case requestParameters(encoding: ParameterEncoding, bodyParameters: Parameters?, urlParameters: Parameters?)
    case requestParametersAndHeaders(encoding: ParameterEncoding, bodyParameters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
}
