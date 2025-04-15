import Foundation
import FirebaseFirestore

struct SatireQuoteResponse: Codable {
    let message: String
    let quotes: SatireQuote
}

struct SatireQuote: Codable {
    let profession: String
    let snug: String
    let quote: String
    let createdAt: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case profession, snug, quote, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profession = try container.decode(String.self, forKey: .profession)
        snug = try container.decode(String.self, forKey: .snug)
        quote = try container.decode(String.self, forKey: .quote)
        
        let createdAtValue = try container.decode([String: Double].self, forKey: .createdAt)
        if let seconds = createdAtValue["_seconds"], let nanoseconds = createdAtValue["_nanoseconds"] {
            createdAt = Timestamp(seconds: Int64(seconds), nanoseconds: Int32(nanoseconds))
        } else {
            createdAt = Timestamp(date: Date())
        }
    }
}
