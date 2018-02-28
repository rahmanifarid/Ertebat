//
//  ChatsCollectionViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/9/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
private let reuseIdentifier = "Cell"

class ChatsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var barViewItem:BarViewItem?
    var messageData = [MessageData]()
    var currentOpenMessageThreadId:String?
    
    var cellData = [ChatsCellData]()
    var firstLaunch = true //used to decide when to play sound when new message arrives
    
    var observerForUnseenMessages:NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingThreads()
        observerForUnseenMessages = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UnseenMessageNumberChange"), object: nil, queue: OperationQueue.main, using: { (notification) in
            var totalUnseen = 0
            for d in self.cellData{
                totalUnseen += d.unseenMessages
            }
            self.barViewItem?.setBadgeValue(toValue: totalUnseen)
            let userInfo = notification.userInfo
            if userInfo?["threadId"] as? String != self.currentOpenMessageThreadId, let unseen = userInfo?["unseenMessages"] as? Int, unseen > 0, self.firstLaunch == false{
                self.beep()
            }
        })
    }
    
    func beep() {
        AudioServicesPlaySystemSound(1007)
    }
    
    func startObservingThreads() {
       let threadsRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("threads")
        threadsRef.addSnapshotListener { (ss, err) in
           
            if let error = err{
                let alert = UIAlertController.createAlert(title: "Error Downloading Messages", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                
            }
            
            if let snapshot = ss{
                var threads = [Thread]()
                for doc in snapshot.documents{
                    let data = doc.data()
                    let thread = Thread.initWith(data: data)
                    threads.append(thread)
                }
               
                
                for thread in threads{
                    let cellData = ChatsCellData.initWith(thread: thread)
                    if !self.cellData.contains(cellData){
                        cellData.beginDownloading()
                        self.cellData.append(cellData)
                        
                    }
                    
                    
                }
                self.firstLaunch = false
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentOpenMessageThreadId = nil
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return cellData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatsCollectionViewCell
        let cellData = self.cellData[indexPath.row]
//        if message != nil{
//            cell.titleLabel.text = messageData[indexPath.row].user.name
//            cell.messageLabel.text = message?.text
//            if let urlString = messageData[indexPath.row].user.profileUrl{
//                let url = URL(string: urlString)
//                cell.imageView.sd_setImage(with: url)
//
//            }
//            if message?.seen == false{
//                cell.messageLabel.font = UIFont.preferredFont(forTextStyle: .headline)
//                cell.messageLabel.textColor = UIColor.blue
//
//            }else{
//                cell.messageLabel.textColor = UIColor.lightGray
//            }
//
//
//        }
        // Configure the cell
        cell.setCellDataModel(cellData)
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedMessageData = cellData[indexPath.row]
        if clickedMessageData.downloaded == false{
            return
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let messageThreadController = storyBoard.instantiateViewController(withIdentifier: "messageThreadController") as! MessageThreadController
        
        messageThreadController.user = clickedMessageData.user
        messageThreadController.thread = clickedMessageData.thread
        navigationController?.pushViewController(messageThreadController, animated: true)
        currentOpenMessageThreadId = clickedMessageData.thread.id
    }

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: min(UIScreen.main.bounds.width - 10, 420), height: 90)
    }
    
    

}


