//
//  DatabaseConnection.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseConnection: ObservableObject{
    
    @Published var showProgressView:Bool = false
    
    static var shared = DatabaseConnection()
    
    var linked: Bool = false
    
    @Published var user:User?{
        
        didSet{
            objectWillChange.send()
        }
        
    }
    
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
    
    @Published var signedInUser:UserData?
    
    @Published var upload: UploadData?
    
    @Published var friendsList: [FriendData] = []
    
    @Published var friendRequests: [FriendData] = []
    
    @Published var friendSearchList: [FriendData] = []
    
    private init(){}
    
    
    func listenToAuthState(){
        
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            
            guard let self = self else{
                //No Change in Auth State
                return
                
            }
            
            self.user = user
            
        }
        
    }//listenToAuthState()
    
    
    
    //functions for firebase operations
    @MainActor
    func loginWithCredentials(withEmail userEmail:String, withPassword userPass: String) async throws -> Bool{
        
        self.showProgressView = true
        
        let authDataResult = try await Auth.auth().signIn(withEmail: userEmail, password: userPass)
        
        let uid = authDataResult.user.uid
        
        let reference = Firestore.firestore().collection("Users").document(uid)
        
        let userData = try await reference.getDocument(as: UserData.self)
            
        self.user = authDataResult.user
        self.signedInUser = userData
        
        await self.getFriendsList()
        
        await self.getFriendRequests()
        
        self.showProgressView = false
        self.loggedIn = true
            
    
    if(self.signedInUser == nil){
        return false
    }
    return true
    }//loginWithCredentials
    
    
    @MainActor
    func signUpWithCredentials(firstName:String, lastName:String, emailAdd:String, passwd:String) async throws-> Bool{
        
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
            
            self.loggedIn = true
            
            self.showProgressView = false
            
        }
        
        await self.getFriendsList()
        
        await self.getFriendRequests()
        
        if(self.signedInUser == nil){
            return false
        }
        return true
    }//signUpWithCredentials
    
    
    func signOut(){
        
        do{
           try Auth.auth().signOut()
            self.loggedIn = false
            self.user = nil
            
            self.signedInUser = nil
            self.friendsList = []
            self.friendRequests = []
            self.friendSearchList = []
            self.upload = nil
        }catch{
            print("Error signing out")
        }
        
    }//signOut
    
    
    func changePassword(newPassword:String) async{
        
        let user = Auth.auth().currentUser
        
        if(user != nil){
            print("User is not nil")
        }
        
            guard let userPassword = self.signedInUser?.password else{
                print("User is nil")
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: userPassword)
            
            user?.reauthenticate(with: credential, completion: { (authResult, error) in
                if let error = error {
                    
                    print("Error while reauthenticating, \(error.localizedDescription)")
                    return
                }
                user?.updatePassword(to: newPassword, completion: { (error) in
                    if let error = error {
                        
                        print("Error while updating password \(error.localizedDescription)")
                        return
                    }
                    
                    self.user = user
                    
                    print("Password updated successfully")
                })
            })
    
    } //changePassword
    
    
    
    
    
    
    
    //get user info (call on refresh)

        //get friends list
        func getFriendsList() async -> Bool{
            DispatchQueue.main.sync {
                self.friendsList = []
            }
            
            guard db != nil
            else{
                Swift.print("No connection to database. May be no internet connection")
                return false
            }
            
            let users = db!.collection("Users")
            
            do{
                for friendID in signedInUser!.friendsList{
                    guard let friendDoc = try await users.document(friendID).getDocument().data()
                    else {
                        print("error getting friendID: \(friendID) from database")
                        return false
                    }
                    
                    let friend = FriendData()
                    
                    friend.firstName = friendDoc["firstName"] as! String
                    friend.lastName = friendDoc["lastName"] as! String
                    friend.profilePic = friendDoc["profilePic"] as! String
                    friend.uid = friendID
                    friend.relationship = .friend
                    
                    do{
                        let user = try await db!.collection("Users").document(friendID).collection("upload").getDocuments()
                        if user.isEmpty{
                            print("collection is empty")
                            friend.upload = nil
                        }
                        else{
                            do{
                                friend.upload = try user.documents[0].data(as: UploadData.self)
                                print("Friend Upload: \(friend.upload)")
                            }
                            catch{
                                print("could not decode")
                                friend.upload = nil
                            }
                            
                        }
                    }
                    catch{
                        print("no upload collection")
                        friend.upload = nil
                    }
                    
                    DispatchQueue.main.sync {
                        self.friendsList.append(friend)
                    }
                    
                }
                print(self.friendsList)
                print("done converting")
            }
            catch{
                print("error converting friends list")
                return false
            }
            
            print("returning true")
            return true
            
        }
    
        //get list of friends who posted
    
        //get list of friend requests
        func getFriendRequests() async -> Bool{
            DispatchQueue.main.sync {
                self.friendRequests = []
            }
            
            guard db != nil
            else{
                Swift.print("No connection to database. May be no internet connection")
                return false
            }
            
            let users = db!.collection("Users")
            
            do{
                for requestID in signedInUser!.friendRequests{
                    guard let requestDoc = try await users.document(requestID).getDocument().data()
                    else {
                        print("error getting requestID: \(requestID) from database")
                        return false
                    }
                    
                    let potentialFriend = FriendData()
                    
                    potentialFriend.firstName = requestDoc["firstName"] as! String
                    potentialFriend.lastName = requestDoc["lastName"] as! String
                    potentialFriend.profilePic = requestDoc["profilePic"] as! String
                    potentialFriend.uid = requestID
                    potentialFriend.relationship = .recievedRequest
                    
                    DispatchQueue.main.sync {
                        self.friendRequests.append(potentialFriend)
                    }
                    
                }
                print("done converting")
            }
            catch{
                print("error converting request list")
                return false
            }
            
            print("returning true")
            return true
            
        }
    
    func checkIfPost() async -> Bool{
            
            guard db != nil
            else{
                Swift.print("No connection to database. May be no internet connection")
                return false
            }
            
            let user = db!.collection("Users").document(signedInUser!.uid).collection("upload")
            
            do{
                let docs = try await user.getDocuments().documents
                guard !docs.isEmpty
                else{
                    print("collection is empty")
                    return false
                }
                
                let data = try docs[0].data(as: UploadData.self)
                
                print("User Upload: \(data)")
                
                //add a day to .time and compare if current date is still earlier
                print("expiry date: \(data.time!.addingTimeInterval(86400))")
                print(Date.now)
                if data.time!.addingTimeInterval(86400) < Date.now{
                    //delete upload from database
                    do{
                        try await user.document(data.id!).delete()
                        print("outdated upload deleted")
                        return false
                    }
                    
                    catch{
                        print("could not delete past upload")
                    }
                }
                
                DispatchQueue.main.sync{
                    self.upload = data
                }
                print("got upload")
            }
            
            catch{
                print("could not get documents or decode")
                return false
            }
            
            
            print("returning")
            return true
        }
        
        //upload photo/video/status or whatever
        func uploadPost(upload: UploadData) async -> Bool{
            
            guard db != nil
            else{
                Swift.print("No connection to database. May be no internet connection")
                return false
            }
            
            let users = db!.collection("Users")
            
            //try JSONEncoder().encode(upload)
            
            do{
                try users.document(signedInUser!.uid).collection("upload").document(signedInUser!.uid).setData(from: upload.self)
                print("successfully uploaded")
            }
            
                    
            catch{
                print("some error happened")
                return false
            }
            return true
        }

    
    //search for users
    func searchForUsers(withKeyPhrase: String, save: Bool) async -> Bool{
        
        print("in search")
        
        DispatchQueue.main.sync {
            self.friendSearchList = []
        }
        
        
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            let query = try await users.whereField("searchTerms", arrayContains: withKeyPhrase.lowercased()).getDocuments()
            //let query = try await patients.whereField("healthCard", isEqualTo: withHealthCardNumber).getDocuments()
            
            guard !query.isEmpty
            else{
                print("query empty")
                return false
                
            }
            
            var potentialFriendList: [FriendData] = []
            for result in query.documents{
                let potentialFriend = FriendData()
                
                potentialFriend.firstName = result.data()["firstName"] as! String
                potentialFriend.lastName = result.data()["lastName"] as! String
                potentialFriend.profilePic = result.data()["profilePic"] as! String
                potentialFriend.uid = result.data()["uid"] as! String
                
//                guard signedInUser != nil
//                else{
//                    print("error, user need to be signed in")
//                    return false
//                }
                if signedInUser!.uid == potentialFriend.uid{
                    //potentialFriend.relationship = .me
                    print("skipping myself")
                }
                else{
                    if signedInUser!.friendsList.contains(potentialFriend.uid){
                        potentialFriend.relationship = .friend
                    }
                    else if signedInUser!.friendRequests.contains(potentialFriend.uid){
                        potentialFriend.relationship = .recievedRequest
                    }
                    else if try await (users.document(potentialFriend.uid).getDocument().data()!["friendRequests"] as! [String]).contains(signedInUser!.uid){
                        potentialFriend.relationship = .sentRequest
                    }
                    else {
                        potentialFriend.relationship = .noRelation
                    }
                    potentialFriend.setID()
                    DispatchQueue.main.sync{
                        self.friendSearchList.append(potentialFriend)
                    }
                }
                
                //potentialFriendList.append(potentialFriend)
            }

            Swift.print("done query")
        }
        catch{
            Swift.print("error finding user. May not exist")
            return false
        }
        
            
        
            Swift.print("returning now")
            return true
        }
    
    //send friend request
    func sendFriendRequest(toUserID: String) async -> Bool{
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            try await users.document(toUserID).updateData(["friendRequests": FieldValue.arrayUnion([signedInUser!.uid])])
            print("request sent")
        }
        catch{
            print("error sending request")
            return false
        }
        print("returning")
        return true
    }
    
    //remove sent request
    func removeSentRequest(requestID: String) async -> Bool{
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            try await users.document(requestID).updateData(["friendRequests": FieldValue.arrayRemove([signedInUser!.uid])])
            print("request removed")
        }
        catch{
            print("error removing request")
            return false
        }
        print("returning")
        return true
    }
    
    //remove friend request
    func removeFriendRequest(requestID: String) async -> Bool{
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            try await users.document(signedInUser!.uid).updateData(["friendRequests": FieldValue.arrayRemove([requestID])])
            print("request removed")
            
            DispatchQueue.main.sync {
                for friend in self.signedInUser!.friendRequests{
                    if friend == requestID{
                        self.signedInUser!.friendRequests.remove(at: self.signedInUser!.friendRequests.firstIndex(of: friend)!)
                        break
                    }
                }
            }
        }
        catch{
            print("error removing request")
            return false
        }
        print("returning")
        return true
    }
    
    //accept friend request
    func acceptFriendRequest(fromUserID: String) async -> Bool{
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            try await users.document(signedInUser!.uid).updateData(["friendRequests": FieldValue.arrayRemove([fromUserID])])
            try await users.document(signedInUser!.uid).updateData(["friendsList": FieldValue.arrayUnion([fromUserID])])
            try await users.document(fromUserID).updateData(["friendsList": FieldValue.arrayUnion([signedInUser!.uid])])
            print(self.friendsList)
            DispatchQueue.main.sync {
                for friend in self.signedInUser!.friendRequests{
                    if friend == fromUserID{
                        self.signedInUser!.friendsList.append(friend)
                        self.signedInUser!.friendRequests.remove(at: self.signedInUser!.friendRequests.firstIndex(of: friend)!)
                        break
                    }
                }
            }
            print(self.friendsList)
            print("request accepted")
        }
        catch{
            print("error accepting request")
            return false
        }
        print("returning")
        return true
    }
    
    //remove friend
    func removeFriend(exFriendID: String) async -> Bool{
        guard db != nil
        else{
            Swift.print("No connection to database. May be no internet connection")
            return false
        }
        
        let users = db!.collection("Users")
        
        do{
            try await users.document(signedInUser!.uid).updateData(["friendsList": FieldValue.arrayRemove([exFriendID])])
            try await users.document(exFriendID).updateData(["friendsList": FieldValue.arrayRemove([signedInUser!.uid])])
            print(self.friendsList)
            DispatchQueue.main.sync {
                for friend in self.signedInUser!.friendsList{
                    if friend == exFriendID{
                        self.signedInUser!.friendsList.remove(at: self.signedInUser!.friendsList.firstIndex(of: friend)!)
                        break
                    }
                }
            }
            print(self.friendsList)
            print("friend removed")
        }
        catch{
            print("error removing friend")
            return false
        }
        print("returning")
        return true
    }
    
    
    //view message log (using snapshot listener for live updates)
    
    //send message
}
