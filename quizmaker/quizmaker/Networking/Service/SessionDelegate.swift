
import Foundation

public class SessionDelegate: NSObject {
    override init() {
        super.init()
    }
}

extension SessionDelegate: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Did receive challenge \(challenge.protectionSpace.authenticationMethod)")
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Did become invalid with error \(error?.localizedDescription ?? "")")
    }
}

extension SessionDelegate: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.previousFailureCount > 1 {
            completionHandler(.cancelAuthenticationChallenge, nil)
        } else {
            guard let username = UserDefaults.standard.getUsername() else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            guard let password = UserDefaults.standard.getPassword() else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            let credential = URLCredential(user: username, password: password, persistence: .forSession)
            completionHandler(.useCredential, credential)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Did complete with error \(error?.localizedDescription ?? "")")
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("Task is waiting for connectivity...")
    }
}
