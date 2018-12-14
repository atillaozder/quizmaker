
import Foundation

/// :nodoc:
public struct UrlParameterEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw EncoderError.missingURL }
        
        if !parameters.isEmpty, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)  {
            urlComponents.queryItems = [URLQueryItem]()
            for (k, v) in parameters {
                // let value = "\(v)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let queryItem = URLQueryItem(name: k, value: "\(v)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
}
