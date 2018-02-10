//
//  MessageThreadController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/5/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "Cell"
private let messageTypePicture = "picture"
private let messageTypeText = "text"
class MessageThreadController: UIViewController {
    var user:User!
    lazy var messagesData:MessageData = MessageData(user: user, messages: [Message]())
   
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMessageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func sendButtonPress(_ sender: Any) {
        var message = Message(type: messageTypeText, senderId: Auth.auth().currentUser?.uid, receiverId: user.id, text: messageTextView.text, pictureUrl: nil, date: Date())
        self.messagesData.messages.append(message)
        let rowNumber = messagesData.messages.count - 1
        let indexPath = IndexPath(row: rowNumber, section: 0)
        collectionView.insertItems(at: [indexPath])
        messageTextView.text = ""
        Firestore.firestore().collection("users").document(user.id!).collection("messages").addDocument(data: message.data()) { (err) in
            if let error = err{
                print(error.localizedDescription)
            }else{
                message.text = message.text! + " Delivered"
                self.messagesData.messages[indexPath.row] = message
                self.collectionView.reloadItems(at: [indexPath])
                print("Message sent? maybe")
            }
            
        }
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("messages").addDocument(data: message.data()) { (err) in
            if let error = err{
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user.name
        loadMessages()
        
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotificationReceived(note:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotificationReceived(note:)), name: .UIKeyboardWillHide, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func loadMessages(){
        Messages.shared.add(Listener: self, forKey: user.id!)
        
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
        return messagesData.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        let message = messagesData.messages[indexPath.row]
        // Configure the cell
        cell.textView.text = message.senderId! + " RecID: " + message.receiverId! + " \n" + message.text!
        cell.backgroundColor = UIColor.gray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        let textView = UITextView()
        let message = self.messagesData.messages[indexPath.row]
        textView.text = message.senderId! + " RecID: " + message.receiverId! + " \n" + message.text!
        var size = textView.sizeThatFits(CGSize(width: width, height: CGFloat.infinity))
        size.width = width
        size.height = size.height + 10
        print(size)
        return size
    }
    
    
}

extension MessageThreadController:MessageReceiver{
    func didReceiveMessages(_ messageData: [MessageData]) {
        guard let first = messageData.first else {
            return
        }
        self.messagesData = first
        print("MessageData Received I think")
        collectionView.reloadData()
    }
}


