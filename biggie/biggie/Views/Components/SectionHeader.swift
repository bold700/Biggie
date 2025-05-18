import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .bold()
            .padding(.vertical, 8)
    }
}

#Preview {
    SectionHeader(title: "Summary")
} 