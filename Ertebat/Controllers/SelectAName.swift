//
//  SelectAName.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/31/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class SelectAName: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func nextButtonPress(_ sender: Any) {
        guard nameField.text != nil else{
            return
        }
        
        performSegue(withIdentifier: "chooseAProfilePicture", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseAProfilePicture" {
            let target = segue.destination as! SelectAProfilePicture
            target.name = nameField.text!
            print("target.name \(target.name) and nameField.text \(nameField.text!)")
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
