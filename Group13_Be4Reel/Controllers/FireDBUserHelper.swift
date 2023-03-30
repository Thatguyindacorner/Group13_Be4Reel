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
    }//insertNewUser
    
    
    func updateUserProfileInfo(userToUpdate:UserData) async throws{
        
//       try await store.collection("Users")
//            .document(userToUpdate.uid)
//            .setData(["firstName" : userToUpdate.firstName,
//                      "lastName": userToUpdate.lastName,
//                      "password": userToUpdate.password])
         
      try await store.collection("Users").document(userToUpdate.uid)
            .updateData(["firstName" : userToUpdate.firstName,
                        "lastName": userToUpdate.lastName,
                        "password": userToUpdate.password])
        

    }//updateUserProfileInfo()
    
    
    func getUserData(userData:UserData) async -> UserData?{
        
        do{
            let userData =   try await self.store.collection("Users")
                .document(userData.uid)
                .getDocument()
                .data(as: UserData.self)
            
            return userData
        }catch {
           print("Error retrieving doc data")
            return nil
        }
       
    }
    
    
    
    
}

