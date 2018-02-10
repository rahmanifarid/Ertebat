//
//  ViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/29/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class LoginSignUpViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var switchLoginState: UIButton!
    @IBOutlet weak var loginMessage: UILabel!
    @IBOutlet weak var loginSignUpButton: UIButton!
    var loginState = true
    
    @IBAction func loginOrSignup(_ sender: Any) {
        guard let emailText = email.text, let passwordText = password.text else {
            return
        }
        if loginState == false{
            Auth.auth().createUser(withEmail: emailText, password: passwordText, completion: { (usr, err) in
                if let error = err{
                    self.present(UIAlertController.createAlert(title:"Error", message: error.localizedDescription), animated: true, completion: nil)
                    
                }else{
                    print("User Created successfully")
                    Messages.shared.initialize()
                    self.performSegue(withIdentifier: "chooseAName", sender: nil)
                    
                    
                }
            })
        }else{
            Auth.auth().signIn(withEmail: emailText, password: passwordText, completion: { (usr, err) in
                if let error = err{
                    self.present(UIAlertController.createAlert(title:"Error", message: error.localizedDescription), animated: true, completion: nil)
                }else{
                    print("Sign in successful")
                    Messages.shared.initialize()
                    self.performSegue(withIdentifier: "mainInterface", sender: nil)
                }
            })
        }
    }
    
    
    @IBAction func switchLoginState(_ sender: Any) {
        if loginState{
            loginState = false
            loginSignUpButton.setTitle("SIGN UP", for: .normal)
            switchLoginState.setTitle("LOG IN", for: .normal)
        }else{
            loginState = true
            loginSignUpButton.setTitle("LOG IN", for: .normal)
            switchLoginState.setTitle("CREATE ACCOUNT", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIAlertController{
    static func createAlert(title:String, message:String)->UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}

//public func createAlert(_ title:String, message:String)-> UIViewController {
//    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//    alert.addAction(action)
//    return alert
//}



