
import Foundation

/// :nodoc:
extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}

/// :nodoc:
public struct BodyParameterEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            
            let contentType = urlRequest.value(forHTTPHeaderField: "Content-Type")
            
            if contentType == "application/json" {
                
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                urlRequest.httpBody = data
                
            } else if contentType == "application/x-www-form-urlencoded" {
                
                let query = (parameters.compactMap({ (key, value) -> String in
                    return "\(key)=\(value)"
                }) as Array).joined(separator: "&")
                
                let data = query.data(using: .utf8, allowLossyConversion: false)
                urlRequest.httpBody = data
                
            } else {
                
                guard let boundary = parameters["boundary"] as? String else {
                    throw EncoderError.encodingFailed
                }
                
                let body = NSMutableData()
                let boundaryPrefix = "--\(boundary)\r\n"
                
                if let params = parameters["dict"] as? Parameters {
                    for (key, value) in params {
                        body.appendString(boundaryPrefix)
                        body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                        body.appendString("\(value)\r\n")
                    }
                }
                
                body.appendString(boundaryPrefix)
                
                if let mimeType = parameters["mimeType"] as? String, let filename = parameters["filename"] as? String, let data = parameters["data"] as? Data {
                    body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
                    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                    body.append(data)
                }
                
                body.appendString("\r\n")
                body.appendString("--".appending(boundary.appending("--")))
                
                urlRequest.httpBody = body as Data
            }
            
        } catch {
            throw EncoderError.encodingFailed
        }
    }
}

