// Path: vibeIn/BizzPortal/BizzPortalView.swift

import SwiftUI

struct BizzPortalView: View {
    @StateObject private var userService = FirebaseUserService.shared
    @State private var activeReviews: [PortalVibeReview] = []
    @State private var reviewTimer: Timer?
    
    // Sample vibe reviews for the portal
    let sampleReviews = [
        PortalVibeReview(text: "This platform changed my business! 🚀", author: "@bizz_owner1"),
        PortalVibeReview(text: "Connected with amazing influencers! 💯", author: "@restaurant_pro"),
        PortalVibeReview(text: "Our sales doubled in just 2 months! 📈", author: "@cafe_vibes"),
        PortalVibeReview(text: "Best decision for our business growth! ⭐", author: "@retail_guru"),
        PortalVibeReview(text: "The vibe network is incredible! 🌟", author: "@fitness_studio"),
        PortalVibeReview(text: "Game changer for local businesses! 🎯", author: "@beauty_salon"),
        PortalVibeReview(text: "Love the influencer connections! 💜", author: "@foodie_spot"),
        PortalVibeReview(text: "Our brand is thriving now! 🔥", author: "@boutique_life")
    ]
    
    var body: some View {
        ZStack {
            PortalBackground()
            PortalReviewBubbles(activeReviews: activeReviews)
            
            VStack {
                PortalHeader(userService: userService)
                
                Spacer()
                
                // Always show create business section in signup flow
                CreateBusinessSection(navigateToSearch: .constant(false))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50) // Less padding since no bottom nav
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startReviewAnimation()
        }
        .onDisappear {
            reviewTimer?.invalidate()
        }
    }
    
    private func startReviewAnimation() {
        addRandomReview()
        
        reviewTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if activeReviews.count > 3 {
                if let oldestReview = activeReviews.first {
                    activeReviews.removeAll { $0.id == oldestReview.id }
                }
            }
            addRandomReview()
        }
    }
    
    private func addRandomReview() {
        let randomReview = sampleReviews.randomElement()!
        let newReview = PortalVibeReview(
            text: randomReview.text,
            author: randomReview.author
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            activeReviews.append(newReview)
        }
    }
}

// MARK: - Portal Background
struct PortalBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.05),
                Color.purple.opacity(0.05),
                Color.pink.opacity(0.03)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Portal Review Bubbles Container
struct PortalReviewBubbles: View {
    let activeReviews: [PortalVibeReview]
    
    var body: some View {
        // Confined area for bubbles - very center of screen
        GeometryReader { geometry in
            let bubbleZoneHeight: CGFloat = 150 // Smaller zone
            let bubbleZoneY = geometry.size.height / 2 - bubbleZoneHeight / 2
            
            ZStack {
                ForEach(activeReviews) { review in
                    FloatingPortalReviewBubble(
                        review: review,
                        containerWidth: geometry.size.width,
                        bubbleZoneY: bubbleZoneY,
                        bubbleZoneHeight: bubbleZoneHeight
                    )
                }
            }
        }
    }
}

// MARK: - Portal Header
struct PortalHeader: View {
    @ObservedObject var userService: FirebaseUserService
    
    var body: some View {
        VStack(spacing: 20) {
            VibeINLogo()
            PortalTagline()
            UserIndicator(userService: userService)
        }
        .padding(.top, 60)
    }
}

// MARK: - VibeIN Logo
struct VibeINLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .blur(radius: 20)
            
            VStack(spacing: -5) {
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
}

// MARK: - Portal Tagline
struct PortalTagline: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Where Businesses")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            Text("Meet Their Vibe")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

// MARK: - User Indicator
struct UserIndicator: View {
    @ObservedObject var userService: FirebaseUserService
    
    var body: some View {
        Group {
            if userService.isLoading {
                LoadingDots()
            } else if let user = userService.currentUser {
                UserBadge(userName: user.userName)
            }
        }
    }
}

// MARK: - Loading Dots
struct LoadingDots: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - User Badge
struct UserBadge: View {
    let userName: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(.purple.opacity(0.6))
            Text(userName)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Create Business Section
struct CreateBusinessSection: View {
    @Binding var navigateToSearch: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            WelcomeCard()
            
            NavigationLink(destination: BizzSelectionView()) {
                CreateBusinessButton()
            }
        }
    }
}

// MARK: - Welcome Card
struct WelcomeCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Now a Larger Online Presence")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.purple)
                            Text("Connect to influencers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.pink)
                            Text("Compare yourself")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Get analytics & advertisements")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "rocket.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(-45))
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Create Business Button
struct CreateBusinessButton: View {
    var body: some View {
        HStack {
            Text("Ready to grow?")
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: "arrow.right")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color(red: 254/255, green: 61/255, blue: 87/255) // Tinder red
        )
        .cornerRadius(16)
        .shadow(color: Color(red: 254/255, green: 61/255, blue: 87/255).opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Business Dashboard Section
struct BusinessDashboardSection: View {
    let business: FirebaseBusiness
    @Binding var navigateToDashboard: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            BusinessCard(business: business)
            
            NavigationLink(destination: BusinessDashboardView(business: business)) {
                DashboardButton()
            }
        }
    }
}

// MARK: - Business Card
struct BusinessCard: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 16) {
            BusinessCardHeader(business: business)
            BusinessCardStats(business: business)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 15, y: 5)
    }
}

// MARK: - Business Card Header
struct BusinessCardHeader: View {
    let business: FirebaseBusiness
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR VIBE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple.opacity(0.8))
                    .tracking(1.5)
                
                Text(business.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(business.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VibeIndicator()
        }
    }
}

// MARK: - Vibe Indicator
struct VibeIndicator: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
            
            Image(systemName: "waveform")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

// MARK: - Business Card Stats
struct BusinessCardStats: View {
    let business: FirebaseBusiness
    
    var body: some View {
        HStack(spacing: 0) {
            MinimalStat(
                value: String(format: "%.1f", business.rating ?? 0.0),
                icon: "star.fill",
                color: .orange
            )
            
            Divider()
                .frame(height: 30)
                .padding(.horizontal, 20)
            
            MinimalStat(
                value: "\(business.reviewCount ?? 0)",
                icon: "bubble.left.fill",
                color: .purple
            )
            
            Divider()
                .frame(height: 30)
                .padding(.horizontal, 20)
            
            MinimalStat(
                value: business.category,
                icon: "tag.fill",
                color: .pink
            )
        }
    }
}

// MARK: - Dashboard Button
struct DashboardButton: View {
    var body: some View {
        HStack {
            Text("Enter Dashboard")
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: "arrow.right")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [.purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Loading Business View
struct LoadingBusinessView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 8)
                        .scaleEffect(x: isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("Setting up your vibe...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Portal Vibe Review Model
struct PortalVibeReview: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

// MARK: - Floating Portal Review Bubble
struct FloatingPortalReviewBubble: View {
    let review: PortalVibeReview
    let containerWidth: CGFloat
    let bubbleZoneY: CGFloat
    let bubbleZoneHeight: CGFloat
    
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.8
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(review.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Text(review.author)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
        .scaleEffect(scale)
        .opacity(opacity)
        .position(x: containerWidth / 2 + offsetX, y: bubbleZoneY + bubbleZoneHeight / 2 + offsetY)
        .onAppear {
            // Start at center
            position = CGPoint(
                x: containerWidth / 2,
                y: bubbleZoneY + bubbleZoneHeight / 2
            )
            
            // Fade in
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // Subtle drift animation - pick a random direction
            let angle = Double.random(in: 0...(2 * .pi))
            let distance: CGFloat = 30 // Only 30 points of movement
            
            withAnimation(.easeInOut(duration: 6)) {
                offsetX = cos(angle) * distance
                offsetY = sin(angle) * distance
            }
            
            // Fade out after 8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    scale = 0.9
                }
            }
        }
    }
}

// MARK: - Minimal Stat
struct MinimalStat: View {
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}
