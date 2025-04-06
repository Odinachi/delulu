//
//  Item.swift
//  delulu
//
//  Created by  Apple on 05/04/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var quote: String
    
    init(qoute: String) {
        self.quote = qoute
    }
}
