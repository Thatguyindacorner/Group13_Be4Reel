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
    
    @Published var signedInUser:UserData?
    
    @Published var friendsList: [FriendData] = []
    
    @Published var friendRequests: [FriendData] = []
    
    @Published var friendSearchList: [FriendData] = []
    
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
                    
                    DispatchQueue.main.sync {
                        self.friendsList.append(friend)
                    }
                    
                }
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
    
    
    
    
    //upload photo/video/status or whatever
    
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
