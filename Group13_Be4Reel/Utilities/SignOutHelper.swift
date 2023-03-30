//
//  SignOutHelper.swift
//  Group13_Be4Reel
//
//  Created by Ameya Joshi on 2023-03-29.
//

import Foundation
import SwiftUI

struct SignOutHelper:View{
    
    @EnvironmentObject var database:DatabaseConnection
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        
        Button(action:{
            print("Perform Logout action")
            database.signOut()
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
    
    
}
