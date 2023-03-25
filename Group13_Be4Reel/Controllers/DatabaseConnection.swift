//
//  DatabaseConnection.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import Foundation
import FirebaseFirestore

class DatabaseConnection: ObservableObject{
    
    static var shared = DatabaseConnection()
    
    var linked: Bool = false
    
    var db: Firestore?{
        get{
            if linked{
                return Firestore.firestore()
            }
            else{
                return nil
            }
        }
    }
    
    @Published var loggedIn: Bool = false
    
    private init(){}
    
    
    //functions for firebase operations
    func loginWithCredentials(username: String, password: String) async -> Bool{
        
        //try to login
        //return false if fail
        
        return true
    }
    
    func signUpWithCredentials(username: String, password: String) async -> Bool{
        
        //try to signUp
        //return false if fail
        
        //create user with userID attached
        //return false if fail
        
        return true
    }
    
    //get user info (call on refresh)

        //get friends list
    
        //get list of friends who posted
    
        //get list of friend requests
    
    
    
    
    //upload photo/video/status or whatever
    
    //send friend request
    
    //accept friend request
    
    //view message log (using snapshot listener for live updates)
    
    //send message
}
