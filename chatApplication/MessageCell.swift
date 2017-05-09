//
//  MessageCell.swift
//  chatApplication
//
//  Created by Игорь Талов on 08.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {
    
    var message: Message? {
        didSet{
            setupNameAndProfileImage()
            
            messageLabel.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue {
               let timeStampDate = NSDate(timeIntervalSince1970: seconds)
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "HH:mm a"
                
               let dateString = dateFormatter.string(from: timeStampDate as Date)
               timeLabel.text = dateString
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictinary = snapshot.value as? [String: AnyObject] {
                    print(snapshot)
                    
                    self.nameLabel.text = dictinary["name"] as? String
                    
                    if let profileImageUrl = dictinary["profileImageURL"] as? String {
                        self.iconImageView.loadImageUsingUrlString(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Message Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:mm"
        label.textColor = UIColor.darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(timeLabel)
        addSubview(iconImageView)
        
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: -10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: 8).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        messageLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 8).isActive = true
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8).isActive = true
        
    }
    
}
