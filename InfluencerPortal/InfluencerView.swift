// Path: vibeIn/InfluencerPortal/InfluencerView.swift

import SwiftUI

struct InfluencerView: View {
    @State private var selectedTab: Int
    
    // Add initializer to set starting tab
    init(startingTab: Int = 0) {
        _selectedTab = State(initialValue: startingTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Search Tab
            InfluencerSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            // Portal Tab (Dashboard)
            InfluencerPortalView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(1)
            
            // Profile Tab
            InfluencerProfileTab()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

// Simple Profile Tab
struct InfluencerProfileTab: View {
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var body: some View {
        NavigationStack {
            if let influencer = influencerService.currentInfluencer {
                InfluencerProfileView(influencer: influencer)
            } else {
                ProgressView("Loading Profile...")
            }
        }
    }
}
