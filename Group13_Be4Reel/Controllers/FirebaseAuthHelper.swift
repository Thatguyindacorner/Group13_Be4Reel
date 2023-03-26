//
//  FirebaseAuthHelper.swift
//  Group13_Be4Reel
//
//  Created by Ameya Joshi on 2023-03-25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class FirebaseAuthHelper:ObservableObject{
    
    @Published var showProgressView:Bool = false
    
    @Published  var isLoggedIn:Bool = false
    
    @Published var signedInUser:UserData?
    
    @Published var user:User?{
        
        didSet{
            objectWillChange.send()
        }
        
    }
    
    //static var fireAuthShared = FirebaseAuthHelper()
    
   // private init(){}
    
    func listenToAuthState(){
        
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            
            guard let self = self else{
                //No Change in Auth State
                return
                
            }
            
            self.user = user
            
        }
        
    }//listenToAuthState()
    
    @MainActor
    func signupUser(firstName:String, lastName:String, emailAdd:String, passwd:String) async throws -> Bool{
        
        self.showProgressView = true
        
        let authDataResult = try await Auth.auth().createUser(withEmail: emailAdd, password: passwd)
        
        let uid = authDataResult.user.uid
        
        let tempUser = UserData(uid: uid, firstName: firstName, lastName: lastName, email: emailAdd, password: passwd)
        
        UserDefaults.standard.set(authDataResult.user.email, forKey: "KEY_EMAIL")
        
        UserDefaults.standard.set(uid, forKey: "KEY_USER_ID")
        
        UserDefaults.standard.set(passwd, forKey: "USER_PASSWORD")
        
        let reference = Firestore.firestore().collection("Users").document(uid)
        
        self.signedInUser = tempUser
        
        self.user = authDataResult.user
        
        do{
            
           let userData =  try await reference.getDocument(as: UserData.self)
            
//            self.signedInUser = userData
            
        }catch{
            
            let reference = Firestore.firestore().collection("Users").document(uid)
            
            try reference.setData(from: tempUser){ err in
                
            }
            
            self.isLoggedIn = true
            
            self.showProgressView = false
            
        }
        if(self.signedInUser == nil){
            return false
        }
        return true
    }//signUpUser
    
    
    @MainActor
    func signInUser(withEmail userEmail:String, withPassword userPass: String) async throws -> Bool{
        
  
            self.showProgressView = true
            
            let authDataResult = try await Auth.auth().signIn(withEmail: userEmail, password: userPass)
            
            let uid = authDataResult.user.uid
            
            let reference = Firestore.firestore().collection("Users").document(uid)
            
            let userData = try await reference.getDocument(as: UserData.self)
                
            self.user = authDataResult.user
            self.signedInUser = userData
                
            self.showProgressView = false
            self.isLoggedIn = true
                
        
        if(self.signedInUser == nil){
            return false
        }
        return true
        
        
    }
    
    
}
