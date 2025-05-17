import SwiftUI

struct ParentControlView: View {
    @StateObject private var viewModel: ParentControlViewModel
    @StateObject private var privacyManager: PrivacyManager
    @State private var showingPinEntry = false
    @State private var pinCode = ""
    @State private var showingPinChange = false
    @State private var newPinCode = ""
    @State private var showingPrivacyPolicy = false
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        parentControlUseCases: ParentControlUseCases,
        soundManager: SoundManager,
        privacyManager: PrivacyManager = PrivacyManager()
    ) {
        _viewModel = StateObject(wrappedValue: ParentControlViewModel(
            parentControlUseCases: parentControlUseCases,
            soundManager: soundManager
        ))
        _privacyManager = StateObject(wrappedValue: privacyManager)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .accessibilityLabel("Loading")
                } else if let parentControl = viewModel.parentControl {
                    if viewModel.isAuthenticated {
                        authenticatedView(parentControl)
                    } else {
                        pinEntryView
                    }
                }
            }
            .navigationTitle("Parent Controls")
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView(privacyManager: privacyManager)
            }
        }
        .task {
            if !privacyManager.isPrivacyPolicyAccepted {
                showingPrivacyPolicy = true
            }
            await viewModel.loadParentControl()
        }
    }
    
    private var pinEntryView: some View {
        VStack(spacing: 20) {
            Text("Enter PIN Code")
                .font(.title)
                .accessibilityAddTraits(.isHeader)
            
            SecureField("PIN Code", text: $pinCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(maxWidth: 200)
                .accessibilityLabel("PIN Code Entry")
                .accessibilityHint("Enter your 4-digit PIN code")
            
            Button("Submit") {
                Task {
                    await viewModel.validatePinCode(pinCode)
                    if viewModel.isAuthenticated {
                        pinCode = ""
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Submit PIN")
            .accessibilityHint("Submit your PIN code to access parent controls")
            
            if privacyManager.grantedPermissions.contains(.faceID) {
                Button("Use Face ID") {
                    Task {
                        do {
                            if try await privacyManager.requestPermission(.faceID) {
                                await viewModel.validatePinCode("faceid")
                            }
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Use Face ID")
                .accessibilityHint("Authenticate using Face ID")
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    private func authenticatedView(_ parentControl: ParentControl) -> some View {
        Form {
            Section {
                Toggle("Enable Parent Controls", isOn: Binding(
                    get: { parentControl.isEnabled },
                    set: { _ in
                        Task {
                            await viewModel.toggleParentControl()
                        }
                    }
                ))
                .accessibilityLabel("Enable Parent Controls")
                .accessibilityHint("Toggle to enable or disable parent control features")
            }
            
            Section("Daily Goal Limit") {
                Stepper("\(parentControl.dailyGoalLimit) goals per day", value: Binding(
                    get: { parentControl.dailyGoalLimit },
                    set: { newValue in
                        Task {
                            await viewModel.updateDailyLimit(newValue)
                        }
                    }
                ), in: 1...20)
                .accessibilityLabel("Daily Goal Limit")
                .accessibilityHint("Set the maximum number of goals that can be completed per day")
            }
            
            Section {
                Button("Change PIN Code") {
                    showingPinChange = true
                }
                .accessibilityLabel("Change PIN Code")
                .accessibilityHint("Tap to change your PIN code")
                
                Button("Privacy Settings") {
                    showingPrivacyPolicy = true
                }
                .accessibilityLabel("Privacy Settings")
                .accessibilityHint("View and manage privacy settings")
            }
        }
        .sheet(isPresented: $showingPinChange) {
            NavigationView {
                Form {
                    Section {
                        SecureField("New PIN Code", text: $newPinCode)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("New PIN Code")
                            .accessibilityHint("Enter your new 4-digit PIN code")
                    }
                }
                .navigationTitle("Change PIN")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingPinChange = false
                            newPinCode = ""
                        }
                        .accessibilityLabel("Cancel PIN Change")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                await viewModel.updatePinCode(newPinCode)
                                showingPinChange = false
                                newPinCode = ""
                            }
                        }
                        .disabled(newPinCode.count != 4 || !newPinCode.allSatisfy { $0.isNumber })
                        .accessibilityLabel("Save New PIN")
                        .accessibilityHint("Save your new PIN code")
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ParentControlView_Previews: PreviewProvider {
    static var previews: some View {
        ParentControlView(
            parentControlUseCases: ParentControlUseCases(
                repository: ParentControlRepository(),
                validator: DefaultParentControlValidator()
            ),
            soundManager: SoundManager()
        )
    }
} 