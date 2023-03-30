
//
//  QuoteAPIConnection.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-29.
//

import Foundation

class APIHelper{
    
    let api = URL(string: "https://type.fit/api/quotes")
    var quoteList: [Quote] = []
    
    func pickRandomQuote() async -> Quote{
        
        guard !self.quoteList.isEmpty
        else{
            return Quote(text: "Sometimes things don't work out the way you expect them to...", author: "Be4Reel Devs")
        }
        
        let randomNumber = Int.random(in: 0..<self.quoteList.count)
        
        return quoteList[randomNumber]
        
    }
    
    func getAuthorOf(quote: String) async -> String{
        
        let found = quoteList.first { current in
            return current.text! == quote
        }
        
        if found == nil{
            print("didn't find quote in list")
            return "Unknown"
        }
        
        if found!.author == nil{
            print("author is nil")
            return "Unknown"
        }
        
        if found!.author == "null"{
            print("author is 'null'")
            return "Unknown"
        }
        
        return found!.author!
        
    }
    
    func getQuotes() async -> Bool{
        
        do{
            print("doing")
            let (data, response) = try await URLSession.shared.data(from: api!)
            print("past 1")
            guard let httpResponse = response as? HTTPURLResponse
            else{
                //error getting / converting code
                print("could not convert response")
                return false
            }
            
            guard httpResponse.statusCode == 200
            else{
                //error code
                print("error code: \(httpResponse.statusCode)")
                return false
            }
            
            print("past 2")
        
            //print(data.encode(to: Quote))
            print(response)
            let jsonData = try JSONDecoder().decode(QuoteResults.self, from: data)
            print("past 3")
            
            self.quoteList = jsonData.results ?? []
            print(jsonData)
            print("successfully got quotes")
        }
        
        catch{
            print("something went wrong")
            return false
        }
        
        print("returning from getQuotes")
        return true
    }
}
