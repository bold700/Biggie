import SwiftUI

struct Theme {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")
    static let background = Color("Background")
    static let text = Color("Text")
    
    static let colors: [String: Color] = [
        "Primary": Color(red: 0.2, green: 0.6, blue: 0.9),    // Vrolijk blauw
        "Secondary": Color(red: 0.9, green: 0.4, blue: 0.4),  // Warm rood
        "Accent": Color(red: 0.4, green: 0.8, blue: 0.4),     // Fris groen
        "Background": Color(red: 0.98, green: 0.98, blue: 1.0), // Lichtblauw
        "Text": Color(red: 0.2, green: 0.2, blue: 0.3)        // Donkerblauw
    ]
    
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let iconSize: CGFloat = 24
    
    static let titleFont = Font.system(.title, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    
    static func buttonStyle() -> some ViewModifier {
        ButtonStyleModifier()
    }
}

struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.primary)
            .foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(radius: 2)
    }
} 