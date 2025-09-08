// Path: vibeIn/vibeInApp.swift

import SwiftUI
import FirebaseCore

@main
struct VibeIn: App {
    
    init() {
        // Configure Firebase when app launches
        FirebaseApp.configure()
        print("🔥 Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView().preferredColorScheme(.light) 
        }
    }
}
