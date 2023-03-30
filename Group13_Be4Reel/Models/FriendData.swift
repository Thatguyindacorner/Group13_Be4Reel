//
//  FriendData.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-27.
//

import Foundation

enum RelationshipType: String{
    //case me = 0
    case friend = "1"
    case sentRequest = "2"
    case recievedRequest = "3"
    case noRelation = "4"
}

class FriendData: Identifiable{

    
    var id: String = ""
    
    //var  = UUID()
    
    var uq = UUID()
    
    var uid:String = ""
    
    var profilePic:String = ""
    
    var firstName:String = ""
    
    var lastName:String = ""
 
    var relationship: RelationshipType = .noRelation
    
    var upload: UploadData?
    
    
    func setID(){
        self.id = "\(relationship.rawValue)\(firstName)"
    }
}
