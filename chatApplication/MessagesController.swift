//
//  ViewController.swift
//  chatApplication
//
//  Created by Игорь Талов on 30.04.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    let cellId = "cellID"
    
    var messages = [Message]()
    var messagesDictinary = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogOut))
        let image = UIImage(named: "plane")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMeessage))
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        
        observeUserMessages()
    }

    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictinary = snapshot.value as? [String : AnyObject] {
                    
                    print("\(snapshot)")
                    
                    let message = Message()
                    message.setValuesForKeys(dictinary)
                    
                    if let chatPartnerId = message.chatPartnerId() as String! {
                        self.messagesDictinary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictinary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictinary = snapshot.value as? [String : AnyObject] {
                
               print("\(snapshot)")
                
               let message = Message()
               message.setValuesForKeys(dictinary)
                
                if let toId = message.toId {
                   self.messagesDictinary[toId] = message
                    
                   self.messages = Array(self.messagesDictinary.values)
                   self.messages.sort(by: { (message1, message2) -> Bool in
                    return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                   })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        }, withCancel: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (snapshot, str) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dict)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        
        messages.removeAll()
        messagesDictinary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = CustomImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        if let profileImageUrl = user.profileImageURL {
            profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        }
        
        titleView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(nameLabel)
        
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatControllerForUser(user: User) {
        print(123)
        let layout = UICollectionViewFlowLayout()
        let chatController = ChatController(collectionViewLayout: layout)
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func handleLogOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }

    func handleNewMeessage() {
        print("new message")
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }

    //MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = messages[indexPath.row]

        let chatPartnerId = message.chatPartnerId()
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictinary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = chatPartnerId
                user.setValuesForKeys(dictinary)
                
                self.showChatControllerForUser(user: user)
            }
            
        }, withCancel: nil)

    }
    
}

