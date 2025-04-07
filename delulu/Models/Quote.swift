    //
//  Item.swift
//  delulu
//
//  Created by  Apple on 05/04/2025.
//

import Foundation
import SwiftData

@Model
final class Quote {
    var quote: String
    var snug: String
    
    init(qoute: String,snug: String) {
        self.quote = qoute
        self.snug  = snug
    }
}
