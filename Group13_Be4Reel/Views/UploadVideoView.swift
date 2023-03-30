//
//  UploadVideoView.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-24.
//

import SwiftUI

struct UploadVideoView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    let quotesAPI = APIHelper()
        
    @State var quote: String = ""
    @State var by: String = ""
    
    @State var randomQuote = Quote(text: "We gotta start somewhere", author: "Be4Reel Devs")
    
    @State var randomQuoteList: [String] = []
    @State var buttonPresses = 0
    
    @State var setQuote: Bool = false
    
    @State var atteptedConnection = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State var showAlert = false
    @State var errorMessage = ""
    
    var body: some View {
        
        let binding = Binding<String>(get: {
                    
                    
        if self.setQuote{
            DispatchQueue.main.async {
                self.quote = randomQuote.text!
                self.setQuote = false
            }
        }

        return self.quote
        
    }, set: {
                self.quote = $0
                
            })
        
        NavigationView{
            VStack{

                VStack(spacing: 0){
                    Image(systemName: "quote.opening")
                        .frame(maxWidth: 350, alignment: .topLeading)
                    
                    TextField("Your fantastic quote goes here", text: binding, axis: .vertical)
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(maxWidth: 300, alignment: .center)
                        .lineLimit(1...10)
                        .multilineTextAlignment(TextAlignment.center)
                        .onChange(of: quote) { newValue in
                            
                            print("calling onChange")
                            
                            if self.randomQuoteList.contains(newValue){
                                
                                Task{
                                    let author = await quotesAPI.getAuthorOf(quote: quote)
                                    DispatchQueue.main.async {
                                        self.by = author
                                    }
                                }
                                
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.by = "\(database.signedInUser!.firstName.capitalized) \(database.signedInUser!.lastName.capitalized)"
                                }
                            }
                        }
                    
                    Image(systemName: "quote.closing")
                        .frame(maxWidth: 350, alignment: .bottomTrailing)
                    
                }.frame(maxWidth: 325, alignment: .center).padding(15).border(Color.black)
                    .onAppear{
                        self.by = "\(database.signedInUser!.firstName.capitalized) \(database.signedInUser!.lastName.capitalized)"
                    }
                    
                    
                    Text("- \(by)").font(.headline).padding(.trailing)
                    
                


                Spacer()
                
                
               
                    Button(action:{
                        print("pressing button")
                        if self.atteptedConnection{
                            Task{
                                randomQuote = await quotesAPI.pickRandomQuote()
                                randomQuoteList.append(randomQuote.text!)
                                print("got quote")
                                print(randomQuoteList)
                                buttonPresses += 1
                                setQuote = true
                            }
                        }
                        
                        else {
                            self.quote = randomQuote.text!
                            randomQuoteList.append(randomQuote.text!)
                            print("got preset quote")
                            buttonPresses += 1
                            setQuote = true
                        }
                        
                    }){
                        Text("Generate Quote")
                    }
                    
                
               
            }
        }.toolbar{
            ToolbarItem(placement: .primaryAction){
                Button(action:{
                    guard quote != ""
                    else{
                        errorMessage = "Quote cannot be empty"
                        showAlert = true
                        return
                    }
                    
                    let pattern = "[a-zA-Z .!?':;,&@$%0-9]"
                    guard quote.range(of: pattern, options: .regularExpression) != nil
                    else{
                        errorMessage = "Invalid charactors used"
                        showAlert = true
                        return
                    }
                    
                    print("upload")
                    
                    let newUpload = UploadData(upload: Quote(text: quote, author: by), time: Date())
                    
                    Task{
                        if await database.uploadPost(upload: newUpload){
                            presentationMode.wrappedValue.dismiss()
                        }
                        else{
                            print("error uploading")
                            errorMessage = "Could not upload to database"
                            showAlert = true
                        }
                    }
                    
                    
                })
                {
                    Image(systemName: "square.and.arrow.up")
                }
                
            }
        }
        .navigationTitle("Upload")
            .onAppear{
                Task{
                    if await quotesAPI.getQuotes(){
                        print("got quotes from api")
                    }
                    else{
                        print("could not get quotes from api")
                    }
                    self.atteptedConnection = true
                }
            }.alert(isPresented: $showAlert){
                Alert(title: Text("Error Uploading"), message: Text(errorMessage), dismissButton: .cancel(Text("Okay")))
            }
        }
        
        
    
}

struct UploadVideoView_Previews: PreviewProvider {
    static var previews: some View {
        UploadVideoView()
    }
}
