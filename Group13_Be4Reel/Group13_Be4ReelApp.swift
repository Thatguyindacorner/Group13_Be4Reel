//
//  Group13_Be4ReelApp.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      DatabaseConnection.shared.linked = true
    return true
  }
}

@main
struct Group13_Be4ReelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let persistenceController = PersistenceController.shared
    
    let database = DatabaseConnection.shared
    
    @State var loginType: Int = 1
    
    @State var isActive: Bool = false

    @StateObject var fireAuthHelper = FirebaseAuthHelper()
    
    @StateObject var fireDBHelper = FireDBUserHelper.sharedFireDBHelper
    
    var body: some Scene {
        
        let binding1 = Binding<Bool>(get: {
                    self.loginType==1
                }, set: {
                    self.isActive = $0
                })
        
        let binding2 = Binding<Bool>(get: {
                    self.loginType==2
                }, set: {
                    self.isActive = $0
                })
        
        WindowGroup {
//            NavigationView{
//
//                //ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
//
//                if UserDefaults.standard.string(forKey: "username") != nil{
//                    //user saved
//                    //use stored info to authenticate with Firebase
//                    //go to MainView()
//                }
//                else{
//                    //user not saved
//
//                    //"creative" way to handle swaping from log in to sign up
//
//                    if loginType == 1{
//                        //login
//                        NavigationLink(destination: LoginView(loginType: $loginType).environmentObject(database), isActive: binding1){}
//                    }
//
//                    else{
//                        //sign up
//                        NavigationLink(destination: SignupView(loginType: $loginType).environmentObject(database), isActive: binding2){}
//                    }
//
//                }
//
//            }.navigationBarBackButtonHidden(true)
            
            
            
            
//            if UserDefaults.standard.string(forKey: "KEY_USER_ID") != nil{
//                //user has logged in before
//                Text("Hello \(UserDefaults.standard.string(forKey: "KEY_EMAIL")!)").onAppear {
//                    Task{
//                        guard try await fireAuthHelper.signInUser(withEmail: UserDefaults.standard.string(forKey: "KEY_EMAIL")!, withPassword: UserDefaults.standard.string(forKey: "USER_PASSWORD")!)
//
//                        else{
//                            print("error signing in")
//                            LoginView(loginType: $loginType).environmentObject(fireDBHelper)
//                                .environmentObject(fireAuthHelper).environmentObject(database)
//                            return
//                        }
//
//                        MainView().environmentObject(database)
//                    }
//
//                }
//
//            }
            //else{
                LoginView(loginType: $loginType).environmentObject(fireDBHelper)
                    .environmentObject(fireAuthHelper).environmentObject(database)
            //}
            
            
            
        }
    }
}
