//
//  ProfileViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/1/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var user: User!
    
    
    
    @IBAction func sendMessageButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messageThread = storyboard.instantiateViewController(withIdentifier: "messageThreadController") as! MessageThreadController
        messageThread.user = user
        navigationController?.pushViewController(messageThread, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("User is \(user)")
        // Do any additional setup after loading the view.
        //let url = URL(string:user.profileUrl!)
        
    }
    var nameObservation:NSKeyValueObservation?
    var imageObservation:NSKeyValueObservation?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = user.profileImage
        nameLabel.text = user.name
        navigationController?.isNavigationBarHidden = false
        nameObservation = user.observe((\.name), changeHandler: { (user, change) in
            self.nameLabel.text = user.name
        })
        imageObservation = user.observe((\.profileImage), changeHandler: { (user, change) in
            self.imageView.image = user.profileImage
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
        nameObservation?.invalidate()
        imageObservation?.invalidate()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        imageView.image = image
//        nameLabel.text = name
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
