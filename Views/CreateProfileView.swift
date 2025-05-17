import SwiftUI

struct CreateProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProfileViewModel
    @State private var name = ""
    @State private var age = 5
    @State private var selectedColor = Color.blue
    
    init(profileUseCases: ProfileUseCases, soundManager: SoundManager) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileUseCases: profileUseCases, soundManager: soundManager))
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
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let newProfile = Profile(
                            name: name,
                            age: age,
                            avatarColor: selectedColor.toHex() ?? "#007AFF"
                        )
                        Task {
                            await viewModel.createProfile(newProfile)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
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
    }
} 