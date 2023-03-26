//
//  SignupView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct SignupView: View {
    
    @Binding var loginType: Int
    
    @State var validated: Bool = false
    
    @EnvironmentObject var database: DatabaseConnection
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Sign Up").font(.title)
                HStack{
                    Button(action:{
                        loginType = 1
                    }){
                        Text("Back to Login").padding(10).border(.black)
                    }
                    //NavigationLink(destination: MainView(loginType: $loginType).environmentObject(database), isActive: $validated) {
                        Button(action:{
                            //validate
                            validated = true
                            database.loggedIn = true
                        }){
                            Text("Sign Up").padding(10).border(.black)
                        }
                    //}
                }
            }
            
        }.navigationBarBackButtonHidden(true).onDisappear{
            print("Dissapear - SignUp")
        }
        
    }
}

struct OnboardingView: View{
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
