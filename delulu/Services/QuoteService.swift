import Foundation
import FirebaseFirestore

class QuoteService: ObservableObject {
    
    let snug: String
    @Published var quote: String = ""
    
    private let db = Firestore.firestore()
    
    init(snug: String) {
        self.snug = snug
    }
    
    
    func createQuote(snug: String, profession: String) async throws -> Quote {
        guard let url = URL(string: "https://us-central1-delulu-863d4.cloudfunctions.net/generateSatireQuotesManually") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: String] = [
            "snug": snug,
            "profession": profession
        ]
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        
        let decoder = JSONDecoder()
        let satireResponse = try decoder.decode(SatireQuoteResponse.self, from: data)
        
        let fetchedQuote = Quote(
            quote: satireResponse.quotes.quote,
            snug: satireResponse.quotes.snug,
            saved: false,
            timestamp: satireResponse.quotes.createdAt
        )

        return fetchedQuote
    }
    
    
    
    func fetchLatestQuote(completion: @escaping (Quote?) -> Void) {
    
        db.collection("Quotes")
            .order(by: "createdAt", descending: true)
            .whereField("snug", isEqualTo: snug)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
       
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
           
                    completion(nil)
                    return
                }
                
                let data = document.data()
                
                guard let text = data["quote"] as? String,
                      let timestamp = data["createdAt"] as? Timestamp else {
                   
                    completion(nil)
                    return
                }
                
                _ = timestamp.dateValue()
                let fetchedQuote = Quote(quote: text, snug: self.snug, saved: false, timestamp: timestamp)
                completion(fetchedQuote)
            }
        
    }
    
    
}

let roles: [[String: String]] = [
    ["name": "Software Developer", "snug": "software_developer"],
    ["name": "Mobile Developer", "snug": "mobile_developer"],
    ["name": "Web Developer", "snug": "web_developer"],
    ["name": "Game Developer", "snug": "game_developer"],
    ["name": "DevOps & Cloud Engineer", "snug": "devops_cloud_engineer"],
    ["name": "Data Analyst / Scientist", "snug": "data_analyst_scientist"],
    ["name": "Machine Learning / AI Engineer", "snug": "ml_ai_engineer"],
    ["name": "Cybersecurity Specialist", "snug": "cybersecurity_specialist"],
    ["name": "QA / Test Engineer", "snug": "qa_test_engineer"],
    ["name": "Product / Platform Engineer", "snug": "product_platform_engineer"],
    ["name": "UI/UX / Product Designer", "snug": "ui_ux_designer"],
    ["name": "Project / Program Manager", "snug": "project_program_manager"],
    ["name": "Technical Writer / Advocate", "snug": "technical_writer_advocate"],
    ["name": "Blockchain / Web3 Engineer", "snug": "blockchain_web3_engineer"],
    ["name": "Marketing & Growth", "snug": "marketing_growth"],
    ["name": "Sales & Business Development", "snug": "sales_business_dev"],
    ["name": "Human Resources / Recruiting", "snug": "hr_recruiting"],
    ["name": "Finance & Legal", "snug": "finance_legal"],
    ["name": "Creative & Media", "snug": "creative_media"],
    ["name": "Customer Support & Operations", "snug": "support_operations"]
]


