
import Foundation
import RxSwift

/// Custom JSON typealias. Basically it is a dictionary keys are String and values could be Any
/// - Precondition: Keys must be String.
public typealias JSON = [String: Any]

/// Custom JSONResponse typealias. A result object T that is the parameter of success will be JSON and U where U: Error will be NetworkError.
/// - SeeAlso:
/// `Result`
public typealias JSONResponse = Result<JSON, NetworkError>

/// API request singleton manager class.
public final class NetworkManager {
    
    private typealias RequestCompletion = (_ data: Data?, _ error: NetworkError?) -> Void
    private typealias NetworkErrorCompletionBlock = (NetworkError) -> Void
    
    private let router = NetworkRouter()
    
    /// Singleton shared object.
    static let shared = NetworkManager()
    
    private init() { }
    
    /// :nodoc:
    deinit {
        router.invalidateSession()
    }
    
    /**
     Cancels the current router request.
     
     - Postcondition: Routing request will be cancelled.
    */
    public func cancel() {
        router.cancel()
    }
    
    /**
     Request was fired through router.
     
     - Parameters:
        - endpoint: Specify the shape of the url request. For instance, where will be the destination.
        - success: When the request is successfull and response is retrieved, it will be mapped to success object type.
        - type: Specify if an error occupied which type should need to be controlled.
     
     - Precondition: `endpoint` must be non-nil.
     - Precondition: `success` must conforms decodable protocol.
     
     - Postcondition: An URLSession request will be fired and mapped object will be returned.
     
     - Returns: An observable of result object.
     */
    public func request<T: Decodable>(_ endpoint: EndpointType, _ success: T.Type, _ type: ErrorType = .api) -> Observable<Result<T, NetworkError>> {
        
        return Observable<Result<T, NetworkError>>.create({ [weak self] observer in
            guard let strongSelf = self else { return Disposables.create() }
            strongSelf.commonRequest(endpoint, type, { (data, error) in
                if let networkError = error {
                    observer.onNext(.failure(networkError))
                    observer.onCompleted()
                } else {
                    guard let data = data else {
                        observer.onNext(.failure(.invalidData))
                        observer.onCompleted()
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let object = try decoder.decode(T.self, from: data)
                        observer.onNext(.success(object))
                    } catch {
                        observer.onNext(.failure(.client(.jsonDecodingFailure)))
                    }
                    
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
    
    /**
     Request was fired through router.
     
     - Parameters:
        - endpoint: Specify the shape of the url request. For instance, where will be the destination.
        - type: Specify if an error occupied which type should need to be controlled.
     
     - Precondition: `endpoint` must be non-nil.
     
     - Postcondition: An URLSession request will be fired and JSON response will be returned.
     
     - Returns: An observable of JSONResponse.
     */
    public func requestJSON(_ endpoint: EndpointType,
                     _ type: ErrorType = .api) -> Observable<JSONResponse> {
        
        return Observable<JSONResponse>.create({ [weak self] observer in
            guard let strongSelf = self else { return Disposables.create() }
            strongSelf.commonRequest(endpoint, type, { (data, error) in
                if let networkError = error {
                    observer.onNext(.failure(networkError))
                    observer.onCompleted()
                } else {
                    guard let data = data else {
                        observer.onNext(.success([:]))
                        observer.onCompleted()
                        return
                    }
                    
                    if data.isEmpty {
                        observer.onNext(.success([:]))
                    } else {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? JSON {
                                observer.onNext(.success(json))
                            } else {
                                observer.onNext(.failure(.client(.jsonCastingFailure)))
                            }
                        } catch {
                            observer.onNext(.failure(.client(.jsonSerializationFailure)))
                        }
                    }
                    
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
    
    private func commonRequest(_ endpoint: EndpointType,
                               _ type: ErrorType,
                               _ completion: @escaping RequestCompletion) {
        
        router.request(endpoint) { [weak self] (data, response, error) in
            guard let strongSelf = self else {
                completion(nil, .requestFailed)
                return
            }
            
            if error != nil {
                completion(nil, .requestFailed)
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, .responseUnsuccessfull)
                return
            }
            
            guard let data = data else {
                completion(nil, .invalidData)
                return
            }
            
            switch response.statusCode {
            case 200..<300:
                completion(data, nil)
            default:
                strongSelf.handleError(response, data, type, { (networkError) in
                    switch networkError {
                    case .shouldRetry:
                        strongSelf.commonRequest(endpoint, type, completion)
                    default:
                        completion(nil, networkError)
                    }
                })
            }
        }
    }

    private func handleError(_ response: HTTPURLResponse,
                             _ data: Data,
                             _ type: ErrorType,
                             _ completion: @escaping NetworkErrorCompletionBlock) {
        do {
            switch response.statusCode {
            default:
                let decoder = JSONDecoder()
                
                switch type {
                case .api:
                    
                    let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                    completion(.api(response: errorResponse))
                    
                case .login:
                    
                    let errorResponse = try decoder.decode(FieldErrorResponse.self, from: data)
                    completion(.auth(.login(response: errorResponse)))
                    
                case .register:
                    
                    let errorResponse = try decoder.decode(RegisterErrorResponse.self, from: data)
                    completion(.auth(.register(response: errorResponse)))
                    
                case .changePassword:
                    
                    let errorResponse = try decoder.decode(ChangePasswordErrorResponse.self, from: data)
                    completion(.update(.changePassword(response: errorResponse)))
                    
                case .editProfile:
                    let errorResponse = try decoder.decode(EditProfileErrorResponse.self, from: data)
                    completion(.update(.editProfile(response: errorResponse)))
                    
                case .apiMessage:
                    
                    let errorResponse = try decoder.decode(ErrorMessage.self, from: data)
                    completion(.apiMessage(response: errorResponse))
                    
                case .quizCreate:
                    
                    let errorResponse = try decoder.decode(QuizCreateErrorResponse.self, from: data)
                    completion(.quiz(.create(response: errorResponse)))
                    
                case .answerValidate:
                    
                    let errorResponse = try decoder.decode(GradeErrorResponse.self, from: data)
                    completion(.quiz(.validate(response: errorResponse)))
                    
                }
            }
        } catch {
            print("Decoding Error while handling error \(error.localizedDescription), errorType: \(type)")
            completion(.client(.jsonDecodingFailure))
        }
    }
}

