//
//  LoginView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    
    @Binding var loginType: Int
    
    @State var validated: Bool = false
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State private var userFName:String = ""
    
    @State private var userLName:String = ""
    
    @State private var userPassword:String = ""
    
    @State private var userEmail:String = ""
    
    
    @EnvironmentObject var fireDBHelper:FireDBUserHelper
    
    @EnvironmentObject var fireAuthHelper:FirebaseAuthHelper
    
    @State private var loginMode:Bool = true{
        willSet{
            print("value is \(newValue)")
        }
        didSet{
            print("Value was \(oldValue)")
        }
    }
    
    @State private var selection:Int? = nil
    
    
    var body: some View {
        
        NavigationView{
            
            content
            
        }//NavigationView
        
        
    }//body
    
    
    var content:some View{
        ZStack{
            
            
            
            ScrollView{
            
                VStack(spacing:16){
                    Picker(selection:$loginMode, label: Text("")){
                        
                        Text("Login")
                            .tag(true)
                        
                        Text("Create Account")
                            .tag(false)
                    }//Picker
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    
                    Image(systemName: "person.circle")
                        .font(.system(size: 100))
                        .foregroundColor(.accentColor)
                        .padding()
                    
                    Group{
                        
                        if(loginMode){
                            TextField("Enter Email", text: $userEmail)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.gray.opacity(0.2), lineWidth: 2)

                                }

                         
                            SecureField("Enter Password", text: $userPassword)
                                .textFieldStyle(.roundedBorder)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.gray.opacity(0.2), lineWidth: 2)
                                    
                                }
                        }//if loginMode
                        else{
                            
                            TextField("Enter First Name*", text: $userFName)
                                .padding(12)
                                .background(.white)
                                .keyboardType(.namePhonePad)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.gray.opacity(0.2), lineWidth: 1)

                                }
                            
                            TextField("Enter Last Name*", text: $userLName)
                                .padding(12)
                                .background(.white)
                                .keyboardType(.namePhonePad)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.gray.opacity(0.2), lineWidth: 1)

                                }
                            
                            HStack{
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray.opacity(0.5))
                                TextField("Enter Email*", text: $userEmail)
                                    //.textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                            
                            }//HStackEmail
                            .padding(12)
                            .background(.white)
                            .overlay{
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                            }//Overlay
                            
                            HStack{
                                Image(systemName: "key")
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                SecureField("Enter Password*", text: $userPassword)
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                            }//HStack Password
                            .padding(12)
                            .background(.white)
                            .overlay{
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                            }//Overlay
                         
                            
                            
                                
                        }//else
                        
                        
                    }//Group
                    .padding(.horizontal)
                    
                    
                    NavigationLink(destination:MainView(loginMode: $loginMode), isActive: $validated){
                        Button(action:{
                            print("Button pressed LoginMode Value is :\(loginMode)")
                            
                            handleButtonAction()
                            
                        }){
                            
                            HStack{
                                Spacer()
                                
                                Text(loginMode ? "Login" : "Sign Up")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                            }//HStack
                            .background(.blue)
                        }//Button
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    
                    
                    
                    
                }//VStack
                .onAppear{
                    Auth.auth().addStateDidChangeListener{(auth, user) in

                        if user != nil{
                            fireAuthHelper.isLoggedIn = true

                        }

                    }
                }
                
            }//ScrollView
            .navigationTitle(loginMode ? "Login" : "Create Account")
            .background(Color(.init(white:0, alpha:0.05)))
            
            if(fireAuthHelper.showProgressView){
                ProgressView()
                    .tint(.red)
                    .scaleEffect(4)
            }
            
        } //ZStack
        
    }
    
    private func handleButtonAction(){
        
        if(loginMode){
            print("✉️ perform login action")
            
            Task(priority:.high){
                await loginUser()
                
                self.userEmail = ""
                self.userPassword = ""
                self.userFName = ""
                self.userLName = ""
                self.userPassword = ""
                
                self.fireAuthHelper.showProgressView = false
                
            }
            
        }else if(loginMode == false){
            print("👍 perform sign up action")
            
            Task(priority:.high){
              let signUpSuccess =   await signUpUser()
                
                if(signUpSuccess){
                    self.userEmail = ""
                    self.userPassword = ""
                    self.userFName = ""
                    self.userLName = ""
                    self.userPassword = ""
                    
                    self.fireAuthHelper.showProgressView = false
                    
                    self.selection = 1
                }
                
                
            }
            
//            Task(priority:.background, operation: {
//
//                do{
//
//                    try await fireAuthHelper.signupUser(firstName: userFName, lastName: userLName, emailAdd: userEmail, passwd: userPassword)
//
//                    self.selection = 1
//
//                    self.userEmail = ""
//                    self.userPassword = ""
//                    self.userFName = ""
//                    self.userPassword = ""
//
//                }catch{
//                    print("Error in the operation\(error.localizedDescription)")
//                }
//
//            })
            
        }// else if
        
        
    }//HandleButtonAction
    
    
    private func loginUser() async{
        
        let loginTask = Task(priority:.high){() -> Bool in
            do{
               
             let logIn = try await fireAuthHelper.signInUser(withEmail: userEmail, withPassword: userPassword)
            
                return logIn
            }catch{
                print("Error while signing in \(error.localizedDescription)")
                return false
            }
            
        }
        
        let loginSuccess = await loginTask.value
        
        if(loginSuccess){
            self.selection = 1
            self.validated = true
            self.database.loggedIn = true
        }else{
            print("Jeez! There was an error signing in")
        }
        
    }//LoginUser
    
    private func signUpUser() async -> Bool{
        
        let signUpTask = Task(priority:.high){() -> Bool in
            do{
                let signIn = try await fireAuthHelper.signupUser(firstName: userFName, lastName: userLName, emailAdd: userEmail, passwd: userPassword)
                
                return signIn
            }catch{
                print("Error signing up \(error.localizedDescription)")
                return false
            }
        }
        
        let isSignedUp = await signUpTask.value
        
        self.validated = true
        self.database.loggedIn = true
        
        return isSignedUp
        
    }//signUpUser
    
    
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
//        LoginView(loginType: .constant(0))
//            .environmentObject(DatabaseConnection.shared)
        LoginView(loginType: .constant(0))
            .environmentObject(FirebaseAuthHelper())
            .environmentObject(FireDBUserHelper.sharedFireDBHelper)
            .environmentObject(DatabaseConnection.shared)
    }
}

/*
  Alex's Code-
 
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
 
 
 */
