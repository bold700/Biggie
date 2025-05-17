import SwiftUI
import UserNotifications
import UIKit

struct PrivacyPolicyView: View {
    @StateObject private var privacyManager: PrivacyManager
    @State private var showingPermissions = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    init(privacyManager: PrivacyManager = PrivacyManager()) {
        _privacyManager = StateObject(wrappedValue: privacyManager)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .accessibilityAddTraits(.isHeader)
                    
                    Group {
                        Text("Data Collection")
                            .font(.headline)
                        Text("We collect minimal data necessary for the app's functionality:")
                        BulletPoint("Goals and progress")
                        BulletPoint("Parent control settings")
                        BulletPoint("Basic analytics for app improvement")
                    }
                    
                    Group {
                        Text("Data Storage")
                            .font(.headline)
                        Text("Your data is stored securely:")
                        BulletPoint("PIN codes are stored in the Keychain")
                        BulletPoint("Other data is stored locally on your device")
                        BulletPoint("No data is shared with third parties")
                    }
                    
                    Group {
                        Text("Permissions")
                            .font(.headline)
                        Text("The app may request the following permissions:")
                        BulletPoint("Face ID/Touch ID for secure access")
                        BulletPoint("Notifications for goal reminders")
                        BulletPoint("Analytics for app improvement")
                    }
                    
                    if !privacyManager.isPrivacyPolicyAccepted {
                        Button("Accept Privacy Policy") {
                            Task {
                                await acceptPrivacyPolicy()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                        .disabled(isLoading)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPermissions) {
                PermissionsView(privacyManager: privacyManager)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await restoreState()
                }
            }
        }
    }
    
    private func acceptPrivacyPolicy() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await privacyManager.acceptPrivacyPolicy()
            showingPermissions = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func restoreState() async {
        do {
            try await privacyManager.restoreState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .padding(.trailing, 5)
            Text(text)
        }
        .padding(.leading)
    }
}

struct PermissionsView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @State private var isRequesting = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(Array(PrivacyPermission.allCases), id: \.self) { permission in
                        PermissionRow(
                            permission: permission,
                            isGranted: privacyManager.grantedPermissions.contains(permission),
                            isRequesting: isRequesting
                        ) {
                            Task {
                                await requestPermission(permission)
                            }
                        }
                    }
                } header: {
                    Text("Required Permissions")
                } footer: {
                    Text("These permissions are necessary for the app to function properly.")
                }
            }
            .navigationTitle("Permissions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .overlay {
                if isRequesting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    private func requestPermission(_ permission: PrivacyPermission) async {
        isRequesting = true
        errorMessage = nil
        
        do {
            _ = try await privacyManager.requestPermission(permission)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isRequesting = false
    }
}

struct PermissionRow: View {
    let permission: PrivacyPermission
    let isGranted: Bool
    let isRequesting: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(permission.rawValue)
                    .font(.headline)
                Text(permissionDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: action) {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Text("Grant")
                    }
                }
                .disabled(isRequesting)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var permissionDescription: String {
        switch permission {
        case .faceID:
            return "Secure access to parent controls"
        case .notifications:
            return "Receive goal reminders"
        case .analytics:
            return "Help improve the app"
        case .location:
            return "Location-based features"
        }
    }
}

extension PrivacyPermission: CaseIterable {
    static var allCases: [PrivacyPermission] = [.faceID, .notifications, .analytics, .location]
}

// MARK: - Previews
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrivacyPolicyView()
                .previewDisplayName("Light Mode")
            
            PrivacyPolicyView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionsView(privacyManager: PrivacyManager())
                .previewDisplayName("Light Mode")
            
            PermissionsView(privacyManager: PrivacyManager())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 