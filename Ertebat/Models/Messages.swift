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
    typealias MessageListener = (MessageData)->()
    typealias AllMessageDataListener = ([MessageData])->() //Listeners who has requested all messages for all users
    private var allMessageListeners = [AllMessageDataListener]()
    static let shared = Messages()
    private var latestMessage:Message?
    private var messages = [String : [Message]]()
    private var messageData = [MessageData]()
    private var users = [String: User]()
    private var listenersForKeys = [String : MessageListener]()
    
    
    
    private init(){
        
        createObserver()
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
    var messagesDownloaded = false
    func downLoadMessages(newer:Bool = false) {
        guard let userId = Auth.auth().currentUser?.uid else {
            
            return
        }
        var query:Query
        
        if newer, let newestMessage = latestMessage {
            print("Query for newer messages added")
            query = Firestore.firestore().collection("users").document(userId).collection("messages").whereField("date", isGreaterThan: newestMessage.date!).order(by: "date", descending: false)
            //query.whereField("text", isEqualTo: "kos wa kawn")
        }else{
            query = Firestore.firestore().collection("users").document(userId).collection("messages").order(by: "date", descending: false)
        }
        
        query.getDocuments { (qsshot, err) in
            print("Updated messages requested")
            if let error = err {
                print(error.localizedDescription)
                
            }
            
            if let snapshot = qsshot{
                
                //save the newest message so next time only newer than this message will be downloaded
                if let newest = snapshot.documents.last{
                    let data = newest.data()
                    let message = Message.initWithData(data)
                    self.latestMessage = message
                }
                
               self.messagesDownloaded = true
                if newer{
                    print("Newer messages downloaded")
                }else{
                    print("All messages downloaded")
                }
                guard let userId = Auth.auth().currentUser?.uid else{
                    return
                }
                
                
                
                print("Number of messages downloaded \(snapshot.documents.count)")
                if snapshot.documents.count == 0{
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
                
                
                for (id, _) in self.messages{
                    if self.users[id] == nil{
                        print("Request for user info sent")
                        Firestore.firestore().collection("users").document(id).getDocument(completion: { (sshot, err) in
                            if let error = err{
                                print(error.localizedDescription)
                            }
                            if let snapshot = sshot{
                                let data = snapshot.data()
                                let user = User.createWith(data: data!)
                                
                                
                                self.users[id] = user
                                self.callListenersForKey(id)
                                //Check if all user data is downloaded
                                if self.users.keys.count == self.messages.keys.count{
                                    //This means all users are downloaded so
                                    print("All users downloaded")
                                    self.invokeMessageListeners()
                                }
                            }
                            
                            
                        })
                    }else{
                        self.callListenersForKey(id)
                        if self.users.keys.count == self.messages.keys.count{
                            //This means all users are downloaded so
                            print("User Downloaded Already")
                            self.invokeMessageListeners()
                        }
                    }
                    
                }
                
                
                
                
            }
        }
    }
    
    func invokeMessageListeners() {
        
        for messageListener in allMessageListeners{
            print("message Listeners invoked")
            var messageDataArray = [MessageData]()
            for (id, user) in users{
                let message = messages[id]
                let messageData = MessageData(user: user, messages: message!)
                messageDataArray.append(messageData)
            }
            messageListener(messageDataArray)
        }
    }
    
    func callListenersForKey(_ key:String) {
        print("Messages.callListenersForKey called")
        if let listener = self.listenersForKeys[key], let user = users[key], let msgArray = self.messages[key]{
            
            let messageData = MessageData(user: user, messages: msgArray)
            listener(messageData)
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
    
    func addMessageListener(messageListener: @escaping AllMessageDataListener) {
        self.allMessageListeners.append(messageListener)
        if messagesDownloaded{
           invokeMessageListeners()
        }
        
    }
    
    func addMessageListenerForKey(key:String, messageListener: @escaping MessageListener) {
        self.listenersForKeys[key] = messageListener
        
    }
    
    func removeMessageListenerForKey(key:String) {
        self.listenersForKeys.removeValue(forKey: key)
        
    }
    
    
    
}



struct MessageData{
    var user:User
    var messages:[Message]
    
}
