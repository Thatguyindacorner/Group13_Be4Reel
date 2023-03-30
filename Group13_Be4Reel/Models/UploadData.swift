//
//  UploadData.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-29.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

extension Date{
    func toHM() -> String{
        return self.formatted(date: .omitted, time: .shortened)
    }
}

class UploadData: Codable{
    
    @DocumentID var id: String?
    
    var upload: Quote?
    var time: Date?
    //var latitute: CLLocationDegrees
    //var longitute: CLLocationDegrees
    
    init(id: String? = nil, upload: Quote, time: Date){//, latitute: CLLocationDegrees, longitute: CLLocationDegrees) {
        self.id = id
        self.upload = upload
        self.time = time
        //self.latitute = latitute
        //self.longitute = longitute
    }
    
    enum CodingKeys: CodingKey {
        case id
        case upload
        case time
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let convert = try container.nestedContainer(keyedBy: Quote.CodingKeys.self, forKey: .upload)
        
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        let text = try convert.decodeIfPresent(String.self, forKey: .text)
        let author = try convert.decodeIfPresent(String.self, forKey: .author)
        self.upload = Quote(text: text ?? "Unknown", author: author ?? "Unknown")
        self.time = try container.decode(Date.self, forKey: .time)
    }
    
//    func encode(to encoder: Encoder) throws {
//
//        var container = encoder.unkeyedContainer()
//        try container.encode(self.upload.map({ quote in
//            quote
//        }))
//
//        var convert = container.nestedContainer(keyedBy: Quote.CodingKeys.self, forKey: .upload)
//
//
//
//        try convert.encodeIfPresent(self.upload
//        try container.encodeIfPresent(self.time, forKey: .time)
//    }
    
    
}
