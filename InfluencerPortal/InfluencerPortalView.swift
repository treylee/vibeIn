// Path: vibeIn/InfluencerPortal/InfluencerPortalView.swift

import SwiftUI

struct InfluencerPortalView: View {
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    @State private var selectedTab = 0
    @State private var influencerReviews: [InfluencerReview] = []
    @State private var isLoadingReviews = false
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.1),
                    Color.orange.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let influencer = influencerService.currentInfluencer {
                VStack(spacing: 0) {
                    // Header
                    InfluencerPortalHeader(influencer: influencer)
                    
                    // Tab View
                    InfluencerTabBar(selectedTab: $selectedTab)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        // Active Offers Tab
                        InfluencerActiveOffersView()
                            .environmentObject(navigationState)
                            .tag(0)
                        
                        // Past Reviews Tab
                        PastReviewsView(reviews: influencerReviews, isLoading: isLoadingReviews)
                            .tag(1)
                        
                        // Analytics Tab
                        InfluencerAnalyticsView(influencer: influencer)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            } else {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.5)
                    
                    Text("Creating your profile...")
                        .font(.headline)
                        .foregroundColor(.purple)
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

// MARK: - Header
struct InfluencerPortalHeader: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text(influencer.userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if influencer.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Label(influencer.displayFollowers, systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        Label(influencer.engagementRateDisplay, systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                        
                        Label(influencer.mainPlatform, systemImage: "app.badge")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Profile image
                AsyncImage(url: URL(string: influencer.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 16)
            
            // Quick Stats
            HStack(spacing: 0) {
                QuickStatItem(
                    value: "\(influencer.completedOffers)",
                    label: "Completed",
                    color: .green
                )
                
                Divider()
                    .frame(height: 30)
                
                QuickStatItem(
                    value: "\(influencer.totalReviews)",
                    label: "Reviews",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 30)
                
                QuickStatItem(
                    value: "\(influencer.joinedOffers)",
                    label: "Joined",
                    color: .purple
                )
            }
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
        }
        .background(Color.white.opacity(0.95))
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
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

// MARK: - Tab Bar
struct InfluencerTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                title: "Active Offers",
                icon: "gift.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabBarButton(
                title: "Past Reviews",
                icon: "star.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabBarButton(
                title: "Analytics",
                icon: "chart.line.uptrend.xyaxis",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .purple : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .purple : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(Color.purple.opacity(isSelected ? 0.1 : 0))
            )
            .overlay(
                Rectangle()
                    .fill(Color.purple)
                    .frame(height: 2)
                    .opacity(isSelected ? 1 : 0),
                alignment: .bottom
            )
        }
    }
}

// Keep the existing ActiveOfferCard implementation since it's still referenced
// The new implementation is in InfluencerActiveOffersView.swift

struct ActiveOfferCard: View {
    let offer: FirebaseOffer
    @State private var navigateToDetail = false
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        // CHANGED: Navigate to InfluencerRestaurantDetailView instead of OfferDetailView
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
