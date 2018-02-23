//
//  TableViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/30/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import FirebaseStorageUI
class PostsTableViewController: UITableViewController {
    var posts = [Post]()
    var users = [String: User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create the barView
        let addPostBarItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewPostPress(_:)))
        toolbarItems?.append(addPostBarItem)
        //load posts
        loadPosts(newerOnly: false)
//

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    @objc func addNewPostPress(_ sender:UIBarButtonItem){
        performSegue(withIdentifier: "addNewPost", sender: self)
    }
    
    func loadPosts(newerOnly: Bool) {
        var afterDate:NSDate = NSDate.init(timeIntervalSinceNow: -(24 * 3600))
        if newerOnly {
            if posts.count > 0{
                afterDate = posts.first!.date!
            }
        }
        let query = Firestore.firestore().collection("posts").whereField("date", isGreaterThan:afterDate).order(by: "date", descending: true)
        query.getDocuments { (sshot, err) in
            if let error = err{
                self.dialog(title: "Error", message: error.localizedDescription)
                return
            }
            if let snapShot = sshot{
                var authorIds = [String]()
                var newPosts = [Post]()
                
                for doc in snapShot.documents{
                    let data = doc.data()
                    let post = Post.createWith(data: data)
                    authorIds.append(data["authorId"] as! String)
                    newPosts.append(post)
                    
                }
                if newPosts.count == 0{
                    
                    return
                }
                
                //Download author details
                if authorIds.count == 0{
                    return
                }
                let sortedAuthorIDs = authorIds.sorted()
                let collectionRef = Firestore.firestore().collection("users")
                collectionRef.whereField("id", isGreaterThanOrEqualTo: sortedAuthorIDs.first!).whereField("id", isLessThanOrEqualTo: sortedAuthorIDs.last!)
                collectionRef.getDocuments(completion: { (sshot, err) in
                    if let error = err{
                        print(error.localizedDescription)
                        
                    }
                    if let snapShot = sshot{
                        for doc in snapShot.documents{
                            let data = doc.data()
                            let id = data["id"] as! String
                            let user = User.createWith(data: data)
                            self.users[id] = user
                        }
                        if self.posts.count == 0{
                            self.posts = newPosts
                            self.tableView.reloadData()
                            //Create The Observer
                            self.createObserver()
                        }else{
                            self.posts = newPosts + self.posts
                            var indexPaths = [IndexPath]()
                            for i in 0..<newPosts.count{
                                indexPaths.append(IndexPath(row: i, section: 0))
                            }
                            self.tableView.insertRows(at: indexPaths, with: .top)
                        }
                        
                        
                        
                        
                    }
                })
                
            }
        }
        
    }
    
    func createObserver() {
        var date:NSDate? = nil
        if posts.count == 0 {
            date = NSDate(timeIntervalSinceNow: -(24 * 3600))
        }else{
           date = posts.first!.date!
        }
        
        Firestore.firestore().collection("posts").order(by: "date", descending: true).whereField("date", isGreaterThan: date!).addSnapshotListener { (ss, err) in
                if let error = err{
                    print(error.localizedDescription)
                }
            
                if ss != nil{
                    self.loadPosts(newerOnly: true)
                }

            }
    }
    
    func dialog(title:String, message:String) {
        print("kaka")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textPostCell", for: indexPath) as! TableViewCell
        let post = posts[indexPath.row]
        let author = users[post.authorId!] as User?
        cell.postText.text = post.text
        cell.name.text = author?.name
        // Configure the cell...
        let profileUrl = URL.init(string: author!.profileUrl!)
        
        cell.profilePictureView.sd_setImage(with: profileUrl) { (img, err, cache, url) in
            if err == nil{
                print("Image downloaded successfulment")
            }
        }
        var description = ""
        let date = post.date!
        let interval = Date().timeIntervalSince(date as Date)
        if interval < (3600 * 12){
            description = "\(Int(interval / 3600))hr ago"
        }else{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            description = formatter.string(from: date as Date)
        }
        
        
        cell.dateLabel.text = description
        return cell
    }
 

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let post = posts[indexPath.row]
//        let te:NSString = post.text as! NSString
//        let ts = te.size(withAttributes: [NSAttributedStringKey.font : font])
        let textv = UITextView()
        textv.text = post.text
        textv.font = font
        let size = textv.sizeThatFits(CGSize(width:UIScreen.main.bounds.width - 110, height:.infinity))
//        let te:NSString = post.text as! NSString
//        let size = te.size(withAttributes: [NSAttributedStringKey.font : font])
//        let contentWidth = UIScreen.main.bounds.width - 135
//        let lines = ceil(max(contentWidth, size.width) / contentWidth) + 1
//        let height = lines * (size.height) + (lines - 1) * 5
//        print("size: \(size) Height is \(height) lines: \(lines) contentW: \(contentWidth)")
//        return height + 26.5 + 8 + 29 + 21 + 10
        return max(size.height + 51.5 + 31.5, 64 + 10)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



