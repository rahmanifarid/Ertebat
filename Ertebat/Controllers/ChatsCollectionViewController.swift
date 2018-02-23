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

class ChatsCollectionViewController: UICollectionViewController {
    var messageData = [MessageData]()
    var currentOpenMessageThreadId:String?
    var threads = [Thread]()
    var cellData = [ChatsCellData]()
    var firstLaunch = true //used to decide when to play sound when new message arrives
    override func viewDidLoad() {
        super.viewDidLoad()
//        Messages.shared.addMessageListener { (messageDataArray) in
//            self.messageData = messageDataArray
//            self.collectionView?.reloadData()
//            if self.firstLaunch{
//                //Don't play any sounds
//                self.firstLaunch = false
//                return
//            }
//
//            //Decide to play sound or not
//            for msgData in messageDataArray{
//                guard let message = msgData.messages.last else{
//                    continue
//                }
//                if message.senderId == Auth.auth().currentUser?.uid{
//                    continue
//                }
//                if message.seen == false && message.senderId != self.currentOpenMessageThreadId{
//                    //make noise
//                    AudioServicesPlaySystemSound(1007)
//                }
//            }
//        }
        startObservingThreads()
        //let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        //flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height:90)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func startObservingThreads() {
       let threadsRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("threads")
        threadsRef.addSnapshotListener { (ss, err) in
            print("Snapshot listener for observing threads returned")
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
                self.threads = threads
                
                for thread in threads{
                    let cellData = ChatsCellData.initWith(thread: thread)
                    if !self.cellData.contains(cellData){
                        cellData.beginDownloading()
                        self.cellData.append(cellData)
                        print("Self not contain chat data so I add")
                    }
                    
                    
                }
                
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
        currentOpenMessageThreadId = clickedMessageData.user.id
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

}


