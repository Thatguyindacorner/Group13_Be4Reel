//
//  FriendsTabView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

enum FriendSearchBy: String{
    case ALL = "friends list"
    case ADD = "for new friends"
}

struct FriendsTabView: View {
    
    @State var searchBy: FriendSearchBy = .ALL
    
    @State var searchText: String = ""
    
    @State var showResults = false
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var showAlert: Bool = false
    
    @State var titleAlert: String = ""
    @State var msgAlert: String = ""
    
    var body: some View {
        //Text("Friends")
        
        VStack(spacing: 25){
            Spacer()
            Text("Friends List").font(.headline)
            
            Picker(selection:$searchBy, label: Text("")){
                
                Text("All Friends")
                    .tag(FriendSearchBy.ALL).onAppear{
                        Task{
                            await database.getFriendsList()
                        }
                    }
                
                Text("Add Friends")
                    .tag(FriendSearchBy.ADD)
            }//Picker
            .pickerStyle(SegmentedPickerStyle())
            
            HStack{
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.5))
                TextField("Search \(searchBy.rawValue)", text: $searchText)
                    //.textFieldStyle(.roundedBorder)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            
            }//HStackEmail
            .padding(12)
            .background(.white)
            .overlay{
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
            }//Overlay
            
            switch searchBy {
            case .ALL:
                if database.friendsList.isEmpty{
                    Text("No Friends :(")
                }
                else{
                    List{
                        ForEach(database.friendsList, id: \.uid){ friend in
                            Button(action:{
                                titleAlert = "Friend: \(friend.firstName) \(friend.lastName)"
                                msgAlert = "What would you like to do?"
                                showAlert = true
                            }){
                                HStack{
                                    Image(systemName: "person")
                                    Spacer()
                                    Text("\(friend.firstName) \(friend.lastName)")
                                    Spacer()
                                }
                            }.confirmationDialog(titleAlert, isPresented: $showAlert, titleVisibility: .visible,
                             actions: {
                                 Button("Send Message"){
                                    print("going to messages")
                                 }
                                 Button("Remove Friend", role: .destructive){
                                     Task{
                                         print("removing friend...")
                                         if await database.removeFriend(exFriendID: friend.uid){
                                             print("success")
                                             await database.getFriendsList()
                                         }
                                         else{
                                             print("failure")
                                         }
                                     }
                                     
                                 }
                             })
                            
                        }
                        
                    }
                }
                        
                    
                
            case .ADD:
                
                Button(action:{
                    if searchText == ""{
                        print("cannot search for nothing")
                    }
                    else{
                        //search database with keywords
                        Task{
                            if await database.searchForUsers(withKeyPhrase: searchText, save: true){
                                print("found results")
                                
                                showResults = true
                            }
                            else{
                                Text("error occured")
                                print("error getting result")
                            }
                        }
                        
                    }
                                                
                }){
                    Text("Search")
                }
                
                List{
                    if showResults{
                         
                        if database.friendSearchList.isEmpty{
                            Text("No Results Found")
                        }
                        
                        else{
                            ForEach(database.friendSearchList.sorted(by: { f1, f2 in
                                return f1.relationship.rawValue < f2.relationship.rawValue
                            }), id: \.uid){ result in
                                HStack{
                                    Image(systemName: "person")
                                    VStack{
                                        Text("\(result.firstName) \(result.lastName)")
                                        Button(action:{
                                            Task{
                                                switch result.relationship{
        //                                                case .me:
        //                                                    //view profile
        //                                                    print("view")
                                                case .friend:
                                                    //remove friend
                                                    print("removing friend...")
                                                    if await database.removeFriend(exFriendID: result.uid){
                                                        print("success")
                                                        await database.searchForUsers(withKeyPhrase: searchText, save: true)
                                                    }
                                                    else{
                                                        print("failure")
                                                    }
                                                case .sentRequest:
                                                    //remove request
                                                    print("removing request...")
                                                    if await database.removeSentRequest(requestID: result.uid){
                                                        print("success")
                                                        await database.searchForUsers(withKeyPhrase: searchText, save: true)
                                                    }
                                                    else{
                                                        print("failure")
                                                    }
                                                case .recievedRequest:
                                                    //accept request
                                                    print("accepting result...")
                                                    if await database.acceptFriendRequest(fromUserID: result.uid){
                                                        print("success")
                                                        await database.searchForUsers(withKeyPhrase: searchText, save: true)
                                                    }
                                                    else{
                                                        print("failure")
                                                    }
                                                case .noRelation:
                                                    //send request
                                                    print("sending request...")
                                                    if await database.sendFriendRequest(toUserID: result.uid){
                                                        print("success")
                                                        await database.searchForUsers(withKeyPhrase: searchText, save: true)
                                                    }
                                                    else{
                                                        print("failure")
                                                    }
                                                }}
                                            }
                                            
                                        ){
                                            switch result.relationship{
        //                                                case .me:
        //                                                    //view profile
        //                                                Text("View Profile")
                                                case .friend:
                                                    //remove friend
                                                Text("Remove Friend")
                                                case .sentRequest:
                                                    //remove request
                                                Text("Remove Request")
                                                case .recievedRequest:
                                                    //accept request
                                                Text("Accept Friend")
                                                case .noRelation:
                                                    //send request
                                                Text("Send Friend Request")
                                        }
                                    }
                                }
                                Text("\(result.id)")
                            }
                        }
                        }
                        
                        

                }

                    
            }
                
//
                
//                if searchText == ""{
//                    //no search results
//                    Text("Search for friends")
//                }
//                else{
//                    //show live results based on searchText
//                }
            }
            Spacer()
        }
        .navigationTitle(Text("Friends List"))
        .navigationBarTitleDisplayMode(.inline)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color(.init(white:0, alpha:0.05)))
        
    }
}

//struct FriendsTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendsTabView()
//    }
//}
