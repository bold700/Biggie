import SwiftUI

struct CreateProfileView: View {
    @Binding var profile: Profile?
    @State private var name = ""
    @State private var age = 7
    @State private var favoriteColor = ""
    @State private var favoriteCharacter = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let maxNameLength = 20
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Who are you?")) {
                    TextField("Your name", text: $name)
                        .onChange(of: name) { newValue in
                            if newValue.count > maxNameLength {
                                name = String(newValue.prefix(maxNameLength))
                            }
                        }
                    
                    Stepper("Age: \(age)", value: $age, in: 4...12)
                }
                
                Section(header: Text("What do you like?")) {
                    TextField("Favorite color", text: $favoriteColor)
                    TextField("Favorite character", text: $favoriteCharacter)
                }
                
                Button(action: validateAndCreateProfile) {
                    Text("Start your adventure!")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(name.isEmpty)
            }
            .navigationTitle("Welcome to Biggie!")
            .alert("Oops!", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func validateAndCreateProfile() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter your name"
            showingAlert = true
            return
        }
        
        if age < 4 || age > 12 {
            alertMessage = "Age must be between 4 and 12"
            showingAlert = true
            return
        }
        
        let newProfile = Profile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age,
            favoriteColor: favoriteColor.isEmpty ? nil : favoriteColor,
            favoriteCharacter: favoriteCharacter.isEmpty ? nil : favoriteCharacter
        )
        
        Profile.save(newProfile)
        profile = newProfile
    }
} 