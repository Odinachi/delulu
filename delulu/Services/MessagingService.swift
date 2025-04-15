import SwiftUI
import Firebase
import FirebaseMessaging

class MessagingService {
    static let shared = MessagingService()
    
  func subscribeToTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
              
                completion?(error)
            } else {
               
                completion?(nil)
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String, completion: ((Error?) -> Void)? = nil) {
           Messaging.messaging().unsubscribe(fromTopic: topic) { error in
               if let error = error {
                   print("Failed to unsubscribe from \(topic): \(error.localizedDescription)")
                   completion?(error)
               } else {
                   print("Successfully unsubscribed from \(topic)")
                   completion?(nil)
               }
           }
       }
    
}
