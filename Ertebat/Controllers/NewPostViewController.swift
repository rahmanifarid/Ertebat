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
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    var keyboardWillShowNotificationObserver:NSObjectProtocol?
    var keyboardWillHideNotificationObserver:NSObjectProtocol?
    var keyboardFrame:CGRect?
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func postPressed(_ sender: Any) {
        guard let listenerBlock = self.listener  else {
            print("No listener block in NewPostViewController")
            textView.resignFirstResponder()
            dismiss(animated: true, completion: nil)
            return
        }
        textView.resignFirstResponder()
        listenerBlock(textView.text, imageView.image)
        dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            self.dismiss(animated: true, completion: nil)
            })
        
    }
    typealias NewPostBlock = (String?, UIImage?)->()
    private var listener:NewPostBlock?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let closeButton = UIImageView()
        closeButton.frame = CGRect(x: 8, y: 8, width: 32, height: 32)
        closeButton.image = #imageLiteral(resourceName: "close_flat copy")
        closeButton.alpha = 0.75
        closeButton.contentMode = .scaleAspectFit
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageRemoveButtonPress(_:))))
        imageView.addSubview(closeButton)
//        self.view.backgroundColor = UIColor.clear
//        self.view.isOpaque = false
        textView.layer.cornerRadius = 10
        textView.delegate = self
        keyboardFrame = CGRect.zero
        
        // Do any additional setup after loading the view.
    }
    
    @objc func imageRemoveButtonPress(_ sender:UIImageView){
        imageHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.alpha = 0
            self.scrollView.layoutIfNeeded()
        }, completion:{(finished)
            in
            self.imageView.image = nil
            self.imageView.alpha = 1.0
            self.textView.becomeFirstResponder()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let keyboardShow = self.keyboardWillShowNotificationObserver{
            NotificationCenter.default.removeObserver(keyboardShow)
        }
        if let keyboardHide = self.keyboardWillHideNotificationObserver{
            NotificationCenter.default.removeObserver(keyboardHide)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardWillShowNotificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (notification) in
            if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                self.keyboardFrame = keyboardFrame
                self.scrollView.contentSize.height += keyboardFrame.height
                //self.scrollToCurserPosition()
                //self.scrollToPositionCalled = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {self.scrollToCurserPosition()})
            }
            
        }
        
        keyboardWillHideNotificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: { (notification) in
            print("Keyboard will hide is actually called")
            var height = 8 + self.textViewHeightConstraint.constant + 17
            if self.imageHeightConstraint.constant > 0{
                height += self.imageHeightConstraint.constant + 17
            }
            let defaultHeight = self.view.bounds.size.height - self.view.safeAreaInsets.top
            self.scrollView.contentSize.height = max(height, defaultHeight)
        })
    }
    
    func add(listener:@escaping NewPostBlock) {
        self.listener = listener
    }
    
    func scrollToCurserPosition(){
        var rectToScrollTo = CGRect.zero
        if let curserPosition = textView.selectedTextRange{
            print("curser position \(curserPosition)")
            rectToScrollTo = textView.caretRect(for: curserPosition.start)
            rectToScrollTo = scrollView.convert(rectToScrollTo, from: textView)
            print("contentOffset: \(scrollView.contentOffset)")
            print("rect to scroll to: \(rectToScrollTo)")
            rectToScrollTo.origin.y += keyboardFrame!.size.height
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.scrollView.scrollRectToVisible(rectToScrollTo, animated: false)
            }, completion: nil)
            
            
        }
    }
    lazy var accView:UIView = {
        let accView = UIView(frame: CGRect(x:0, y: self.view.bounds.height - 44, width: self.view.bounds.width, height: 54))
        accView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        let button = UIImageView()
        button.isUserInteractionEnabled = true
        button.contentMode = .scaleAspectFit
        button.image = #imageLiteral(resourceName: "camera-256")
        
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.translatesAutoresizingMaskIntoConstraints = false
       
        accView.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        let margin = accView.layoutMargins
        button.centerXAnchor.constraint(equalTo: accView.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: accView.centerYAnchor, constant: 0).isActive = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePicture(_:))))
        
        return accView
    }()
    override var inputAccessoryView: UIView?{
        return accView
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func takePicture(_ sender:UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
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

// MARK: - TextViewDelegate
extension NewPostViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: view.bounds.size.width - 16, height: .infinity))
//        let maxHeight = view.bounds.size.height - 8 - view.safeAreaInsets.top - keyboardFrame!.size.height
        scrollView.contentSize.height = max(scrollView.contentSize.height, size.height + keyboardFrame!.size.height)
        viewHeight.constant = max(scrollView.contentSize.height, size.height + keyboardFrame!.size.height)
        textViewHeightConstraint.constant = size.height
        
        //let selectedRange = textView.selectedRange
        
        self.view.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        scrollToCurserPosition()
//        if let curserPosition = textView.selectedTextRange{
//            print("curser position \(curserPosition)")
//            rectToScrollTo = textView.caretRect(for: curserPosition.start)
//            rectToScrollTo = scrollView.convert(rectToScrollTo, from: textView)
//            print("contentOffset: \(scrollView.contentOffset)")
//            print("rect to scroll to: \(rectToScrollTo)")
//            rectToScrollTo.origin.y += keyboardFrame!.size.height
//            self.scrollView.scrollRectToVisible(rectToScrollTo, animated: true)
//
//        }
        
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
//        if scrollToPositionCalled{
//            scrollToPositionCalled = false
//            return
//        }
        scrollToCurserPosition()
    }
}

extension NewPostViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let imageW = UIScreen.main.bounds.width - 16
            let height = (imageW * image.size.height) / image.size.width
            imageHeightConstraint.constant = height
            imageView.image = image
            imageView.layer.cornerRadius = 10
            scrollView.layoutIfNeeded()
        }
    }
}
