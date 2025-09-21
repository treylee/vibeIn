// Path: vibeIn/InfluencerPortal/Components/EventsView.swift

import SwiftUI

// MARK: - Events Coming Soon Content
struct EventsComingSoonContent: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Animated Header
                EventsHeaderView()
                
                // Title and Description
                EventsTitleSection()
                
                // Features Grid
                EventsFeaturesGrid()
                    .padding(.horizontal, 20)
                
                // Coming Soon Button
                EventsComingSoonButton()
                    .padding(.horizontal, 20)
                
                // Launch Timeline
                LaunchTimeline()
                    .padding(.vertical, 20)
                
                // Extra padding at bottom
                Color.clear
                    .frame(height: 100)
            }
            .padding(.top, 20)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Events Title Section
struct EventsTitleSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Local Events Hub")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Build Your Local Community")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text("Connect with fellow influencers, discover exclusive brand events, and create your own meetups")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Events Header View
struct EventsHeaderView: View {
    @State private var animateGradient = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient circle
            EventsBackgroundCircle(animateGradient: animateGradient, floatingOffset: floatingOffset)
            
            // Community illustration
            EventsCommunityIllustration(animateGradient: animateGradient)
        }
        .frame(height: 250)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
                floatingOffset = -10
            }
        }
    }
}

// MARK: - Events Background Circle
struct EventsBackgroundCircle: View {
    let animateGradient: Bool
    let floatingOffset: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.3),
                        Color.pink.opacity(0.3),
                        Color.purple.opacity(0.2)
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
            )
            .frame(width: 200, height: 200)
            .blur(radius: 30)
            .offset(y: floatingOffset)
    }
}

// MARK: - Events Community Illustration
struct EventsCommunityIllustration: View {
    let animateGradient: Bool
    
    var body: some View {
        VStack(spacing: -10) {
            // People icons
            PeopleCircleFormation(animateGradient: animateGradient)
            
            // Coming Soon Badge
            ComingSoonBadge()
        }
    }
}

// MARK: - People Circle Formation
struct PeopleCircleFormation: View {
    let animateGradient: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<6) { index in
                PersonIcon(index: index, animateGradient: animateGradient)
            }
            
            // Center calendar icon
            CenterCalendarIcon(animateGradient: animateGradient)
        }
        .frame(width: 150, height: 150)
    }
}

// MARK: - Person Icon
struct PersonIcon: View {
    let index: Int
    let animateGradient: Bool
    
    var body: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 35))
            .foregroundStyle(
                LinearGradient(
                    colors: gradientColors(for: index),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(
                x: cos(CGFloat(index) * .pi / 3) * 50,
                y: sin(CGFloat(index) * .pi / 3) * 50
            )
            .rotationEffect(.degrees(animateGradient ? 5 : -5))
    }
    
    private func gradientColors(for index: Int) -> [Color] {
        switch index {
        case 0: return [.orange, .pink]
        case 1: return [.pink, .purple]
        case 2: return [.purple, .blue]
        case 3: return [.blue, .cyan]
        case 4: return [.cyan, .green]
        case 5: return [.green, .orange]
        default: return [.gray, .gray]
        }
    }
}

// MARK: - Center Calendar Icon
struct CenterCalendarIcon: View {
    let animateGradient: Bool
    
    var body: some View {
        Image(systemName: "calendar.badge.plus")
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(
                LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
            )
            .scaleEffect(animateGradient ? 1.1 : 1.0)
    }
}

// MARK: - Coming Soon Badge
struct ComingSoonBadge: View {
    var body: some View {
        Text("COMING SOON")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
            )
            .offset(y: 20)
    }
}

// MARK: - Events Features Grid
struct EventsFeaturesGrid: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                EventFeatureCard(
                    icon: "megaphone.fill",
                    title: "Host Events",
                    description: "Create and promote your own meetups",
                    color: .orange
                )
                
                EventFeatureCard(
                    icon: "ticket.fill",
                    title: "VIP Access",
                    description: "Get invited to exclusive launches",
                    color: .pink
                )
            }
            
            HStack(spacing: 16) {
                EventFeatureCard(
                    icon: "person.3.fill",
                    title: "Network",
                    description: "Meet local influencers",
                    color: .purple
                )
                
                EventFeatureCard(
                    icon: "sparkles",
                    title: "Collabs",
                    description: "Find content partners",
                    color: .blue
                )
            }
        }
    }
}

// MARK: - Event Feature Card
struct EventFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Events Coming Soon Button
struct EventsComingSoonButton: View {
    @State private var showNotifySheet = false
    
    var body: some View {
        Button(action: {
            showNotifySheet = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18))
                Text("Get Notified")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.orange, .pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.orange.opacity(0.4), radius: 10, y: 5)
        }
        .sheet(isPresented: $showNotifySheet) {
            EventsNotifySheet()
        }
    }
}

// MARK: - Events Notify Sheet
struct EventsNotifySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 40)
                
                Text("Get Notified")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Be the first to know when Events launches")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                TextField("your@email.com", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                Spacer()
                
                // Updated Button - Coming Soon instead of Notify Me
                Button(action: {
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }) {
                    if showSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("You're on the list!")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                            Text("Coming Soon")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .disabled(true) // Always disabled since it's coming soon
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Launch Timeline (Simplified)
struct LaunchTimeline: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundColor(.orange)
            
            Text("Coming Q1 2026")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.1))
        )
    }
}
