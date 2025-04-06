import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .black, .white]
    let images: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    let fonts: [String] = ["SfPro","Rooster","PrettySingle", "Ladywish", "CatchyMager"]
    @State private var showImageDialog = false
    @State private var showTextDialog = false
    @State private var fontStyle = "SfPro"
    @State private var bgImg = "1"
    
    var body: some View {
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
                        
                    }) {Image(systemName: "paperplane.fill").padding().font(.title2).foregroundColor(.white)}
                    
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
                    .padding(.horizontal, 32)
                
                Spacer()
                Text("New quote in 2:40mins").foregroundColor(.white).font(.caption)
            }
            .frame(
                width:UIScreen.main.bounds.width
            )
            
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
