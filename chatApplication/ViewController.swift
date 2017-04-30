//
//  ViewController.swift
//  chatApplication
//
//  Created by Игорь Талов on 30.04.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(handleLogOut))
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }
        
    }

    func handleLogOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }





}

