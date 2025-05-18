//
//  ContentView.swift
//  biggie
//
//  Created by Kenny Timmer on 18/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var profile: Profile = Profile.example
    @State private var goals: [Goal] = Goal.examples

    var body: some View {
        TabView {
            OverviewView(profile: profile, goals: goals)
                .tabItem {
                    Label("Overview", systemImage: "house.fill")
                }
            GoalsView(goals: $goals)
                .tabItem {
                    Label("Goals", systemImage: "checkmark.circle.fill")
                }
            RewardsView()
                .tabItem {
                    Label("Rewards", systemImage: "gift.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
