// Path: vibeIn/SharedComponents/SharedComponents.swift

import SwiftUI

// MARK: - vibeIN Logo Components

/// Small vibeIN logo for headers and navigation
struct SmallVibeINLogo: View {
    var body: some View {
        HStack(spacing: -2) {
            Text("vibe")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(" IN")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

/// Medium vibeIN logo for splash screens and main headers
struct MediumVibeINLogo: View {
    var body: some View {
        HStack(spacing: -5) {
            Text("vibe")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("IN")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

/// Large vibeIN logo with glow effect for login/splash screens
struct LargeVibeINLogo: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Glowing background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 30)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(spacing: -8) {
                Text("vibe")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("IN")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}
