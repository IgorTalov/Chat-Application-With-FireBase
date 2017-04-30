//
//  ViewController.swift
//  chatApplication
//
//  Created by Игорь Талов on 30.04.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(handleLogOut))
    }

    func handleLogOut() {
        print("log out")
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }





}

