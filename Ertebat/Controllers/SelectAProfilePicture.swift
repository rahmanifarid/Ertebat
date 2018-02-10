//
//  SelectAProfilePicture.swift
//  Ertebat
//
//  Created by Farid Rahmani on 1/31/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
class SelectAProfilePicture: UIViewController, UINavigationControllerDelegate {
    var imagePicked = false
    var profileUrl = ""
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var percentageUploaded: UILabel!
    @IBAction func nextButtonPress(_ sender: Any) {
        if imagePicked == false{
            return
        }
        let image = imageView.image!.resizeWithWidth(width: 128)
        let data = UIImagePNGRepresentation(image!)
        let ref = Storage.storage().reference()
        let userUID = Auth.auth().currentUser?.uid
        let filename = "\(userUID!).png"
        let fileRef = ref.child(filename)
        let uploadTask = fileRef.putData(data!)
        activityView.startAnimating()
        uploadTask.observe(.progress) { (snapshot) in
            let percentage = Int(100 * snapshot.progress!.fractionCompleted)
            self.percentageUploaded.text = "\(percentage)%"
        }
        uploadTask.observe(.success) { (snapshot) in
            if let meta = snapshot.metadata{
                print("Upload successful")
                let profileUrl = meta.downloadURL()!
                Firestore.firestore().collection("users").document(userUID!).setData(["name": self.name, "profileURL" : profileUrl.absoluteString, "id" : userUID!], completion: { (err) in
                    if let error = err{
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                            self.nextButtonPress(action)
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.performSegue(withIdentifier: "mainInterface", sender: nil)
                    }
                })
                
                
            }
        }
        
    }
    
    @IBAction func skipButtonPress(_ sender: Any) {
    }
    var name:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:))))
        print("Name is \(name)")
        // Do any additional setup after loading the view.
    }
    
    @objc func imageViewTapped(_ sender:UIImageView){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
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

extension SelectAProfilePicture: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        imagePicked = true
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = pickedImage
    }
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
