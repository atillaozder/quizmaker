
import Foundation

public typealias RouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

public protocol Router: class {
    func request(_ endpoint: EndpointType, completion: @escaping RouterCompletion)
    func invalidateSession()
    func cancel()
}

/// :nodoc:
public final class NetworkRouter {
    
    private var session: URLSession
    private var task: URLSessionTask?
    private var delegate: SessionDelegate
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
//        if #available(iOS 11.0, *) { configuration.waitsForConnectivity = true }
        
        delegate = SessionDelegate()
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: OperationQueue.main)
    }
    
    deinit {
        self.invalidateSession()
    }
    
    private func prepare(request: inout URLRequest, _ endpoint: EndpointType) {
        request.httpMethod = endpoint.httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    private func configureParameters(for request: inout URLRequest, endpoint: EndpointType) throws {
        do {
            switch endpoint.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let encoder, let bodyParameters, let urlParameters):
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                try encoder.encode(urlRequest: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
            case .requestParametersAndHeaders(let encoder,
                                              let bodyParameters,
                                              let urlParameters,
                                              let additionalHeaders):
                
                guard let headers = additionalHeaders else { return }
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                
                try encoder.encode(urlRequest: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
            }
        } catch {
            throw error
        }
    }
}

extension NetworkRouter: Router {
    
    public func request(_ endpoint: EndpointType, completion: @escaping RouterCompletion) {
        var request = URLRequest(url: endpoint.baseURL.appendingPathComponent(endpoint.path))
        prepare(request: &request, endpoint)
        
        do {
            try configureParameters(for: &request, endpoint: endpoint)
        } catch {
            completion(nil, nil, error)
        }
        
        NetworkLogger.log(request: request)
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            completion(data, response, error)
        })
        
        self.task?.resume()
    }
    
    public func cancel() {
        self.task?.cancel()
    }
    
    public func invalidateSession() {
        self.session.invalidateAndCancel()
    }
}



