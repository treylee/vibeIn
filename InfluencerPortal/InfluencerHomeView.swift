// Path: vibeIn/InfluencerPortal/InfluencerHomeView.swift

import SwiftUI
import FirebaseFirestore

struct InfluencerHomeView: View {
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @State private var activeReviews: [InfluencerPortalReview] = []
    @State private var reviewTimer: Timer?
    @State private var localNews: [LocalNewsItem] = []
    @State private var isLoadingNews = true
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    // Sample vibe reviews for the portal
    let sampleReviews = [
        InfluencerPortalReview(text: "Just made $500 from one post! 💰", author: "@lifestyle_guru"),
        InfluencerPortalReview(text: "Connected with amazing brands! ⭐", author: "@foodie_adventures"),
        InfluencerPortalReview(text: "My engagement rate doubled! 📈", author: "@fashion_vibes"),
        InfluencerPortalReview(text: "Best platform for influencers! 🚀", author: "@travel_soul"),
        InfluencerPortalReview(text: "Love the vibe connections! 💜", author: "@wellness_warrior"),
        InfluencerPortalReview(text: "Game changer for content creators! 🎯", author: "@tech_creator"),
        InfluencerPortalReview(text: "Real opportunities, real results! 🌟", author: "@beauty_buzz"),
        InfluencerPortalReview(text: "My followers love these offers! 🔥", author: "@fitness_flow")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                InfluencerPortalBackground()
                
                VStack(spacing: 0) {
                    // Header at top of screen
                    HomePortalHeader(influencer: influencerService.currentInfluencer)
                        .padding(.top, 20)
                        .padding(.bottom, 15)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Review Bubbles Section (above Messages)
                            ReviewBubblesSection(activeReviews: activeReviews)
                                .frame(height: 60) // Small area
                                .padding(.horizontal, 20)
                            
                            // Message Navigation Button
                            MessageNavigationButton()
                                .padding(.horizontal, 20)
                            
                            // You Should Know Section
                            YouShouldKnowSection(
                                localNews: localNews,
                                isLoading: isLoadingNews
                            )
                            
                            // Vibe Discovery Section at bottom
                            VibeDiscoverySection()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100) // Significantly increased bottom padding
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // Reset and start fresh
                activeReviews.removeAll()
                reviewTimer?.invalidate()
                startReviewAnimation()
                loadLocalNews()
            }
            .onDisappear {
                reviewTimer?.invalidate()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func startReviewAnimation() {
        // Clear any existing reviews
        activeReviews.removeAll()
        
        // Start fresh with first review
        addRandomReview()
        
        reviewTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            // Keep only the last 2 reviews to prevent buildup
            if activeReviews.count > 2 {
                activeReviews.removeFirst()
            }
            
            // Add new review
            addRandomReview()
        }
    }
    
    private func addRandomReview() {
        let randomReview = sampleReviews.randomElement()!
        let newReview = InfluencerPortalReview(
            text: randomReview.text,
            author: randomReview.author
        )
        
        activeReviews.append(newReview)
    }
    
    private func loadLocalNews() {
        // Simulate loading local news (in real app, this would be from an API)
        isLoadingNews = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.localNews = [
                LocalNewsItem(
                    title: "New Restaurant Opens Downtown",
                    description: "Popular vegan chain expands to Phoenix area",
                    category: "Food & Dining",
                    imageIcon: "fork.knife"
                ),
                LocalNewsItem(
                    title: "Fashion Week Comes to Scottsdale",
                    description: "Local designers showcase spring collections",
                    category: "Fashion",
                    imageIcon: "sparkles"
                ),
                LocalNewsItem(
                    title: "Tech Startup Funding Surge",
                    description: "Phoenix ranks top 10 for new investments",
                    category: "Business",
                    imageIcon: "dollarsign.circle.fill"
                )
            ]
            self.isLoadingNews = false
        }
    }
}

// MARK: - Portal Background
struct InfluencerPortalBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.pink.opacity(0.05),
                Color.purple.opacity(0.05),
                Color.orange.opacity(0.03)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Portal Header
struct HomePortalHeader: View {
    let influencer: FirebaseInfluencer?
    
    var body: some View {
        VStack(spacing: 12) {
            InfluencerVibeINLogo()
            InfluencerPortalTagline()
            if let influencer = influencer {
                HomeUserIndicator(influencer: influencer)
            }
        }
    }
}

// MARK: - VibeIN Logo
struct InfluencerVibeINLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .blur(radius: 20)
            
            VStack(spacing: -5) {
                Text("vibe")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("IN")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

// MARK: - Portal Tagline
struct InfluencerPortalTagline: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Where Influencers")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            Text("Find Their Vibe")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

// MARK: - User Indicator
struct HomeUserIndicator: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        InfluencerUserBadge(userName: influencer.userName, isVerified: influencer.isVerified)
    }
}

// MARK: - User Badge
struct InfluencerUserBadge: View {
    let userName: String
    let isVerified: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(.pink.opacity(0.6))
            Text(userName)
                .font(.subheadline)
                .foregroundColor(.gray)
            if isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Message Navigation Button
struct MessageNavigationButton: View {
    @EnvironmentObject var navigationState: InfluencerNavigationState
    @State private var showNotification = true
    
    var body: some View {
        Button(action: {
            withAnimation {
                navigationState.selectedTab = .portal
            }
        }) {
            HStack {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "message.fill")
                        .font(.title2)
                        .foregroundColor(.purple.opacity(0.6))
                    
                    // Notification dot
                    if showNotification {
                        Circle()
                            .fill(Color.pink.opacity(0.8))
                            .frame(width: 10, height: 10)
                            .offset(x: 5, y: -2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Messages")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.8))
                    Text("3 new messages from brands")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
        }
    }
}

// MARK: - Review Bubbles Section
struct ReviewBubblesSection: View {
    let activeReviews: [InfluencerPortalReview]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(activeReviews.suffix(3).enumerated()), id: \.element.id) { index, review in
                FloatingReviewBubble(
                    review: review,
                    containerWidth: geometry.size.width,
                    index: index
                )
            }
        }
    }
}

// MARK: - Floating Review Bubble
struct FloatingReviewBubble: View {
    let review: InfluencerPortalReview
    let containerWidth: CGFloat
    let index: Int
    
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.5
    @State private var show = false
    @State private var yOffset: CGFloat = 20
    
    var isLeft: Bool {
        index % 2 == 0
    }
    
    var xPosition: CGFloat {
        if isLeft {
            return 110 // Left side position
        } else {
            return containerWidth - 110 // Right side position
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(review.text)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(review.author)
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: isLeft ? [
                            Color.pink.opacity(0.7),
                            Color.purple.opacity(0.6)
                        ] : [
                            Color.purple.opacity(0.6),
                            Color.orange.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: isLeft ? Color.pink.opacity(0.2) : Color.purple.opacity(0.2), radius: 8, y: 3)
        .scaleEffect(show ? 1.0 : scale)
        .opacity(show ? 1.0 : 0)
        .position(x: xPosition, y: 30 + yOffset)
        .onAppear {
            // Stagger the appearance with smooth pop-in effect
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) {
                // Smooth entrance animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                    show = true
                    yOffset = 0
                }
                
                // Add gentle floating after appearance
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
                    yOffset = isLeft ? -3 : 3
                }
                
                // Smooth fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        show = false
                        scale = 0.8
                        yOffset = -10
                    }
                }
            }
        }
    }
}

// MARK: - You Should Know Section
struct YouShouldKnowSection: View {
    let localNews: [LocalNewsItem]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("You Should Know...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Text("Phoenix, AZ")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            if isLoading {
                NewsLoadingCard()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(localNews) { item in
                            YouShouldKnowCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - You Should Know Card
struct YouShouldKnowCard: View {
    let item: LocalNewsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: item.imageIcon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Spacer()
                Text(item.category)
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Text(item.title)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Text("2 hours ago")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text("Read more →")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
}

// MARK: - News Loading Card
struct NewsLoadingCard: View {
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
            Text("Loading updates...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
}

// MARK: - Vibe Discovery Section (Now at bottom)
struct VibeDiscoverySection: View {
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.horizontal, 40)
            
            InfluencerWelcomeCard()
            
            Button(action: {
                withAnimation {
                    navigationState.selectedTab = .discover
                }
            }) {
                DiscoverVibesButton()
            }
        }
    }
}

// MARK: - Welcome Card
struct InfluencerWelcomeCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.pink.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discover Amazing Vibes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.caption)
                                .foregroundColor(.pink)
                            Text("Find exclusive offers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.purple)
                            Text("Share authentic reviews")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Earn from your influence")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(-15))
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Discover Vibes Button
struct DiscoverVibesButton: View {
    var body: some View {
        HStack {
            Text("Vibes to checkout")
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
                gradient: Gradient(colors: [.pink, .purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.pink.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Supporting Models
struct InfluencerPortalReview: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

struct LocalNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let imageIcon: String
}
