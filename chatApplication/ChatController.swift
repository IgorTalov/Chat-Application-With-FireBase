//
//  ChatController.swift
//  chatApplication
//
//  Created by Игорь Талов on 01.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
 
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
        
        observeMessanges()
    }
    
    func observeMessanges() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictinary = snapshot.value as? [String: AnyObject] {
                   let message = Message()
                   message.setValuesForKeys(dictinary)
                    
                    if message.chatPartnerId() == self.user?.id {
                        self.messages.append(message)
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    //MARK: Setup Views
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    }

    //MARK: Actions
    
    func handleSendMessage() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text": "Test message for test bubbles"/*inputTextField.text!*/, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
               print("\(error)")
               return
            }
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
        }
    }

    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    //MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        
        return cell
    }
    
     //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}
