//
//  Message.swift
//  chatApplication
//
//  Created by Игорь Талов on 07.05.17.
//  Copyright © 2017 Игорь Талов. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId!
        } else {
            return fromId!
        }
    }
    
}
