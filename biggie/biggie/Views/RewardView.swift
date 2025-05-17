import SwiftUI

struct RewardView: View {
    @StateObject private var viewModel: RewardViewModel
    @State private var showingAddReward = false
    
    init(rewardUseCases: RewardUseCases, profileUseCases: ProfileUseCases, soundManager: SoundManager) {
        _viewModel = StateObject(wrappedValue: RewardViewModel(
            rewardUseCases: rewardUseCases,
            profileUseCases: profileUseCases,
            soundManager: soundManager
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.rewards.isEmpty {
                    ContentUnavailableView(
                        "No Rewards Yet",
                        systemImage: "gift",
                        description: Text("Add your first reward to get started!")
                    )
                } else {
                    List {
                        ForEach(viewModel.rewards) { reward in
                            RewardRow(reward: reward) {
                                Task {
                                    await viewModel.unlockReward(reward)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await viewModel.deleteReward(viewModel.rewards[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rewards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReward = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReward) {
                CreateRewardView { newReward in
                    Task {
                        await viewModel.createReward(newReward)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await viewModel.loadRewards()
        }
    }
}

struct RewardRow: View {
    let reward: Reward
    let onUnlock: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reward.title)
                    .font(.headline)
                Text(reward.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Cost: \(reward.cost) coins")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Spacer()
            
            if !reward.isUnlocked {
                Button {
                    onUnlock()
                } label: {
                    Image(systemName: "gift")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            } else {
                Image(systemName: "gift.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CreateRewardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var cost = 1
    
    let onSave: (Reward) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Reward Title", text: $title)
                    TextField("Description", text: $description)
                    Stepper("Cost: \(cost) coins", value: $cost, in: 1...100)
                }
            }
            .navigationTitle("New Reward")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newReward = Reward(
                            title: title,
                            description: description,
                            cost: cost
                        )
                        onSave(newReward)
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
} 