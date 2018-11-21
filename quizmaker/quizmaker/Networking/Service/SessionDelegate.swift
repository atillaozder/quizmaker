
import Foundation

class SessionDelegate: NSObject {
    override init() {
        super.init()
    }
}

extension SessionDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Did receive challenge \(challenge.protectionSpace.authenticationMethod)")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Did become invalid with error \(error?.localizedDescription ?? "")")
    }
}

extension SessionDelegate: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Did complete with error \(error?.localizedDescription ?? "")")
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("Task is waiting for connectivity...")
    }
}
