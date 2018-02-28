//
//  MessageThreadController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/5/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore
import AVFoundation

private let outgoingTextReuseIdentifier = "outgoingText"
private let incomingTextReuseIdentifier = "incomingText"
private let messageTypePicture = "picture"
private let messageTypeText = "text"

class MessageThreadController: UIViewController {
    
    var messages = [Message]()
    var thread:Thread?
    var user:User?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMessageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var rowCalculatedSizes = [IndexPath : CGSize]() //Row sizes that are already calculated
    @IBAction func sendButtonPress(_ sender: UIButton) {
        let messageText = messageTextView.text.trimmingCharacters(in: CharacterSet(charactersIn: "\n \t\r"))
        if messageText == ""{
            return
        }
        sender.isEnabled = false
        let message = Message(type:messageTypeText, senderId: Auth.auth().currentUser?.uid, receiverId: user?.id, text: messageText, pictureUrl: nil)
        
        if errorRetrievingThreadInfo{
            //Try one more time to retrieve thread info
            let threadId = constructThreadId()
            
            let listenerBlock = {(ss:DocumentSnapshot?, err:Error?) in
                if let error = err{
                    print(error.localizedDescription)
                    self.errorRetrievingThreadInfo = true
                    let alert = UIAlertController(title: "Error Sending Message", message: error.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    sender.isEnabled = true
                }
                
                if let snapshot = ss{
                    if let data = snapshot.data(){
                        let thread = Thread.initWith(data: data)
                        self.thread = thread
                        self.observeThread(id: thread.id)
                    }
                    self.send(message: message)
                }
            }
            Firestore.firestore().collection("threads").document(threadId).getDocument(completion:listenerBlock)
        }else{
            send(message: message)
        }
        
        
        
    }
    
    func send(message:Message) {
        
        if thread != nil {
            sendMessage(message, thread: thread!)
            
        }else{
            //Create the thread first
            let threadId = constructThreadId()
            let currentUserId = Auth.auth().currentUser!.uid
            let threadUsers = [user!.id!, currentUserId]
            let threadData:[String:Any] = ["id": threadId, "creationDate": Date(), "users" : threadUsers, "lastMessage": message.data()]
            let threadRef = Firestore.firestore().collection("threads").document(threadId)
            threadRef.setData(threadData, completion: { (err) in
                if let error = err{
                    let alert = UIAlertController.createAlert(title: "Error", message: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                    self.sendButton.isEnabled = true
                    return
                }
                
                self.thread = Thread(id: threadId, lastMessage: nil, users: threadUsers)
                self.sendMessage(message, thread: self.thread!)
                self.observeThread(id: self.thread!.id)
                
            })
            //Add this thread to both users thread collection
            let u1 = Firestore.firestore().collection("users").document(currentUserId).collection("threads").document(threadId)
            u1.setData(threadData)
            let u2 = Firestore.firestore().collection("users").document(user!.id!).collection("threads").document(threadId)
            u2.setData(threadData)
        }
       
    }
    
    func sendMessage(_ message:Message, thread:Thread) {
        self.messages.append(message)
        //lastMessageSent = message
        let rowNumber = messages.count - 1
        let indexPath = IndexPath(row: rowNumber, section: 0)
        collectionView.insertItems(at: [indexPath])
        messageTextView.text = ""
        sendButton.isEnabled = true
        receivedMessageIds.append(message.id!)
        let threadId = thread.id
        let doc = Firestore.firestore().collection("threads").document(threadId).collection("messages").document(message.id!)
        doc.setData(message.data()) { (err) in
            if let error = err{
                print(error.localizedDescription)
            }else{
                //message.text = message.text! + " Delivered"
                self.receivedMessageIds.append(message.id!)
                self.messages[indexPath.row].text = self.messages[indexPath.row].text ?? "" + " Sent"
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.collectionView.reloadItems(at: [indexPath])
                }, completion: nil)
                
                print("Message sent? maybe")
//                let doc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("messages").document(message.id!)
                
//                doc.setData(message.data()) { (err) in
//                    if let error = err{
//                        print(error.localizedDescription)
//                    }
//                }
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user?.name
//        for msg in messagesData.messages{
//            receivedMessageIds.append(msg.id!)
//        }
        
        loadThreadMessages()
        registerForKeyboardNotifications()
        
    }
    
    
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotificationReceived(note:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotificationReceived(note:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        if messagesData.messages.count - 1 >= 0{
//            let indexPath = IndexPath(item: messagesData.messages.count - 1, section: 0)
//            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
//        }else{
//            print("nope)")
//        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observer?.remove()
        user = nil
        thread = nil
        messages.removeAll()
    }
    
    
    var receivedMessageIds = [String]()
    var errorRetrievingThreadInfo = false //This will be set to true if there were errors when getting thread info
    
    func loadThreadMessages(){
        if thread != nil{
            observeThread(id: thread!.id)
        }else{
            //If the thread is nil and the user is not, this means the MessageThreadController
            //is launched from a ProfileViewController, so we query the database to see if there
            //is a previous message exchange with this user.
            retrieveThreadInfo()
        }
//        Messages.shared.addMessageListenerForKey(key: messagesData.user.id!) { (messageData) in
//
//            let messages = messageData.messages
//            self.processMessagesAndAddToCollectionView(receivedMessages: messages)
//            print("Load messages called")
//        }
    }
    
    func retrieveThreadInfo() {
        
        let threadId = constructThreadId()
        
        let listenerBlock = {(ss:DocumentSnapshot?, err:Error?) in
            if let error = err{
                print(error.localizedDescription)
                self.errorRetrievingThreadInfo = true
            }
            
            if let snapshot = ss{
                if let data = snapshot.data(){
                    let thread = Thread.initWith(data: data)
                    self.thread = thread
                    print("Thread is \(thread)")
                    self.observeThread(id: thread.id)
                }
            }
        }
        Firestore.firestore().collection("threads").document(threadId).getDocument(completion:listenerBlock)
        
    }
    
    func constructThreadId() -> String {
        let id1 = user!.id!
        let id2 = Auth.auth().currentUser!.uid
        
        
        
        var threadId = ""
        for i in 0..<14{
            let index1 = id1.index(id1.startIndex, offsetBy: i)
            let c1 = id1[index1]
            
            let index2 = id2.index(id2.startIndex, offsetBy: i)
            let c2 = id2[index2]
            if c1 < c2{
                threadId += String(c1) + String(c2)
            }else{
                threadId += String(c2) + String(c1)
            }
        }
        return threadId
    }
    
    
    var observer:ListenerRegistration?
    
    func observeThread(id:String) {
        let query = Firestore.firestore().collection("threads").document(id).collection("messages").order(by: "date", descending: true).limit(to: 20)
        
        observer = query.addSnapshotListener { (sshot, err) in
            if let error = err{
                print(error.localizedDescription)
            }
            
            if let snapshot = sshot{
                var receivedMessages = [Message]()
                for doc in snapshot.documents{
                    let data = doc.data()
                    let message = Message.initWithData(data)
                    receivedMessages.append(message)
                    
                }

                self.processMessagesAndAddToCollectionView(receivedMessages: receivedMessages)
            }
        }
        
        
    }
    
    
    func processMessagesAndAddToCollectionView(receivedMessages:[Message])  {
        //filter out the last message that is sent by user from incoming messages because
        //that is already added to the table view
        var messages = receivedMessages.filter({ (message) -> Bool in
            return !self.receivedMessageIds.contains(message.id!)
        })
        messages.sort()
        var startNumberOfNewRows = self.messages.count
        if messages.count > 0, self.messages.count != 0{
            //make noise
            AudioServicesPlaySystemSound(1003)
        }
        self.messages += messages
        var indexPaths = [IndexPath]()
        for _ in messages{
            let indexPath = IndexPath(item: startNumberOfNewRows, section: 0)
            indexPaths.append(indexPath)
            startNumberOfNewRows += 1
        }
        
        self.collectionView.insertItems(at: indexPaths)
        
        for msg in messages{
            self.receivedMessageIds.append(msg.id!)
        }
        if self.messages.count - 1 >= 0{
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
        
        
        
        for var msg in messages{
            if msg.seen == false && msg.senderId != Auth.auth().currentUser?.uid{
                print("Updated message to seen:true \(msg)")
                msg.seen = true
                Firestore.firestore().collection("threads").document(thread!.id).collection("messages").document(msg.id!).updateData(["seen": true]){(err) in
                    if let error = err{
                        print("Error while updating message state to seen:true")
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc func keyboardNotificationReceived(note:Notification){
        guard let userInfo = note.userInfo else{
            return
        }
        if note.name == .UIKeyboardWillShow{
            
        }
        var finalRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        finalRect = view.convert(finalRect, from: view.window)
        var beginRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        beginRect = view.convert(beginRect, from: view.window)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let layoutConstant = beginRect.origin.y - finalRect.origin.y
        
        UIView.animate(withDuration: duration) {
            self.bottomConstraint.constant += layoutConstant
            self.collectionView.contentOffset.y += layoutConstant
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension MessageThreadController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages[indexPath.row]
        let prevMessage = indexPath.row > 0 ? messages[indexPath.row - 1] : nil
        let nextMessage = indexPath.row < (messages.count - 1) ? messages[indexPath.row + 1] : nil
        var reuseId = ""
        if message.senderId == Auth.auth().currentUser?.uid{
            reuseId = outgoingTextReuseIdentifier
        }else{
            reuseId = incomingTextReuseIdentifier
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! TextMessageCell
        
        // Configure the cell
        cell.textView.text = message.text!
        cell.layoutIfNeeded()
        if reuseId == outgoingTextReuseIdentifier{
            
            //cell.bubbleView.backgroundColor = UIColor(red: 0, green: 212 / 255, blue: 255 / 255, alpha: 1)
            
            cell.bubbleView.layer.cornerRadius = 15
            var maskedCorners:CACornerMask = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner]
            if prevMessage?.senderId != Auth.auth().currentUser?.uid || nextMessage?.senderId != Auth.auth().currentUser?.uid{
                
                maskedCorners.formUnion(.layerMaxXMaxYCorner)
            }
//            if nextMessage?.senderId != Auth.auth().currentUser?.uid{
//
//                maskedCorners.formUnion(.layerMaxXMaxYCorner)
//            }
            
            cell.bubbleView.layer.maskedCorners = maskedCorners
        }else if reuseId == incomingTextReuseIdentifier{
            cell.bubbleView.layer.cornerRadius = 15
            var maskedCorners:CACornerMask = [CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMaxXMaxYCorner]
            if prevMessage?.senderId != message.senderId || nextMessage?.senderId != message.senderId{
                
                maskedCorners.formUnion(.layerMinXMaxYCorner)
            }
//            if nextMessage?.senderId != message.senderId{
//
//                maskedCorners.formUnion(.layerMinXMaxYCorner)
//            }
            
            cell.bubbleView.layer.maskedCorners = maskedCorners
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let calculatedSize = rowCalculatedSizes[indexPath]{
            return calculatedSize
        }
        let width = (UIScreen.main.bounds.width) / 2 + 64
        let textView = UITextView()
        let message = self.messages[indexPath.row]
        textView.text = message.text!
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        var size = textView.sizeThatFits(CGSize(width: width, height: CGFloat.infinity))
        size.width = UIScreen.main.bounds.size.width - 20
        
        rowCalculatedSizes[indexPath] = size
        return size
    }
    
    
    
    
}




