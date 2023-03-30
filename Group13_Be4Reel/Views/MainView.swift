//
//  MainView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI
import AVKit
import FirebaseFirestore
import FirebaseAuth

enum SheetSelection{
    case profile
    case friends
    case notifications
}

struct MainView: View {
    
    //@Binding var loginType: Int
    @Binding var loginMode: Bool
    
    @State var upload: Bool = false
    @State var doneFetch: Bool = false
    
    @State var showTab: Bool = false
    @State var activeTab: SheetSelection = .profile
    
    @EnvironmentObject var database: DatabaseConnection
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            
            //FreshScrollView{
                
            VStack{
                
                if !database.loggedIn{
                    Text("").onAppear{
                        print("logged out")
                        loginMode = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if database.upload != nil{
                    if database.signedInUser!.friendsList.isEmpty{
                        Text("No friends added yet :(")
                    }
                    else{
                        List{
                            ForEach(database.friendsList, id:\.uid){ friend in
                                if friend.upload != nil{
                                    NavigationLink(destination: QuoteView(friend: friend)){
                                        HStack{
                                            //profile pic
                                            VStack{
                                                Image(systemName: "brain.head.profile")
                                                Text("\(friend.firstName) \(friend.lastName)")
                                            }
                                            Text("Time Posted: \(friend.upload!.time!.toHM())")
                                            //Text("Xkm away")
                                        }
                                    }
                                }
                                else{
                                    Text("No Post from \(friend.firstName) \(friend.lastName) today")
                                }
                                
                            }
                        }
                    }
                    
                }
                
                else{
                    //yet to upload video for day
                    NavigationLink(destination: UploadVideoView().environmentObject(database), isActive: $upload) {
                        ZStack(alignment: .bottom){
                            Button(action: {
                                //go to UploadVideoView
                                upload = true
                            } ){
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color.green)
                            }
                        }
                    }.disabled(!doneFetch)
                }
            }.onAppear{
                if !database.loggedIn{
                    print("here")
                    presentationMode.wrappedValue.dismiss()
                }
                else{
                    Task{
                        await database.getFriendsList()
                        await database.getFriendRequests()
                        await database.checkIfPost()
                        doneFetch = true
                    }
                }
                
            }
            .toolbar {
                
                ToolbarItem(placement: .bottomBar){
                    Button(action:{
                        print("ScrollView Scrolled up")
        
                        Task(priority:.background){
        
                            self.database.friendRequests = []
        
                            self.database.friendsList = []
        
                            let reference = Firestore.firestore().collection("Users").document(self.database.signedInUser!.uid)
                            do{
                                self.database.signedInUser = try await reference.getDocument(as: UserData.self)
        
                                await self.database.getFriendsList()
                                await self.database.getFriendRequests()
                                await self.database.checkIfPost()
        
                                print("User Updated")
                            }catch{
                                print("Error getting the User document, \(error.localizedDescription)")
                            }//catch
        
                        }//Task
                    }){
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    //profile tab
                    Button(action:{
                        activeTab = .profile
                        showTab = true
                    }){
                        Image(systemName: "person.text.rectangle")
                        //Image(systemName: "person.crop.artframe")
                        //Image(systemName: "person.fill.questionmark")
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Be 4 Reel")
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    //notifications tab
                    
                    Button(action:{
                        activeTab = .notifications
                        showTab = true
                    }){
                        //if database.signedInUser!.friendRequests.isEmpty{
                        //                        if database.signedInUser!.friendRequests.isEmpty{
                        //                            Image(systemName: "bell")
                        //                        }
                        //                        else{
                        //                            Image(systemName: "bell.badge")
                        //                        }
                        Image(systemName: database.signedInUser?.friendRequests.isEmpty ?? true ? "bell" : "bell.badge")
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    //friends tab
                    
                    Button(action:{
                        activeTab = .friends
                        showTab = true
                    }){
                        Image(systemName: "person.3.fill")
                        //Image(systemName: "person.2.circle")
                    }
                }
                
                ToolbarItem(placement:.secondaryAction){
                    //SignOutHelper()
                    Button(action:{
                        print("Perform Logout action")
                        database.signOut()
                        self.loginMode = true
                        presentationMode.wrappedValue.dismiss()
                        //dismiss()
                    }){
                        VStack{
                            Image(systemName: "door.left.hand.open")
                                .font(.system(size: 16))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.black, .red)
                            Text("Logout")
                        }
                    }//Button
                    
                }
                
            }.sheet(isPresented: $showTab) {
                if activeTab == .profile{
                    //load profile view
                    ProfileTabView()
                }
                else if activeTab == .notifications{
                    //load notifications view
                    NotificationsTabView()
                }
                else{
                    //load friends view
                    FriendsTabView()
                }
             }//sheet
//            } action: {
//                print("ScrollView Scrolled up")
//
//                Task(priority:.background){
//
//                    self.database.friendRequests = []
//
//                    self.database.friendsList = []
//
//                    let reference = Firestore.firestore().collection("Users").document(self.database.signedInUser!.uid)
//                    do{
//                        self.database.signedInUser = try await reference.getDocument(as: UserData.self)
//
//                        await self.database.getFriendsList()
//                        await self.database.getFriendRequests()
//                        await self.database.checkIfPost()
//
//                        print("User Updated")
//                    }catch{
//                        print("Error getting the User document, \(error.localizedDescription)")
//                    }//catch
//
//                }//Task
//
//            }//FreshScrollView
            
        }.navigationBarBackButtonHidden(true)//NavigationView
        
        
    }//body
}

struct QuoteView: View{
    var friend: FriendData
    
    var body: some View{
        NavigationView{
            VStack{
                Text("\(friend.firstName) \(friend.lastName)'s")
                Spacer()
                
                Text("\"\(friend.upload!.upload!.text!)\"")
                    .font(.headline)
                    .padding(.horizontal)
                    
                Text("- \(friend.upload!.upload!.author!)")
                Spacer()
            }
        }.navigationTitle("Quote of the day")
    }
}

struct VideoLoadView: View {
    
    var video: URL
    
   //@State var player = AVPlayer(url: NSURLRequest(url: <#T##URL#>))
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "video2", withExtension: "m4v")!)
    @State var isPlaying: Bool = false

    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(width: 320, height: 180, alignment: .center)

            Button {
                isPlaying ? player.pause() : player.play()
                isPlaying.toggle()
                player.seek(to: .zero)
            } label: {
                Image(systemName: isPlaying ? "stop" : "play")
                    .padding()
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    
    static var previews: some View {
//        LoginView(loginType: .constant(0))
//            .environmentObject(DatabaseConnection.shared)
        MainView(loginMode: .constant(false))
            .environmentObject(FirebaseAuthHelper())
            .environmentObject(FireDBUserHelper.sharedFireDBHelper)
            .environmentObject(DatabaseConnection.shared)
    }
}
