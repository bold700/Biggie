import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    init(profileUseCases: ProfileUseCases, soundManager: SoundManager) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileUseCases: profileUseCases, soundManager: soundManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let profile = viewModel.profile {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Avatar
                            Circle()
                                .fill(profile.avatarColorValue)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text(String(profile.name.prefix(1)))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            // Profile Info
                            VStack(spacing: 8) {
                                Text(profile.name)
                                    .font(.title)
                                    .bold()
                                
                                Text("Age: \(profile.age)")
                                    .font(.title3)
                                
                                Text("Coins: \(profile.coins)")
                                    .font(.title3)
                                    .foregroundColor(.yellow)
                            }
                            
                            // Edit Button
                            Button {
                                showingEditProfile = true
                            } label: {
                                Label("Edit Profile", systemImage: "pencil")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "No Profile",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text("Create your profile to get started!")
                    )
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                if let profile = viewModel.profile {
                    EditProfileView(profile: profile) { updatedProfile in
                        Task {
                            await viewModel.updateProfile(updatedProfile)
                        }
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
            await viewModel.loadProfile()
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var age: Int
    @State private var selectedColor: Color
    
    private let profile: Profile
    private let onSave: (Profile) -> Void
    
    init(profile: Profile, onSave: @escaping (Profile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _name = State(initialValue: profile.name)
        _age = State(initialValue: profile.age)
        _selectedColor = State(initialValue: profile.avatarColorValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    Stepper("Age: \(age)", value: $age, in: 5...8)
                }
                
                Section("Avatar Color") {
                    ColorPicker("Select Color", selection: $selectedColor)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedProfile = Profile(
                            id: profile.id,
                            name: name,
                            age: age,
                            avatarColor: selectedColor.toHex() ?? "#007AFF",
                            coins: profile.coins,
                            createdAt: profile.createdAt
                        )
                        onSave(updatedProfile)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 