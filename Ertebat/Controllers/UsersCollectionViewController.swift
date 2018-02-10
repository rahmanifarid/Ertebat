//
//  UsersCollectionViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/1/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class UsersCollectionViewController: UICollectionViewController {
    var users = [User]()
    var clickedCellFrame = CGRect.zero
    var clickedIndexPath:IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        //self.collectionView?.backgroundColor = UIColor.brown
        //let layout = UICollectionViewFlowLayout()
        //layout.itemSize = CGSize(width: 150, height: 150)
        //collectionView?.collectionViewLayout = layout
        loadUsers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UsersCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    
    
    func loadUsers() {
        Firestore.firestore().collection("users").getDocuments { (sshot, err) in
            if let error = err{
                let alert = UIAlertController.createAlert(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }
            
            if let snapShot = sshot{
                for doc in snapShot.documents{
                    let data = doc.data()
                    let user = User.createWith(data: data)
                    self.users.append(user)
                    
                }
                
                
                self.collectionView?.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileVC"{
            let profileVC = segue.destination as! ProfileViewController
            profileVC.user = users[clickedIndexPath!.row]
            profileVC.image = clickedImage
            profileVC.name = users[clickedIndexPath!.row].name
            
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UsersCollectionViewCell
        
         //Configure the cell
        let user = users[indexPath.row]
        let url = URL(string: user.profileUrl!)
        if let url = url, cell.imageView != nil{
            cell.imageView.sd_setImage(with: url, completed: nil)
        }
        if let label = cell.nameLabel{
            label.text = user.name
        }
        
        cell.userId = user.id!
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    var clickedImage:UIImage?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)
        clickedCellFrame = self.collectionView!.window!.convert(layoutAttributes!.frame, from: self.collectionView!)
        clickedIndexPath = indexPath
        let clickedCell = collectionView.cellForItem(at: indexPath) as! UsersCollectionViewCell
        clickedImage = clickedCell.imageView.image

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "profileVC")as! ProfileViewController
        profileVC.user = users[indexPath.row]
        profileVC.image = clickedImage
        profileVC.name = users[indexPath.row].name
        self.navigationController?.pushViewController(profileVC, animated: true)
//        self.performSegue(withIdentifier: "showProfile", sender: nil)
//        print("Item frame \(clickedCellFrame)")
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    

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

extension UsersCollectionViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromVCType = type(of: fromVC)
        let toVCType = type(of: toVC)
        let condition = fromVCType == ProfileViewController.self && toVCType == MessageThreadController.self || toVCType == ProfileViewController.self && fromVCType == MessageThreadController.self
        if condition{
            return nil
        }
        let animationController = AnimationController()
        animationController.cellFrame = clickedCellFrame
        animationController.presenting = (operation == .push)
        animationController.collectionView = collectionView
        return animationController
    }
}
class AnimationController:NSObject, UIViewControllerAnimatedTransitioning{
    var animationTime:TimeInterval = 0.5
    var presenting:Bool = true
    var cellFrame = CGRect.zero
    var collectionView:UICollectionView?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationTime
    }
    var usersTransform = CGAffineTransform.identity
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        guard let toView = toVC?.view, let fromView = fromVC?.view else{
            return
        }
        
        
        
        let usersView = presenting ? fromView : toView
        let profileView = presenting ? toView : fromView
        
        var initialFrame = presenting ? cellFrame : profileView.frame
        let finalFrame = presenting ? profileView.frame : cellFrame
        
        let initialFrameAspect = initialFrame.width / initialFrame.height
        let profileAspect = profileView.frame.width / profileView.frame.height
        if initialFrameAspect > profileAspect{
            initialFrame.size = CGSize(width: profileAspect * initialFrame.height, height: initialFrame.height)
        }else{
            initialFrame.size = CGSize(width: initialFrame.width, height: initialFrame.width / profileAspect)
        }
        
        var resizedFinalFrame = finalFrame
        let finalFrameAspect = finalFrame.width / finalFrame.height
        if finalFrameAspect > profileAspect{
            resizedFinalFrame.size = CGSize(width: profileAspect * finalFrame.height, height: finalFrame.height)
        }else{
            resizedFinalFrame.size = CGSize(width: finalFrame.width, height: finalFrame.width / profileAspect)
        }
        
        let scaleFactor = initialFrame.width / resizedFinalFrame.width
        let shrinkFactor = presenting ? scaleFactor : 1 / scaleFactor
        let growFactor = (presenting ? 1 / scaleFactor : scaleFactor) * 0.5
        
        if presenting{
            usersTransform = usersView.transform
            profileView.transform = CGAffineTransform(scaleX: shrinkFactor, y: shrinkFactor)
            profileView.center = CGPoint(x: cellFrame.midX, y: cellFrame.midY)
            profileView.alpha = 0
        }
        profileView.alpha = presenting ? 0 : 1
        collectionView!.alpha = presenting ? 1 : 0
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubview(toFront: profileView)
        transitionContext.containerView.backgroundColor = UIColor.white
        UIView.animate(withDuration: animationTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if self.presenting{
                profileView.alpha = 1
                self.collectionView!.alpha = 0
                
                profileView.transform = CGAffineTransform.identity
                
                
                let scale = CGAffineTransform(scaleX: growFactor, y: growFactor)
                let translate = self.collectionView?.transform.translatedBy(x: usersView.frame.midX - self.cellFrame.midX, y: usersView.frame.midY - self.cellFrame.midY)
                let transform = translate!.concatenating(scale)
                self.collectionView!.transform = transform
                
                
            }else{
                profileView.alpha = 0
                self.collectionView!.alpha = 1
                
                profileView.transform = CGAffineTransform(scaleX: shrinkFactor, y: shrinkFactor)
                self.collectionView!.transform = CGAffineTransform.identity
                
                
            }
            profileView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
        
    }
    
    
    
    
    
}
