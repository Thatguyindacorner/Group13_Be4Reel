//
//  MainView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI
import AVKit

enum SheetSelection{
    case profile
    case friends
}

struct MainView: View {
    
    @Binding var loginType: Int
    
    @State var upload: Bool = false
    
    @State var showTab: Bool = false
    @State var activeTab: SheetSelection = .profile
    
    @EnvironmentObject var database: DatabaseConnection
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            VStack{
                
                if !database.loggedIn{
                    Text("").onAppear{
                        print("logged out")
                        loginType = 1
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if false{
                    //uploaded video for day
//                    List{
//                        ForEach(friend in database.postedFriends){
//                            NavigationLink(destination: VideoLoadView(video: friend.videoURL)){
//                                HStack{
//                                    //profile pic
//                                    VStack{
//                                        Image(systemName: "brain.head.profile")
//                                        Text("Name")
//                                    }
//                                    Text("Time Posted: HH:MM")
//                                    Text("Xkm away")
//                                }
//                            }
//                        }
//                    }
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
                    }
                }
            }.onAppear{
                if !database.loggedIn{
                    print("here")
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading){
                    //profile tab
                    Button(action:{
                        activeTab = .profile
                        showTab = true
                    }){
                        Image(systemName: "person.fill.questionmark")
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Be 4 Reel")
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    //friends tab
                    
                    Button(action:{
                        activeTab = .friends
                        showTab = true
                    }){
                        Image(systemName: "person.2.circle")
                    }
                }
            }.sheet(isPresented: $showTab) {
                if activeTab == .profile{
                    //load profile view
                    ProfileTabView()
                }
                else{
                    //load friends view
                    FriendsTabView()
                }
            }
        }.navigationBarBackButtonHidden(true)//NavigationView
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

