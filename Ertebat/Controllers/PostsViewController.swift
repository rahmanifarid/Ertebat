//
//  PostsViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/13/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase

let textPostId = "textPostCell"
class PostsViewController: UIViewController {
    var precalculatedPostSizes = [String:(CGSize, CGSize)]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addPostButton: UIButton!
    
    
    @IBAction func addNewPostPress(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let newPostNavController = storyBoard.instantiateViewController(withIdentifier: "createNewPost") as? UINavigationController, let newPostController = newPostNavController.viewControllers.first as? NewPostViewController else{
            print("Can't instantiate NewPostViewController")
            return
        }
        newPostController.add(listener: createNewPostHandler)
        newPostNavController.modalPresentationStyle = .formSheet
        
//        newPostController.add { (postText, postImage) in
//
//        }
        navigationController?.present(newPostNavController, animated: true, completion: nil)
        
    }
    
    func createNewPostHandler(postText:String?, postImage:UIImage?) {
        if let image = postImage{
            
            //upload image
            guard let resizedImage = image.resizeWithWidth(width: UIScreen.main.bounds.width * 2) else{
                let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                let action = UIAlertAction(title: "That Sucks!", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let data = UIImageJPEGRepresentation(resizedImage, 0.9)
            let ref = Storage.storage().reference()
            let imageName = UUID().uuidString
            let filename = "\(imageName).png"
            let fileRef = ref.child("/images/\(filename)")
            let uploadTask = fileRef.putData(data!)
            //activityView.startAnimating()
            uploadTask.observe(.progress) { (snapshot) in
                //let percentage = Int(100 * snapshot.progress!.fractionCompleted)
                //self.percentageUploaded.text = "\(percentage)%"
            }
            uploadTask.observe(.success) { (snapshot) in
                print("Upload successful")
                
                var post = [String: Any]()
                if postText != nil{
                    post["text"] = postText!
                }
                post["imageWidth"] = resizedImage.size.width
                post["imageHeight"] = resizedImage.size.height
                post["authorId"] = Auth.auth().currentUser?.uid
                post["date"] = NSDate()
                
                var pictureUrl = ""
                if snapshot.metadata != nil{
                    pictureUrl = snapshot.metadata!.downloadURL()!.absoluteString
                }
                post["pictureUrl"] = pictureUrl
                Firestore.firestore().collection("posts").addDocument(data: post)
            }
        }else if postText != nil{
            var post = [String: Any]()
            post["text"] = postText!
            post["authorId"] = Auth.auth().currentUser?.uid
            post["date"] = NSDate()
            Firestore.firestore().collection("posts").addDocument(data: post)
        }
    }
    var posts = [Post]()
    var users = [String: User]()
    var dbListener:ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(white: 0.75, alpha: 1.0)
        let freeHorizontalSpace = UIScreen.main.bounds.size.width - (2 * 320 + 30)
        if freeHorizontalSpace > 0{
            let leftEdge = freeHorizontalSpace / 2
            let edgeInset = UIEdgeInsetsMake(10, leftEdge, 10, leftEdge)
            collectionView.contentInset = edgeInset
        }
        loadPosts()
        // Do any additional setup after loading the view.
    }
    lazy var query:Query = {
        var query:Query
        if posts.count > 0 {
            let afterDate = posts.first!.date!
            query = Firestore.firestore().collection("posts").whereField("date", isGreaterThan: afterDate ).order(by: "date", descending: true).limit(to: 20)
        }else{
            query = Firestore.firestore().collection("posts").order(by: "date", descending: true).limit(to: 20)
        }
        return query
    }()
    
    func loadPosts() {
        
       
        self.dbListener = query.addSnapshotListener { (sshot, err) in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            
            if let snapShot = sshot{
                print("Number of posts downloaded \(snapShot.documents.count)")
                if snapShot.documents.count == 0{
                    return
                }
                var authorIds = [String]()
                var newPosts = [Post]()
                
                for doc in snapShot.documents{
                    let data = doc.data()
                    var post = Post.createWith(data: data)
                    post.postId = doc.documentID
                    authorIds.append(data["authorId"] as! String)
                    newPosts.append(post)
                    
                }
                
                
                if self.posts.count == 0{
                    self.posts = newPosts
                    self.collectionView.reloadData()
                    
                    
                }else{
                    self.posts = newPosts + self.posts
                    var indexPaths = [IndexPath]()
                    for i in 0..<newPosts.count{
                        indexPaths.append(IndexPath(row: i, section: 0))
                    }
                    self.collectionView.insertItems(at: indexPaths)
                }
                
                self.query = Firestore.firestore().collection("posts").order(by: "date", descending: true).end(beforeDocument: snapShot.documents.first!).limit(to: 20)
                self.dbListener?.remove()
                self.loadPosts()
                
                
//                //Download author details
//                if authorIds.count == 0{
//                    return
//                }
//                let sortedAuthorIDs = authorIds.sorted()
//                let collectionRef = Firestore.firestore().collection("users")
//                collectionRef.whereField("id", isGreaterThanOrEqualTo: sortedAuthorIDs.first!).whereField("id", isLessThanOrEqualTo: sortedAuthorIDs.last!)
//                collectionRef.getDocuments(completion: { (sshot, err) in
//                    if let error = err{
//                        print(error.localizedDescription)
//
//                    }
//                    if let snapShot = sshot{
//                        for doc in snapShot.documents{
//                            let data = doc.data()
//                            let id = data["id"] as! String
//                            let user = User.createWith(data: data)
//                            self.users[id] = user
//                        }
//                        if self.posts.count == 0{
//                            self.posts = newPosts
//                            self.collectionView.reloadData()
//                            //Create The Observer
//                            self.createObserver()
//                        }else{
//                            self.posts = newPosts + self.posts
//                            var indexPaths = [IndexPath]()
//                            for i in 0..<newPosts.count{
//                                indexPaths.append(IndexPath(row: i, section: 0))
//                            }
//                            //self.tableView.insertRows(at: indexPaths, with: .top)
//                        }
//
//
//
//
//                    }
//                })
                
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
        
        dbListener = Firestore.firestore().collection("posts").order(by: "date", descending: true).whereField("date", isGreaterThan: date!).addSnapshotListener { (ss, err) in
            if let error = err{
                print(error.localizedDescription)
            }
            
            if ss != nil{
                self.loadPosts()
            }
            
        }
    }
    
    func sizeFor(post:Post) -> (CGSize, CGSize) {
        if let postId = post.postId, let precalculated = precalculatedPostSizes[postId]{
            return precalculated
        }
        let width = min(500, UIScreen.main.bounds.width - 20)
        var imageSize = CGSize(width: width, height: 0)
        if let imageHeight = post.imageHeight, let imageWidth = post.imageWidth{
            //imageSize.height = width * CGFloat(imageHeight) / CGFloat(imageWidth)
            imageSize.height = imageSize.width + 8
        }
        var labelSize = CGSize.zero
        if let postText = post.text{
            let label = UILabel()
            label.text = postText
            label.font = UIFont.preferredFont(forTextStyle: .title3)
            label.numberOfLines = 0
            labelSize = label.sizeThatFits(CGSize(width: width - 20, height: .infinity))
            
        }
        
        
        
        if let postId = post.postId{
            precalculatedPostSizes[postId] = (labelSize, imageSize)
        }
        return (labelSize, imageSize)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if self.posts.count > 20{
            for i in 19..<posts.count{
                self.posts.remove(at: i)
            }
            collectionView.reloadData()
        }
        
    }
    var clickedImageFrame = CGRect.zero
    var vxView:UIVisualEffectView = {
        
        let view = UIVisualEffectView(effect: nil)
        view.frame = UIScreen.main.bounds
        return view
    }()
    func zoomImageView(_ imageView:UIImageView){
        let zoomedImageView = UIImageView()
        zoomedImageView.contentMode = .scaleAspectFit
        
        if let frame = UIApplication.shared.keyWindow?.convert(imageView.frame, from: imageView.superview!){
            clickedImageFrame = frame
            zoomedImageView.frame = frame
            zoomedImageView.image = imageView.image
            zoomedImageView.contentMode = .scaleAspectFill
            zoomedImageView.clipsToBounds = true
            /*
             let initialFrameAspect = initialFrame.width / initialFrame.height
             let profileAspect = profileView.frame.width / profileView.frame.height
             if initialFrameAspect > profileAspect{
             initialFrame.size = CGSize(width: profileAspect * initialFrame.height, height: initialFrame.height)
             }else{
             initialFrame.size = CGSize(width: initialFrame.width, height: initialFrame.width / profileAspect)
             }
             */
            var width:CGFloat = 0
            var height:CGFloat = 0
            let imageAspect = imageView.image!.size.width / imageView.image!.size.height
            let screenAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
            if screenAspect > imageAspect{
                width = UIScreen.main.bounds.height * imageAspect
                height = UIScreen.main.bounds.height
            }else{
                height = UIScreen.main.bounds.width / imageAspect
                width = UIScreen.main.bounds.width
            }
            UIApplication.shared.keyWindow?.addSubview(vxView)
            //vxView.contentView.addSubview(zoomedImageView)
            UIApplication.shared.keyWindow?.addSubview(zoomedImageView)
            zoomedImageView.isUserInteractionEnabled = true
            zoomedImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(zoomViewPanned(_:))))
            let effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomedImageView.frame.size = CGSize(width: width, height: height)
                zoomedImageView.center = UIApplication.shared.keyWindow!.center
                self.vxView.effect = effect
            }, completion: nil)
        }
        
    }
    var animator:UIViewPropertyAnimator!
    @objc func zoomViewPanned(_ sender:UIPanGestureRecognizer){
        let window = UIApplication.shared.keyWindow!
        if sender.state == .began{
            sender.setTranslation(window.center, in: window)
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn) {
                sender.view!.frame = self.clickedImageFrame
                //sender.view!.contentMode = .scaleAspectFill
                sender.view!.layer.cornerRadius = 10
               self.vxView.effect = nil
            }
            animator.pauseAnimation()
            animator.addCompletion({ (animPosition) in
                if animPosition == UIViewAnimatingPosition.end{
                    sender.view!.removeFromSuperview()
                    self.vxView.removeFromSuperview()
                }
            })
            return
        }
        let maxDistance:CGFloat = 300.0
        let translation = sender.translation(in: window)
        let delta = window.center.y - translation.y
        if sender.state == .changed{
            if delta >= 0 {
                
                let distanceMoved = min(delta, maxDistance)
                let fraction = distanceMoved / maxDistance
                print(fraction)
                animator.fractionComplete = fraction
//                self.vxView.layer.timeOffset = CFTimeInterval(fraction)
                
            }else{
                animator.fractionComplete = 0
                
            }
            
        }
        
        if sender.state == .ended{
            if delta > 50{
                //animator.fractionComplete = 0
                animator.startAnimation()
            }else{
                animator.isReversed = true
                animator.startAnimation()
            }
            
        }
    
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

extension PostsViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Cell for row called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textPostId, for: indexPath) as! TextPostCollectionViewCell
        let post = posts[indexPath.row]
        cell.setPostData(post)
//        print("Row \(indexPath.row)")
//        if let text = post.text{
//
//            cell.textView.text = text
////            let frame = CGRect(origin: CGPoint(x:10, y: 10), size: labelSize)
////            cell.textView.frame = frame
//            cell.textView.isHidden = false
//        }else{
//
//            cell.textView.isHidden = true
//
//        }
//
//        if let pictureName = post.pictureUrl {
//            let ref = Storage.storage().reference(withPath: "/images/\(pictureName)")
//            cell.imageView.sd_setImage(with: ref)
////            var frame = CGRect.zero
////            frame.size = imageSize
////            if labelSize.height > 0{
////                frame.origin.y = labelSize.height + 20
////            }
////            cell.imageView.frame = frame
////            print("ImageView Frame \(frame)")
//            cell.imageView.isHidden = false
//        }else{
//            cell.imageView.isHidden = true
//        }
       cell.postsVC = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let post = posts[indexPath.row]
        let (labelSize, imageSize) = sizeFor(post: post)
        var addedHeight:CGFloat = 0
        if post.text != nil{
            addedHeight = 24
        }
        return CGSize(width: imageSize.width, height: labelSize.height + imageSize.height + addedHeight)
        
    }
}
