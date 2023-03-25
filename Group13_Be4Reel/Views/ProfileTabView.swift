//
//  ProfileTabView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct ProfileTabView: View {
    
    //State values
    
    @EnvironmentObject var database: DatabaseConnection
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack{
            
            //Text("My Profile").font(.title)

            Form{
                Section{
                    //profile information
                    Text("My Profile")
                }
                
                Section{
                    Button(action:{
                        //update database and singleton
                    }){
                        Text("Update Information")
                    }
                }

                Section{
                    Button(action:{
                        //logout (clear UserDefaults)
                        database.loggedIn = false
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Text("Logout")
                    }
                }
                
                
            }//.frame(width: 400, height: 600)


//                Button(action:{
//                    //logout (clear UserDefaults)
//                }){
//                    Text("Logout")
//                }


        }
        
        
        
        
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
    }
}
