//
//  ChatMessageCell.swift
//  chatApplication
//
//  Created by Игорь Талов on 09.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "TEST TEXT"
        tv.isEditable = false
        tv.backgroundColor = UIColor.lightGray
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = UIColor.orange
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(textView)
        
        textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
}
