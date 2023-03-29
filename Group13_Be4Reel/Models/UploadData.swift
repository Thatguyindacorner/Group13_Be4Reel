//
//  UploadData.swift
//  Group13_Be4Reel
//
//  Created by Alex Olechnowicz on 2023-03-29.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

class UploadData: Codable{
    
    @DocumentID var id: String?
    
    var upload: String = ""
    var time: Date = Date()
    //var location:
}
