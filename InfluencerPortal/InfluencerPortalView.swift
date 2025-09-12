// Path: vibeIn/InfluencerPortal/InfluencerPortalView.swift

import SwiftUI

struct InfluencerPortalView: View {
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    @State private var influencerReviews: [InfluencerReview] = []
    @State private var isLoadingReviews = false
    @State private var animateGradient = false
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .ignoresSafeArea()
            
            if let influencer = influencerService.currentInfluencer {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Enhanced Header with gradient accent
                        InfluencerPortalHeader(influencer: influencer)
                        
                        // Main Content with improved design
                        VStack(spacing: 32) {
                            // Active Offers Section with card design
                            VStack(alignment: .leading, spacing: 20) {
                                // Section Header with animated gradient
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                                                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "gift.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.purple, .pink],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Active Offers")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                        Text("Your current collaborations")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // Decorative element
                                    Image(systemName: "arrow.right.circle")
                                        .font(.title3)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .padding(.horizontal, 20)
                                
                                // Content card with subtle shadow
                                VStack {
                                    InfluencerActiveOffersView()
                                        .environmentObject(navigationState)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.02))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 24)
                            
                            // Stylish Divider
                            HStack(spacing: 16) {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.clear, Color.purple.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 1)
                                
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.purple.opacity(0.3))
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.2), Color.clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 40)
                            
                            // Past Reviews Section with enhanced design (centered)
                            VStack(spacing: 20) {
                                // Section Header with animated gradient (centered)
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.orange.opacity(0.1), .yellow.opacity(0.1)],
                                                        startPoint: animateGradient ? .bottomTrailing : .topLeading,
                                                        endPoint: animateGradient ? .topLeading : .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.orange, .yellow],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Past Reviews")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            
                                            Text("Your review history")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        // Review count badge
                                        if !influencerReviews.isEmpty {
                                            Text("\(influencerReviews.count)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [.orange, .yellow],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                )
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                // Content with enhanced styling
                                VStack {
                                    PastReviewsView(reviews: influencerReviews, isLoading: isLoadingReviews)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.02))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            // Bottom decoration
                            VStack(spacing: 12) {
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("You're all caught up!")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.top, 20)
                            
                            // Extra padding at bottom for navigation bar
                            Color.clear
                                .frame(height: 120)
                        }
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            } else {
                // Enhanced loading state
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Setting up your portal")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Just a moment...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            loadInfluencerReviews()
        }
    }
    
    private func loadInfluencerReviews() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        isLoadingReviews = true
        influencerService.getInfluencerReviews(influencerId: influencer.influencerId) { reviews in
            self.influencerReviews = reviews
            self.isLoadingReviews = false
        }
    }
}

// MARK: - Enhanced Header with Better Aesthetics
struct InfluencerPortalHeader: View {
    let influencer: FirebaseInfluencer
    @State private var showSparkle = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient accent line at top
            LinearGradient(
                colors: [.purple, .pink, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 2)
            .opacity(0.8)
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "hand.wave.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange.opacity(0.8))
                                .rotationEffect(.degrees(showSparkle ? 10 : -10))
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showSparkle)
                        }
                        
                        HStack(spacing: 10) {
                            Text(influencer.userName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.black, .black.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            if influencer.isVerified {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        
                        // Stats pills with enhanced design
                        HStack(spacing: 10) {
                            StatPill(
                                icon: "person.2.fill",
                                text: influencer.displayFollowers,
                                colors: [.purple, .pink]
                            )
                            
                            StatPill(
                                icon: "heart.fill",
                                text: influencer.engagementRateDisplay,
                                colors: [.pink, .red]
                            )
                            
                            StatPill(
                                icon: "app.badge",
                                text: influencer.mainPlatform,
                                colors: [.blue, .cyan]
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced profile image
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 75, height: 75)
                            .blur(radius: 10)
                        
                        AsyncImage(url: URL(string: influencer.profileImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                        .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Enhanced Quick Stats with cards
                HStack(spacing: 12) {
                    EnhancedStatCard(
                        value: "\(influencer.completedOffers)",
                        label: "Completed",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        bgGradient: [.green.opacity(0.1), .mint.opacity(0.1)]
                    )
                    
                    EnhancedStatCard(
                        value: "\(influencer.totalReviews)",
                        label: "Reviews",
                        icon: "star.circle.fill",
                        color: .orange,
                        bgGradient: [.orange.opacity(0.1), .yellow.opacity(0.1)]
                    )
                    
                    EnhancedStatCard(
                        value: "\(influencer.joinedOffers)",
                        label: "Joined",
                        icon: "person.crop.circle.badge.checkmark",
                        color: .purple,
                        bgGradient: [.purple.opacity(0.1), .pink.opacity(0.1)]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        .onAppear {
            showSparkle = true
        }
    }
}

// MARK: - Stat Pill Component
struct StatPill: View {
    let icon: String
    let text: String
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.1) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.2) },
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Enhanced Stat Card
struct EnhancedStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let bgGradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: bgGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 70)
                
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(color)
                        
                        Text(value)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Keep the existing ActiveOfferCard and other components...
struct ActiveOfferCard: View {
    let offer: FirebaseOffer
    @State private var navigateToDetail = false
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)
            .environmentObject(navigationState)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Business Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.businessName)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(offer.businessAddress)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Participation
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(offer.participantCount)/\(offer.maxParticipants)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        
                        Text("spots left")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                // Offer Description
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(2)
                
                // Platforms
                HStack(spacing: 8) {
                    ForEach(offer.platforms, id: \.self) { platform in
                        PlatformChip(platform: platform)
                    }
                    
                    Spacer()
                    
                    // Valid Until
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(offer.formattedValidUntil)
                            .font(.caption2)
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

struct PlatformChip: View {
    let platform: String
    
    var platformIcon: String {
        switch platform {
        case "Google": return "globe"
        case "Apple Maps": return "applelogo"
        case "Social Media": return "camera.fill"
        default: return "app"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: platformIcon)
                .font(.caption2)
            Text(platform)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.purple.opacity(0.1))
        .foregroundColor(.purple)
        .cornerRadius(4)
    }
}

struct EmptyOffersState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No active offers")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Check back soon for new opportunities!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}
