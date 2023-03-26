//
//  FireDBUserHelper.swift
//  Group13_Be4Reel
//
//  Created by Ameya Joshi on 2023-03-25.
//

import Foundation
import FirebaseFirestore


class FireDBUserHelper:ObservableObject{
    
    private let store = Firestore.firestore()
    
    
    static let sharedFireDBHelper = FireDBUserHelper()
    
    private let COLLECTION_USERS = "Users"
    
    
    
    
    private init(){}
    

    func insertUser(newUserData:UserData) async throws{
        
        try store.collection(COLLECTION_USERS).document(newUserData.uid).setData(from: newUserData){ err in
            
            if let err = err{
                
                print("😡 Error during insert operation \(err.localizedDescription)")
                
                return
            }else{
                print("😎 Users collection created for DOC ID: \(newUserData.uid)")
            }
        }
    }
    
    
    
}

