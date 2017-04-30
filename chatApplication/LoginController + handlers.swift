//
//  LoginController + handlers.swift
//  chatApplication
//
//  Created by Игорь Талов on 01.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        
        if let editImage = info["UIImagePickerControllerEditedImage"] {
            print(editImage)
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
               print(originalImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
