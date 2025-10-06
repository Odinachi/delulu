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
    @State private var isScreenshoting = false
    @State private var showToast: Bool = false
    @State private var errorMsg: String = ""
    
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
                                if let name = profession["name"] {
                                    Text(name)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .tag(name)
                                }
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
                        .onChange(of: selectedProfession) { oldValue, newValue in
                            updateSelectedSnug(for: newValue)
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
                .onAppear {
                    // Initialize selectedSnug when view appears
                    updateSelectedSnug(for: selectedProfession)
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
                                
                                
                                    .opacity(isScreenshoting ? 0.0 : 1.0)
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
                                    .foregroundColor(.white) .opacity(isScreenshoting ? 0.0 : 1.0)
                            }
                            Button(action: {
                                if !items.isEmpty && currentQuoteIndex < items.count {
                                    let quoteToUpdate = items[currentQuoteIndex]
                                    quoteToUpdate.saved = !(quoteToUpdate.saved ?? false)
                                    
                                    do {
                                        try modelContext.save()
                                    } catch {
                                       
                                        errorMsg = error.localizedDescription
                                        showToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showToast = false
                                        }
                                        
                                    }
                                }
                            }) {
                                Image(systemName: !items.isEmpty && currentQuoteIndex < items.count && (items[currentQuoteIndex].saved == true) ? "bookmark.fill" : "bookmark")
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(.white) .opacity(isScreenshoting ? 0.0 : 1.0)
                            }
                            Button(action: {
                                isScreenshoting = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    takeScreenshotAndShare()
                                   isScreenshoting = false
                                }
                               
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, (showImageDialog || showTextDialog) ? 0 : 100)
                        .padding(.horizontal, 20) .opacity(isScreenshoting ? 0.0 : 1.0)
                        
                        
                        
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
                                        
                                        
                                        VStack {
                                            if items.indices.contains(index) {
                                                Text(items[index].quote)
                                                    .font(.custom(fontStyle, size: 35, relativeTo: .largeTitle))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 30)
                                                    .padding(.top, 100)
                                            } else {
                                                
                                                EmptyView()

                                               
                                            }

                                            Spacer()
                                        }
                                        
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .onChange(of: items.count) { oldCount, newCount in
                                // Reset index if it's out of bounds
                                if currentQuoteIndex >= newCount {
                                    currentQuoteIndex = max(0, newCount - 1)
                                }
                            }
                        } else {
                            Text("No quotes available.")
                                .foregroundColor(.white)
                        }
                        
                        
                        
                        
                        
                       if !isScreenshoting {
                            HStack {
                                Spacer()
                                Button(action: {
                                    if let latestItem = self.items.max(by: { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }) {
                                        MessagingService.shared.unsubscribeFromTopic(latestItem.snug)
                                    }
                                    for item in self.items where item.saved == false {
                                        if let timestamp = item.timestamp, Date().timeIntervalSince(timestamp) > 12 * 60 * 60 {
                                            self.modelContext.delete(item)
                                        }
                                    }
                                    // Reset index and authentication after cleanup
                                    currentQuoteIndex = 0
                                    withAnimation {
                                        authenticated = false
                                    }
                                }) {
                                    Image(systemName: "globe")
                                        .foregroundColor(.white)
                                        .font(.callout)
                                }
                                Spacer()
                            }
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
        }.toast(isShown: $showToast, message: errorMsg)
    }
    
    // Helper function to update selectedSnug
    private func updateSelectedSnug(for professionName: String) {
        if let selected = professionMap.first(where: { $0["name"] == professionName }) {
            selectedSnug = selected["snug"] ?? "software_developer"
        }
    }
    
    private func checkForSavedQuotes() {
        if !items.isEmpty {
            authenticated = true
            // Ensure currentQuoteIndex is valid
            if currentQuoteIndex >= items.count {
                currentQuoteIndex = 0
            }
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
                errorMsg = error.localizedDescription
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showToast = false
                }
            }
        }
    }
    

    
    func takeScreenshotAndShare() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let image = renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        // Share the screenshot
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
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
            print("kkkkkk \(error.localizedDescription)")
           
            errorMsg = error.localizedDescription
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
    }
}

extension View {
    func toast(isShown: Binding<Bool>, title: String? = nil, message: String, icon: Image = Image(systemName: "exclamationmark.circle"), alignment: Alignment = .top) -> some View {
       
        ZStack {
            self
            Toast(isShown: isShown, title: title, message: message, icon: icon, alignment: alignment)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Quote.self, inMemory: true)
}
