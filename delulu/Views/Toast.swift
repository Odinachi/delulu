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
                    VStack(alignment: .center, spacing: 4) {
                        if let title {
                            Text(title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)   // allow wrapping
                        }
                        
                        Text(message)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)     // allow wrapping
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(RoundedRectangle(cornerRadius: 8).fill(.red))
                .frame(maxWidth: 300) // ✅ full-width container
                .transition(.move(edge: alignmentToEdge(self.alignment)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .animation(.linear(duration: 0.15), value: isShown)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
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
