    //
//  Item.swift
//  delulu
//
//  Created by  Apple on 05/04/2025.
//

import Foundation
import SwiftData
import FirebaseFirestore


@Model
final class Quote {
    var quote: String
    var snug: String
    var saved: Bool?
    var timestamp: Date?
    
    init(quote: String,snug: String, saved: Bool? = nil, timestamp: Timestamp? = nil) {
        self.quote = quote
        self.snug  = snug
        self.saved = saved
        self.timestamp = timestamp?.dateValue()
    }
}




