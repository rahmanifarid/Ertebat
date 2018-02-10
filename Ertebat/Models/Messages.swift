//
//  Messages.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/6/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
import Firebase

class Messages {
    typealias MessageListener = ([MessageData])->()
    private var messageListeners = [MessageListener]()
    static let shared = Messages()
    private var latestMessage:Message?
    private var messages = [String : [Message]]()
    private var messageData = [MessageData]()
    private var users = [String: User]()
    private var listenersForOneKey = NSMapTable<AnyObject, AnyObject>(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
    private var listenersForAllKeys = [MessageReceiver?]()
    
    
    private init(){
        
        createObserver()
    }
    
    func add(Listener listener:MessageReceiver, forKey key: String) {
        listenersForOneKey.setObject(listener, forKey: NSString(string: key))
        callListenersForKey(key)
    }
    
    func initialize() {
        print("Messages Manager Initialized")
    }
    
    private func createObserver(){
        guard let userId = Auth.auth().currentUser?.uid else {
            
            return
        }
        
        Firestore.firestore().collection("users").document(userId).collection("messages").order(by: "date", descending: true).addSnapshotListener { (qsshot, err) in
            if let error = err {
                print(error.localizedDescription)
                
            }
            
            if qsshot != nil{
                self.downLoadMessages(newer: true)
            }
        }
    }
    
    func downLoadMessages(newer:Bool = false) {
        guard let userId = Auth.auth().currentUser?.uid else {
            
            return
        }
        let query = Firestore.firestore().collection("users").document(userId).collection("messages").order(by: "date", descending: true)
        if newer, let newestMessage = latestMessage {
            
            query.whereField("date", isGreaterThan: newestMessage.date!)
        }
        query.getDocuments { (qsshot, err) in
            if let error = err {
                print(error.localizedDescription)
                
            }
            
            if let snapshot = qsshot{
                self.messages.removeAll()
                print("New message arraived")
                guard let userId = Auth.auth().currentUser?.uid else{
                    return
                }
                
                for doc in snapshot.documents{
                    let data = doc.data()
                    let message = Message.initWithData(data)
                    let key = message.senderId == userId ? message.receiverId! : message.senderId!
                    var msgArray = self.messages[key] ?? [Message]()
                    msgArray.append(message)
                    self.messages[key] = msgArray
                    
                }
                
                for (userId, messageArray) in self.messages{
                    Firestore.firestore().collection("users").document(userId).getDocument(completion: { (sshot, err) in
                        if let error = err{
                            print(error.localizedDescription)
                        }
                        if let snapshot = sshot{
                            let data = snapshot.data()
                            let user = User.createWith(data: data!)
                            let messageData = MessageData(user: user, messages: messageArray)
                            self.messageData.append(messageData)
                            self.callListenersForKey(userId)
                            
                        }
                        
                        //Check if all user data is downloaded
                        if self.messageData.count == self.messages.keys.count{
                            //This means all users are downloaded so
                            self.invokeMessageListeners()
                        }
                    })
                }
                
                
            }
        }
    }
    
    func invokeMessageListeners() {
        for messageListener in messageListeners{
            messageListener(messageData)
        }
    }
    
    func callListenersForKey(_ key:String) {
        if let listener = self.listenersForOneKey.object(forKey: NSString(string:key)) as? MessageReceiver, let user = users[key], let msgArray = self.messages[key]{
            
            let messageData = MessageData(user: user, messages: msgArray)
            listener.didReceiveMessages([messageData])
        }
    }
    
    func chats() -> [MessageData] {
        var result = [MessageData]()
        for (userId, user) in self.users{
            if let message = self.messages[userId]{
                result.append(MessageData(user: user, messages: message))
            }
        }
        return result
    }
    
    func addMessageListener(messageListener: @escaping MessageListener) {
        self.messageListeners.append(messageListener)
    }
    
    
    
    
}



struct MessageData{
    var user:User
    var messages:[Message]
    
}
