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
    
    @EnvironmentObject var fireAuthHelper:FirebaseAuthHelper
    
    @EnvironmentObject var fireDBUserHelper:FireDBUserHelper
    
    @State private var fName:String = ""
    
    @State private var lName:String = ""
    
    @State private var emailAdd:String  = ""
    
    @State private var password:String = ""
    
    @State private var changePassword:Bool = true
    
    
    var body: some View {
        
        VStack{
            Spacer()
            if(fireAuthHelper.user == nil){
               showNoUserFound()
            }else{
                
                showEditImage()
                
                showEditFields()
                
                showSaveButton()
            }
            
            
            Spacer()
            
            
        }//VStack
        .navigationTitle(Text("Update Profile"))
        .navigationBarTitleDisplayMode(.inline)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color(.init(white:0, alpha:0.05)))
        
        
    }//Body
    
    private func showEditImage() -> some View{
        Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .font(.system(size: 120))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.yellow, .green)
            .padding()
    }//showEditImage()
    
    func showEditFields() -> some View{
        Group{
            
            TextField("Edit First Name", text: $fName)
                .padding(12)
                .background(.white)
                .cornerRadius(10)
                .keyboardType(.namePhonePad)
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)

                }
            
            TextField("Edit Last Name", text: $lName)
                .padding(12)
                .background(.white)
                .cornerRadius(10)
                .keyboardType(.namePhonePad)
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)

                }
            
            TextField("Edit Password",text: $password)
                .padding(12)
                .background(.white)
                .cornerRadius(10)
                .keyboardType(.namePhonePad)
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)

                }
            
        }//Group
        .padding(.horizontal)
    }//showEditFields()
    
    
    func showSaveButton() -> some View{
        
        Button(action:{
            print("Save Button clicked")
        }){
            
            HStack{
                Image(systemName: "mail")
                
                Text("Save")
                
            }
            
        }
        .buttonStyle(.borderedProminent)
        .font(.title)
        .controlSize(.regular)
        .padding()
    }//showSaveButton()
    
    
    func showNoUserFound() -> some View{
        
        VStack{
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 120))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.black, .red)
                .padding(.bottom, 60)
                
            
            Button(action:{
                print("Go to home Screen")
            }){
                Text("Home")
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 50)
            }
            .background()
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .bold))
            .cornerRadius(10)
            .overlay{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 1)
            }
            
            Spacer()
            
        }
        .padding(EdgeInsets(top: 60, leading: 30, bottom: 30, trailing: 30))
        
    }
    
    
    
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProfileTabView().environmentObject(FirebaseAuthHelper())
                .environmentObject(FireDBUserHelper.sharedFireDBHelper)
        }
    }
}

/*
    Alex's Code --
 
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
 
 
 
 */
