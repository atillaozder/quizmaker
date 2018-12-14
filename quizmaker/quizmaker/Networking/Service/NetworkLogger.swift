
import Foundation

/**
 A helper class to debug and trace the API Request.
 */
public final class NetworkLogger {
    
    /**
     A helper static method to debug and trace the API Request.
     
     - Parameters:
        - request: URLRequest instance contains information about request.
     
     - Postcondition: All request information will be printed in console.
     */
    static func log(request: URLRequest) {
        let urlString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var output = """
        \n--------------------------------------------
        \(urlString) \n\(method) \(path)?\(query) HTTP/1.1 \nHOST: \(host)\n
        """
        
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            output += "\(key): \(value) \n"
        }
        
        if let body = request.httpBody {
            output += "\n\(String(data: body, encoding: String.Encoding.utf8) ?? "")"
        }
        
        output += "\n--------------------------------------------"
        print(output)
    }
}
