//
//  FriendsTabView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct FriendsTabView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    var body: some View {
        Text("Friends")
    }
}

struct FriendsTabView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsTabView()
    }
}
