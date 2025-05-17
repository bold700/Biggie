import SwiftUI

struct ParentControl: Codable {
    var pinCode: String
    var isEnabled: Bool
    var dailyGoalLimit: Int
    var allowedRewards: [String]
    
    static let `default` = ParentControl(
        pinCode: "1234",
        isEnabled: false,
        dailyGoalLimit: 5,
        allowedRewards: ["Sticker", "Playtime", "Coin"]
    )
}

struct ParentControlView: View {
    @AppStorage("parentControl") private var parentControlData: Data = try! JSONEncoder().encode(ParentControl.default)
    @State private var parentControl: ParentControl = ParentControl.default
    @State private var isUnlocked = false
    @State private var enteredPin = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            if isUnlocked {
                Form {
                    Section(header: Text("Parent Controls")) {
                        Toggle("Enable Parent Controls", isOn: $parentControl.isEnabled)
                        
                        Stepper("Daily Goal Limit: \(parentControl.dailyGoalLimit)", 
                               value: $parentControl.dailyGoalLimit, in: 1...10)
                        
                        NavigationLink("Manage Rewards") {
                            RewardManagementView(allowedRewards: $parentControl.allowedRewards)
                        }
                    }
                    
                    Section(header: Text("Security")) {
                        SecureField("Change PIN", text: $enteredPin)
                            .keyboardType(.numberPad)
                        
                        Button("Update PIN") {
                            if enteredPin.count == 4 {
                                parentControl.pinCode = enteredPin
                                saveParentControl()
                                enteredPin = ""
                                alertMessage = "PIN updated successfully!"
                                showingAlert = true
                            } else {
                                alertMessage = "PIN must be 4 digits"
                                showingAlert = true
                            }
                        }
                    }
                }
                .navigationTitle("Parent Controls")
                .onChange(of: parentControl) { _ in
                    saveParentControl()
                }
            } else {
                VStack(spacing: 20) {
                    Text("Parent Controls")
                        .font(Theme.titleFont)
                    
                    SecureField("Enter PIN", text: $enteredPin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                    
                    Button("Unlock") {
                        if enteredPin == parentControl.pinCode {
                            isUnlocked = true
                            enteredPin = ""
                        } else {
                            alertMessage = "Incorrect PIN"
                            showingAlert = true
                        }
                    }
                    .modifier(Theme.buttonStyle())
                }
                .padding()
            }
        }
        .alert("Message", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadParentControl()
        }
    }
    
    private func loadParentControl() {
        if let control = try? JSONDecoder().decode(ParentControl.self, from: parentControlData) {
            parentControl = control
        }
    }
    
    private func saveParentControl() {
        if let encoded = try? JSONEncoder().encode(parentControl) {
            parentControlData = encoded
        }
    }
}

struct RewardManagementView: View {
    @Binding var allowedRewards: [String]
    @State private var newReward = ""
    
    var body: some View {
        List {
            Section(header: Text("Add New Reward")) {
                HStack {
                    TextField("Reward name", text: $newReward)
                    Button("Add") {
                        if !newReward.isEmpty {
                            allowedRewards.append(newReward)
                            newReward = ""
                        }
                    }
                }
            }
            
            Section(header: Text("Allowed Rewards")) {
                ForEach(allowedRewards, id: \.self) { reward in
                    Text(reward)
                }
                .onDelete { indexSet in
                    allowedRewards.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Manage Rewards")
    }
} 