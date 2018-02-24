//
//  SelfProfileViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/23/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class SelfProfileViewController: ProfileViewController {
    
    
    @IBAction func editProfilePress(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let editProfileVC = storyBoard.instantiateViewController(withIdentifier: "editProfileViewController") as! EditProfileViewController
        editProfileVC.user = user
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    
    @IBOutlet weak var bioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfile"{
            let destinationVC = segue.destination as! EditProfileViewController
            destinationVC.user = user
        }
    }
    

}
