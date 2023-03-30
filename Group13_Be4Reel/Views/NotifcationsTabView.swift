//
//  NotifcationsTabView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-27.
//

import SwiftUI

struct NotificationsTabView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var showAlert: Bool = false
    
    @State var titleAlert: String = ""
    @State var msgAlert: String = ""
    
    var body: some View {
        VStack{
            
            Spacer()
            
            Text("Notifications").font(.title)
            
            Spacer()
            
            if database.friendRequests.isEmpty{
                Text("No Notifications to Display")
            }
            else{
                //maybe do messages too
                List{
//                    ForEach(database.friendRequests, id: \.uq){ request in
                    ForEach(database.friendRequests, id: \.uq){ request in
                        Button(action:{
                            titleAlert = "Friend request from \(request.firstName) \(request.lastName)"
                            msgAlert = "What would you like to do?"
                            showAlert = true
                        }){
                            HStack{
                                Image(systemName: "person")
                                Spacer()
                                VStack{
                                    Text("Friend Request from")
                                    Text("\(request.firstName) \(request.lastName)")
                                }
                                Spacer()
                            }
                        }.confirmationDialog(titleAlert, isPresented: $showAlert, titleVisibility: .visible,
                        actions: {
                            Button("Accept Request"){
                                Task{
                                    print("accepting")
                                    if await database.acceptFriendRequest(fromUserID: request.uid){
                                        print("success")
                                        await database.getFriendRequests()
                                    }
                                    else{
                                        print("failure")
                                    }
                                }
                            }
                            Button("Remove Request", role: .destructive){
                                Task{
                                    print("removing")
                                    if await database.removeFriendRequest(requestID: request.uid){
                                        print("success")
                                        await database.getFriendRequests()
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
                
            Spacer()
        }
//        .onAppear{
//
//            Task{
//                await self.database.getFriendRequests()
//            }//Task
//        }//onAppear
    }
}

