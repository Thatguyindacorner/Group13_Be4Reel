//
//  UserData.swift
//  Group13_Be4Reel
//
//  Created by Ameya Joshi on 2023-03-25.
//

import Foundation

import Foundation
import FirebaseFirestoreSwift

struct UserData: Codable, Hashable{
    
   //@DocumentID var id: String? = UUID().uuidString
    
    var uid:String = ""
    
    var firstName:String = ""
    
    var lastName:String = ""
    
    var email:String = ""
    
    var password:String = ""
    
    
    init(uid:String, firstName:String, lastName:String, email:String, password:String){
        
        //self.id = id
        
        self.uid = uid
        
        self.firstName = firstName
        
        self.lastName = lastName
        
        self.email = email
        
        self.password = password
        
    }
    
    init(){
        
    }
    
    
//    init?(dictionary: [String:Any]){
//
//
//        guard let nUid = dictionary["uid"] as? String else{
//            print("Unable to read uid from the Object")
//            return nil
//        }
//
//        guard let fName = dictionary["firstName"] as? String else{
//            print("Unable to read firstName from the Object")
//            return nil
//        }
//
//        guard let lName = dictionary["lastName"] as? String else{
//            print("Unable to read lastName from the Object")
//            return nil
//        }
//
//        guard let uEmail = dictionary["email"] as? String else{
//            print("Unable to read email from the Object")
//            return nil
//        }
//
//        guard let uPassword = dictionary["password"] as? String else{
//            print("Unable to read password from the Object")
//            return nil
//        }
//
//       // self.init(id:nID, uid: nUid, firstName: fName, lastName: lName, email: uEmail, password: uPassword)
//
//        self.init(uid: nUid, firstName: fName, lastName: lName, email: uEmail, password: uPassword)
//    }
    
    
    
    
}
