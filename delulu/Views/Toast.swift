import SwiftUI




struct Toast: View {
    @Binding var isShown: Bool
    var title: String? = "title"
    var message: String = "message"
    var icon: Image = Image(systemName: "exclamationmark.circle")
    var alignment: Alignment = .top

    var body: some View {
        VStack {
            if isShown {
                HStack(spacing: 16) {
                    icon
                    VStack(alignment: .leading, spacing: 0) {
                        if let title {
                            Text(title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Text(message)
                            .multilineTextAlignment(.leading)
                        
                        
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(RoundedRectangle(cornerRadius: 8).fill(.red))
                .transition(.move(edge: alignmentToEdge(self.alignment)))
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .animation(.linear(duration: 0.15), value: isShown)
        
    }
    
    private func alignmentToEdge(_ alignment: Alignment) -> Edge {
        switch alignment {
        case .topLeading, .top, .topTrailing:
            return .top
        case .bottomLeading, .bottom, .bottomTrailing:
            return .bottom
        default:
            return .top
        }
    }
}
