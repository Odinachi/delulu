import SwiftUI
import SwiftData
import FirebaseFirestore

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quote.timestamp, order: .reverse) private var items: [Quote]
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .black, .white]
    let images: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let fonts: [String] = ["SfPro","Rooster","PrettySingle", "Ladywish", "CatchyMager"]
    
    @State private var showImageDialog = false
    @State private var showTextDialog = false
    @State private var authenticated = false
    @State private var fontStyle = "SfPro"
    @State private var bgImg = "1"
    
    var professionMap: [[String: String]] = roles  // ensure 'roles' is globally available
    @State private var selectedSnug: String = "software_developer"
    @State private var selectedProfession: String = "Software Developer"
    
    @State private var currentQuoteIndex = 0
    @State private var isLoading = false
    

    
    var body: some View {
        Group {
            if !authenticated {
                ZStack {
                    Image("bg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Select Profession")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 100)
                            .padding(.bottom, 50)
                        
                        Picker("Profession", selection: $selectedProfession) {
                            ForEach(professionMap, id: \.self) { profession in
                                Text(profession["name"] ?? "Unknown")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .tag(profession["name"] ?? "")
                            }
                        }
                        .pickerStyle(.wheel)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                        )
                        .frame(height: 150)
                        .clipped()
                        .onChange(of: selectedProfession) { newValue in
                            if let selected = professionMap.first(where: { $0["name"] == newValue }) {
                                selectedSnug = selected["snug"] ?? ""
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isLoading = true
                            Task {
                                await fetchAndSaveQuote()
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(1.2)
                                    .frame(maxWidth: 300)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal, 32)
                            } else {
                                Text("Start")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: 300)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .disabled(isLoading)
                        
                        Spacer()
                    }
                }
            } else {
                ZStack {
                    Image(bgImg)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showImageDialog = false
                                    showTextDialog.toggle()
                                }
                            }) {
                                Text("T").foregroundColor(.white).font(.title)
                            }
                            Button(action: {
                                withAnimation {
                                    showTextDialog = false
                                    showImageDialog.toggle()
                                }
                            }) {
                                Image(systemName: "paintpalette")
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                if !items.isEmpty && currentQuoteIndex < items.count {
                                    let quoteToUpdate = items[currentQuoteIndex]
                                    quoteToUpdate.saved = !(quoteToUpdate.saved ?? false)
                                    
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("❌ Failed to save quote: \(error)")
                                    }
                                }
                            }) {
                                Image(systemName: !items.isEmpty && currentQuoteIndex < items.count && (items[currentQuoteIndex].saved == true) ? "bookmark.fill" : "bookmark")
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "paperplane.fill")
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, (showImageDialog || showTextDialog) ? 0 : 100)
                        .padding(.horizontal, 20)
                        
                        
                        if showImageDialog {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(images, id: \.self) { imageName in
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .onTapGesture {
                                                withAnimation {
                                                    bgImg = imageName
                                                    showImageDialog.toggle()
                                                }
                                            }
                                    }
                                }
                                .padding(.leading, 20)
                            }
                            .frame(height: 100)
                            .transition(.scale)
                        }
                        
                        if showTextDialog {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(fonts, id: \.self) { fontName in
                                        Text("Aa")
                                            .font(Font.custom(fontName, size: 20, relativeTo: .largeTitle))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .onTapGesture {
                                                withAnimation {
                                                    fontStyle = fontName
                                                    showTextDialog.toggle()
                                                }
                                            }
                                    }
                                }
                                .padding(.leading, 20)
                            }
                            .frame(height: 100)
                            .transition(.scale)
                        }
                        
                        if !items.isEmpty {
                            TabView(selection: $currentQuoteIndex) {
                                ForEach(items.indices, id: \.self) { index in
                                    ZStack {
                                        Color.clear
                                            .ignoresSafeArea()
                                        
                                        
                                        VStack{
                                            Text(items[index].quote)
                                                .font(Font.custom(fontStyle, size: 35, relativeTo: .largeTitle))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 30).padding(.top, 100)
                                            Spacer()
                                        }
                                        
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        } else {
                            Text("No quotes available.")
                                .foregroundColor(.white)
                        }
                        
                        
                        
                        
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                if let latestItem = self.items.max(by: { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }) {
                                    withAnimation {
                                        authenticated = false
                                        MessagingService.shared.unsubscribeFromTopic(latestItem.snug)
                                    }
                                }
                                for item in self.items where item.saved == false {
                                    if let timestamp = item.timestamp, Date().timeIntervalSince(timestamp) > 12 * 60 * 60 {
                                        self.modelContext.delete(item)
                                    }
                                }
                            }) {
                                Image(systemName: "globe")
                                    .foregroundColor(.white)
                                    .font(.callout)
                            }
                            Spacer()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width).onAppear {
                        Task {
                            await refreshQuotes()
                        }
                    }
                }
            }
        }
        .onAppear {
            checkForSavedQuotes()
        }
    }
    
    private func checkForSavedQuotes() {
        if !items.isEmpty {
            authenticated = true
        }
    }
    
    private func refreshQuotes() async {
        guard !items.isEmpty else {
            withAnimation {
                authenticated = false
            }
            return
        }
        if let timestamp = items.first?.timestamp {
            let timeInterval = Date().timeIntervalSince(timestamp)
            if timeInterval < 12 * 60 * 60 {
                return;
            }
        }

        let quoteService = QuoteService(snug: selectedSnug)

        let latestQuote = await withCheckedContinuation { continuation in
            quoteService.fetchLatestQuote { fetchedQuote in
                continuation.resume(returning: fetchedQuote)
            }
        }

        if let latestQuote = latestQuote,
           latestQuote.timestamp != items.first?.timestamp {
            modelContext.insert(latestQuote)

            do {
                try modelContext.save()
            } catch {
                print("❌ Failed to save quote: \(error)")
            }
        }
    }


    
    private func fetchAndSaveQuote() async {
        let quoteService = QuoteService(snug: selectedSnug)
        
        do {
            var finalQuote: Quote?
            let fetchTask = Task<Quote?, Error> {
                return await withCheckedContinuation { continuation in
                    quoteService.fetchLatestQuote { latestQuote in
                        continuation.resume(returning: latestQuote)
                    }
                }
            }
            
            finalQuote = try await fetchTask.value
            
            if finalQuote == nil {
                finalQuote = try await quoteService.createQuote(snug: selectedSnug, profession: selectedProfession)
            }
            
            guard let quote = finalQuote else {
                throw NSError(domain: "QuoteError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Failed to get or create quote"])
            }
            
            for item in self.items where item.saved == false {
                if let timestamp = item.timestamp, Date().timeIntervalSince(timestamp) > 12 * 60 * 60 {
                    self.modelContext.delete(item)
                }
            }
            
            modelContext.insert(quote)
            try  modelContext.save()
            withAnimation {
               
                authenticated = true
            }
            
            MessagingService.shared.subscribeToTopic(selectedSnug)
            
        } catch {
            print("❌ Failed to fetch or save quote: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Quote.self, inMemory: true)
}
