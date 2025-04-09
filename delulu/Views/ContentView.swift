import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [Quote]
    
    let quoteService = QuoteService(snug: "")
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .black, .white]
    
    let images: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    
    let fonts: [String] = ["SfPro","Rooster","PrettySingle", "Ladywish", "CatchyMager"]
    
    @State private var showImageDialog = false
    
    @State private var showTextDialog = false
    
    @State private var authenticated = false
    
    @State private var fontStyle = "SfPro"
    
    @State private var bgImg = "1"
    
    var professionMap:[[String: String]] = roles
    
    @State private var selectedSnug: String = "software_developer"
    
    @State private var selectedName: String = "Software Developer"
    
    
    init() {
           // This temporary value will be replaced when the view is created
           _authenticated = State(initialValue: false)
       }
    
    
    
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
                            .foregroundColor(.white).padding(.top, 100).padding(.bottom,50)
                        Picker("Profession", selection: $selectedName) {
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
                        .onChange(of: selectedName) { oldValue, newValue in
                            if let selected = professionMap.first(where: { $0["name"] == newValue }) {
                                selectedSnug = selected["snug"] ?? ""
                            }
                        }
                        
                        Spacer()
                        Button(action: {
                            let newQuote = Quote(quote: "Compiler error is not compiling", snug: selectedSnug, saved: false, timestamp: Date.now)
                            modelContext.insert(newQuote)
                            
                            do {
                                try modelContext.save()
                                withAnimation {
                                    authenticated = true
                                }
                            } catch {
                                print("❌ Failed to save quote: \(error)")
                            }
                        }) {
                            Text("Start")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth:300)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                    }
                    
                }
            }
            else {
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
                                    showImageDialog = false;
                                    showTextDialog.toggle()
                                    
                                }
                            }) {
                                Text("T").foregroundColor(.white).font(.title)
                            }
                            Button(action: {
                                withAnimation {
                                    showTextDialog = false;
                                    showImageDialog.toggle()
                                }
                            }){ Image(systemName: "paintpalette").padding().font(.title2).foregroundColor(.white)}
                            
                            Button(action: {
                                
                            })  { Image(systemName: "bookmark.fill").padding().font(.title2).foregroundColor(.white)}
                            Button(action: {
                                
                            }) { Image(systemName: "paperplane.fill").padding().font(.title2).foregroundColor(.white)}
                            
                        }.padding(.bottom,  showImageDialog||showTextDialog ?0:100).padding(.horizontal,20)
                        
                        
                        if showImageDialog {
                            ScrollView([.horizontal],showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(images, id: \.self) { imageName in
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2)).padding(.all, 1).onTapGesture {
                                                withAnimation{
                                                    bgImg = imageName
                                                    showImageDialog.toggle()}
                                            }
                                    }
                                }.padding(.leading, 20)
                            }
                            .frame(height: 100)
                            .transition(.scale)
                        }
                        if showTextDialog {
                            ScrollView([.horizontal],showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(fonts, id: \.self) { fontName in
                                        Text("Aa")
                                            .font(Font.custom(fontName, size: 20, relativeTo: .largeTitle))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .padding(.all, 10)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2)).padding(.all, 1).onTapGesture {
                                                withAnimation{
                                                    fontStyle = fontName
                                                    showTextDialog.toggle()
                                                }
                                            }
                                    }
                                }.padding(.leading, 20)
                            }
                            .frame(height: 100)
                            .transition(.scale)
                        }
                        
                        Text("If it compiles without errors, that's a red flag. You clearly forgot something.")
                            .font(Font.custom(fontStyle, size: 35, relativeTo: .largeTitle))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 80)
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Text("New quote in 2:40mins").foregroundColor(.white).font(.caption)
                            Button(action: {
                                withAnimation {
                                    authenticated = false
                                }
                            }){
                                Image(systemName: "globe").foregroundColor(.white).font(.callout)
                            }
                            Spacer()
                        }
                    }
                    .frame(
                        width:UIScreen.main.bounds.width
                    )
                    
                    
                    
                }
            }
        }.onAppear {
            checkForSavedQuotes()
        }
    }
    
    
    private func checkForSavedQuotes() {
    
         if !items.isEmpty {
             authenticated = true
         }
     }
}

#Preview {
    ContentView()
        .modelContainer(for: Quote.self, inMemory: true)
}
