import SwiftUI

struct InfoCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    InfoCard(label: "Coins", value: "10")
} 