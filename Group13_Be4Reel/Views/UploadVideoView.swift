//
//  UploadVideoView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct UploadVideoView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    var body: some View {
        
        NavigationView{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).onAppear{
                print("here")
            }
        }
        
        
    }
}

struct UploadVideoView_Previews: PreviewProvider {
    static var previews: some View {
        UploadVideoView()
    }
}
