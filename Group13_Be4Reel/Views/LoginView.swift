//
//  LoginView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var loginType: Int
    
    @State var validated: Bool = false
    
    @EnvironmentObject var database: DatabaseConnection
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Login").font(.title)
                HStack{
                    Button(action:{
                        loginType = 2
                    }){
                        Text("Back to Sign Up").padding(10).border(.black)
                    }
                    NavigationLink(destination: MainView(loginType: $loginType).environmentObject(database), isActive: $validated) {
                        Button(action:{
                            //validate
                            validated = true
                            database.loggedIn = true
                        }){
                            Text("Log In").padding(10).border(.black)
                        }
                    }
                    
                }
            }
            
        }.navigationBarBackButtonHidden(true).onDisappear{
            print("Dissapear - Login")
        }
        
    }
}
