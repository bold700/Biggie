import SwiftUI

struct ProfileView: View {
    let profile: Profile
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "black": return .black
        case "white": return .white
        case "gray", "grey": return .gray
        default: return .blue
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About Me")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(profile.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(profile.age) years")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let color = profile.favoriteColor {
                    Section(header: Text("Favorite Color")) {
                        HStack {
                            Circle()
                                .fill(colorForName(color))
                                .frame(width: 30, height: 30)
                            Text(color)
                        }
                    }
                }
                
                if let character = profile.favoriteCharacter {
                    Section(header: Text("Favorite Character")) {
                        Text(character)
                    }
                }
            }
            .navigationTitle("My Profile")
        }
    }
} 