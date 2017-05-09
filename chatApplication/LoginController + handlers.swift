//
//  LoginController + handlers.swift
//  chatApplication
//
//  Created by Игорь Талов on 01.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print("\(error)")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authentificated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.2) {
            
//            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.2) {
            
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("\(error)")
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                       let values = ["name": name, "email": email, "profileImageURL": profileImageUrl]
                        
                       self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
//        let dbUrl = "https://chatapplication-cf55d.firebaseio.com/"
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print("\(err)")
                return
            }
            
            print("Saved user successfully into Firebase db")
            let user = User()
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFromPicker = editImage as? UIImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.layer.masksToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}
