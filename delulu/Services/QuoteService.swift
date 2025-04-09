import Foundation
import FirebaseFirestore

class QuoteService: ObservableObject {
    
    let snug: String
    @Published var quote: String = ""
    
    private let db = Firestore.firestore()
    
    init(snug: String) {
        self.snug = snug
    }
    
    func fetchLatestQuote(completion: @escaping (Quote?) -> Void) {
        db.collection("Quotes")
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching latest quote: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No quotes found")
                    completion(nil)
                    return
                }
                
                let data = document.data()
                
                guard let text = data[self.snug] as? String,
                      let dateString = data["date"] as? String,
                      let date = QuoteService.parseDate(from: dateString) else {
                    print("Invalid data in document")
                    completion(nil)
                    return
                }
                
                let fetchedQuote = Quote(quote: text, snug: self.snug, saved: false, timestamp: date)
                completion(fetchedQuote)
            }
    }
    
    private static func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string)
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
