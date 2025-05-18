import SwiftUI

struct RewardsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Rewards")
                    .font(.largeTitle)
                    .bold()
                Text("Here you can manage and view all rewards for your child.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Rewards")
        }
    }
}

#Preview {
    RewardsView()
} 