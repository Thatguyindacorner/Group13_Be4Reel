//
//  Quote.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-29.
//

import Foundation
import FirebaseFirestoreSwift

struct QuoteResults: Codable, Hashable{
    var results: [Quote]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let list = try container.decode([Quote].self)
        self.results = list
    }
}

struct Quote: Codable, Hashable{
    @DocumentID var id: String?
    
    var text: String?
    var author: String?
    
    enum CodingKeys: CodingKey {
        case text
        case author
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.text, forKey: .text)
        try container.encodeIfPresent(self.author, forKey: .author)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
    }
    
    init(text: String, author: String){
        self.text = text
        self.author = author
    }
    
    
}
