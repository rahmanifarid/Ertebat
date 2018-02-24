//
//  EditProfileViewController.swift
//  Ertebat
//
//  Created by Farid Rahmani on 2/23/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var user:User!
    @IBOutlet weak var imageView: UIImageView!
    var pickedImageData:Data?
    @IBAction func editProfilePress(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        let alertView = UIAlertController(title: "Change profile image", message: nil, preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Take photo", style: .default) { (action) in
            imagePicker.sourceType = .camera
        }
        alertView.addAction(actionCamera)
        
        let actionPhotoGallary = UIAlertAction(title: "Choose from photo library", style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertView.addAction(actionPhotoGallary)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            imagePicker.dismiss(animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertView.addAction(actionCancel)
        present(alertView, animated: true, completion: nil)
        
    }

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = user.profileImage
        nameTextField.text = user.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveInfo(_ :)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit(_ :)))

    }
    @objc func saveInfo(_ sender:Any){
        let nameText = nameTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: "\n \t\r"))
        if nameText?.count == 0{
            let alert = UIAlertController.createAlert(title: "Name can't be empty", message: "Please enter a name in the name field.")
            present(alert, animated: true, completion: nil)
            return
        }
        if pickedImageData != nil{
            
            let ref = Storage.storage().reference()
            let userUID = Auth.auth().currentUser?.uid
            let filename = "\(UUID().uuidString).jpg"
            let fileRef = ref.child(filename)
            let uploadTask = fileRef.putData(pickedImageData!)
            uploadTask.observe(.progress) { (snapshot) in
                let percentage = Int(100 * snapshot.progress!.fractionCompleted)
                //self.percentageUploaded.text = "\(percentage)%"
            }
            uploadTask.observe(.success) { (snapshot) in
                if let meta = snapshot.metadata{
                    print("Upload successful")
                    let profileUrl = meta.downloadURL()!
                    Firestore.firestore().collection("users").document(userUID!).updateData(["name": nameText!, "profileURL" : profileUrl.absoluteString, "id" : userUID!], completion: { (err) in
                        if let error = err{
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                                self.saveInfo(action)
                            })
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    
                    
                }
            }
        }else{
            Firestore.firestore().collection("users").document(user.id!).updateData(["name": nameText!], completion: { (err) in
                if let error = err{
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                        self.saveInfo(action)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        
    }
    @objc func cancelEdit(_ sender:Any){
        navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
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

extension EditProfileViewController{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let resized = image.resizeWithWidth(width: UIScreen.main.bounds.width * 2) {
            self.imageView.image = image
            let compressed = UIImageJPEGRepresentation(resized, 0.8)
            self.pickedImageData = compressed
            
        }
    }
}
