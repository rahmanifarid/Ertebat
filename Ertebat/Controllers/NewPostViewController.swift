//
//  NewPostViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/30/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class NewPostViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBAction func postPressed(_ sender: Any) {
        guard let postText = textView.text else {
            return
        }
        var post:[String: Any] = ["text": postText]
        post["author"] = "SomeAuthor"
        post["authorId"] = Auth.auth().currentUser?.uid
        post["date"] = NSDate()
        Firestore.firestore().collection("posts").addDocument(data: post)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
