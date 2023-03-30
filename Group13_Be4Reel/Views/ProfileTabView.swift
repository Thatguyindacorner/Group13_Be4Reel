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
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var fireAuthHelper:FirebaseAuthHelper
    
    @EnvironmentObject var fireDBUserHelper:FireDBUserHelper
    
    
    @State private var fName:String = ""
    
    @State private var lName:String = ""
    
    @State private var emailAdd:String  = ""
    
    @State private var password:String = ""
    
    @State private var changePassword:Bool = true
    
    
    @State private var showAlert:Bool = false
    
    @State private var errorMessage:String = ""
    
    var body: some View {
        
        VStack(spacing: 25){
            Spacer()
//            if(fireAuthHelper.user == nil){
            if(database.user == nil){
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
    
    
    func validateEmptyFields() throws{
        
        if(self.password.isEmpty || self.fName.isEmpty || self.lName.isEmpty){
            throw ErrorEnum.FieldsEmpty
        }
        
    }//validateEmptyFields
    
    func validatePasssordLength() throws{
        
        if(self.password.count < 6){
            throw ErrorEnum.InvalidLength
        }
        
    }//validatePasswordLength
    
    @ViewBuilder
    func showEditImage() -> some View{
        Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .font(.system(size: 120))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.yellow, .green)
            .padding()
    }//showEditImage()
    
    //@ViewBuilder
    func showEditFields() -> some View{
        VStack{
            
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
    
    @ViewBuilder
    func showSaveButton() -> some View{
        
        HStack(spacing:10){
            
            Button(action:{
                print("Save Button clicked")
                
                do{
                    try self.validateEmptyFields()
                    
                    try self.validatePasssordLength()
                    
                    Task(priority:.background){
                        
                    
                        if(!password.isEmpty){
                            await database.changePassword(newPassword: password)
                            
                            self.database.signedInUser?.password = self.password
                        }
                        
                        if(!self.fName.isEmpty){
                            self.database.signedInUser?.firstName = self.fName
                        }
                        
                        if(!self.lName.isEmpty){
                            self.database.signedInUser?.lastName = self.lName
                        }
                        
                        do{
                            try await fireDBUserHelper.updateUserProfileInfo(userToUpdate: self.database.signedInUser!)
                            
                            self.database.signedInUser?.createSearchTerms()
                            
                            dismiss()
                            
                        }catch{
                            print("Error updating user data, \(error.localizedDescription)")
                            self.errorMessage = error.localizedDescription
                            
                            self.showAlert = true
                        }//catch
                    }//Task
                    
                }catch(let errMsg){
                    print("Error processing data \(errMsg.localizedDescription)")
                    
                    self.errorMessage = errMsg.localizedDescription
                    
                    self.showAlert = true
                }
                
            }){
                
                HStack{
                    Image(systemName: "mail")
                    
                    Text("Save")
                    
                }
                
            }//Button
            .buttonStyle(.borderedProminent)
            .font(.title)
            .controlSize(.regular)
            .padding()
            
            
            Button(action:{
                print("Dismiss View")
                dismiss()
            }){
                Text("Cancel")
                    .frame(minHeight: 0, maxHeight: 50)
            }//Button
            .padding(.horizontal)
            .background()
            .foregroundColor(.blue)
            .font(.system(size: 16, weight: .bold))
            .cornerRadius(10)
            .overlay{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 1)
            }
            
            
        }//HStack
        .frame(minWidth: 0, maxWidth: .infinity)
        
        .alert("Error", isPresented: self.$showAlert, actions: {
            Button("OK", role: .cancel){
                self.showAlert = false
            }
        }, message: {
            Text(self.errorMessage)
        })
        
        
    }//showSaveButton()
    
    
    @ViewBuilder
    func showNoUserFound() -> some View{
        
        VStack{
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 120))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.black, .red)
                .padding(.bottom, 60)
                
            Text("No Active User Found!")
            
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
            
        }//VStack
        .padding(EdgeInsets(top: 60, leading: 30, bottom: 30, trailing: 30))
        
    }
    
    
    
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProfileTabView().environmentObject(FirebaseAuthHelper())
                .environmentObject(FireDBUserHelper.sharedFireDBHelper)
                .environmentObject(DatabaseConnection.shared)
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
