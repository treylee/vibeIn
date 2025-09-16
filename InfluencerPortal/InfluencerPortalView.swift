// Path: vibeIn/InfluencerPortal/InfluencerPortalView.swift

import SwiftUI

struct InfluencerPortalView: View {
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    @State private var influencerReviews: [InfluencerReview] = []
    @State private var isLoadingReviews = false
    @State private var animateGradient = false
    @State private var completedOffers: [FirebaseOffer] = []
    @State private var isLoadingCompletedOffers = false
    @State private var completedOffersCount = 0
    @State private var showReviewSheet = false
    @State private var selectedOfferForReview: FirebaseOffer?
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
                            
                            // Past Offers Section with enhanced design
                            VStack(spacing: 20) {
                                // Section Header with animated gradient (left aligned like Active Offers)
                                HStack {
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
                                        
                                        Image(systemName: "clock.arrow.circlepath")
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
                                        Text("Past Offers")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                        Text("Your completed offers & vibe reviews")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // Counts badge
                                    HStack(spacing: 8) {
                                        if completedOffersCount > 0 {
                                            Text("\(completedOffersCount)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(
                                                    Capsule()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [.green, .mint],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                )
                                        }
                                        
                                        if influencerReviews.count > 0 {
                                            Text("\(influencerReviews.count)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
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
                                }
                                .padding(.horizontal, 20)
                                
                                // Content with enhanced styling
                                VStack {
                                    PastOffersTabView(
                                        completedOffers: completedOffers,
                                        reviews: influencerReviews,
                                        isLoadingOffers: isLoadingCompletedOffers,
                                        isLoadingReviews: isLoadingReviews,
                                        onWriteReview: { offer in
                                            selectedOfferForReview = offer
                                            showReviewSheet = true
                                        },
                                        onRefreshReviews: {
                                            loadInfluencerReviews()
                                        }
                                    )
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
            loadCompletedOffers()
        }
        .sheet(isPresented: $showReviewSheet) {
            if let offer = selectedOfferForReview,
               let influencer = influencerService.currentInfluencer {
                WriteVibeReviewSheet(
                    offer: offer,
                    influencer: influencer,
                    isPresented: $showReviewSheet,
                    onReviewSubmitted: {
                        loadInfluencerReviews()
                    }
                )
            }
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
    
    private func loadCompletedOffers() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        isLoadingCompletedOffers = true
        
        offerService.getCompletedOffersForInfluencer(influencerId: influencer.influencerId) { offers in
            self.completedOffers = offers
            self.completedOffersCount = offers.count
            self.isLoadingCompletedOffers = false
        }
    }
}

// MARK: - Past Offers Tab View
struct PastOffersTabView: View {
    let completedOffers: [FirebaseOffer]
    let reviews: [InfluencerReview]
    let isLoadingOffers: Bool
    let isLoadingReviews: Bool
    let onWriteReview: (FirebaseOffer) -> Void
    let onRefreshReviews: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            HStack(spacing: 0) {
                // Completed Offers Tab
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                            Text("Completed")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == 0 ? .green : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == 0 ?
                                LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Reviews Tab
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 1
                        onRefreshReviews()
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                            Text("My Vibe Reviews")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == 1 ? .orange : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == 1 ?
                                LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Tab Content
            if selectedTab == 0 {
                // Completed Offers Tab
                ScrollView {
                    if isLoadingOffers {
                        ProgressView("Loading completed offers...")
                            .padding(.top, 40)
                    } else if completedOffers.isEmpty {
                        EmptyCompletedOffersState()
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(completedOffers) { offer in
                                CompletedOfferCard(
                                    offer: offer,
                                    onWriteReview: { onWriteReview(offer) }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .frame(height: 300)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            } else {
                // My Reviews Tab
                ScrollView {
                    if isLoadingReviews {
                        ProgressView("Loading your reviews...")
                            .padding(.top, 40)
                    } else if reviews.isEmpty {
                        EmptyReviewsState()
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(reviews) { review in
                                MyReviewCard(review: review)
                            }
                        }
                        .padding()
                    }
                }
                .frame(height: 300)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Completed Offer Card
struct CompletedOfferCard: View {
    let offer: FirebaseOffer
    let onWriteReview: () -> Void
    @State private var hasReviewed = false
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.businessName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text(offer.businessAddress)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Completed Badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                    Text("Completed")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Offer Description
            Text(offer.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Completion Date
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text("Completed on \(offer.formattedValidUntil)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Action Button with matching color aesthetic
            Button(action: {
                if !hasReviewed {
                    onWriteReview()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: hasReviewed ? "star.fill" : "sparkles")
                        .font(.system(size: 12))
                    Text(hasReviewed ? "Review Submitted" : "Write a Vibe Review")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(hasReviewed ? .gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    hasReviewed ?
                    LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(8)
            }
            .disabled(hasReviewed)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            checkIfReviewed()
        }
    }
    
    private func checkIfReviewed() {
        guard let offerId = offer.id else { return }
        
        influencerService.hasReviewedOffer(offerId: offerId) { hasReviewed in
            DispatchQueue.main.async {
                self.hasReviewed = hasReviewed
            }
        }
    }
}

// MARK: - My Review Card
struct MyReviewCard: View {
    let review: InfluencerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.businessName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("San Francisco, CA")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Rating Stars
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(index < review.rating ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
            
            // Review Text
            Text(review.reviewText)
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Review Metadata
            HStack {
                // Platform
                HStack(spacing: 4) {
                    Image(systemName: platformIcon(for: review.platform))
                        .font(.system(size: 10))
                    Text(review.platform)
                        .font(.system(size: 11))
                }
                .foregroundColor(.purple)
                
                Spacer()
                
                // Date
                Text(review.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            // Engagement Metrics
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.pink)
                    Text("\(review.likes)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    Text("\(review.comments)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    Text("\(review.views)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if review.isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                        Text("Verified")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Instagram": return "camera.fill"
        case "TikTok": return "music.note"
        default: return "app"
        }
    }
}

// MARK: - Empty States
struct EmptyCompletedOffersState: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.1), Color.mint.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("No completed offers yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Complete offers to see them here")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Write Vibe Review Sheet
struct WriteVibeReviewSheet: View {
    let offer: FirebaseOffer
    let influencer: FirebaseInfluencer
    @Binding var isPresented: Bool
    let onReviewSubmitted: () -> Void
    
    @State private var reviewText = ""
    @State private var rating = 5
    @State private var selectedPlatform = "Google"
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    let platforms = ["Google", "Instagram", "TikTok", "Facebook"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.05), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Write Your Vibe Review")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(offer.businessName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        
                        // Rating Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Your Rating", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            rating = star
                                        }
                                    }) {
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.title)
                                            .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
                                            .scaleEffect(star == rating ? 1.2 : 1.0)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Platform Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Platform", systemImage: "app.badge")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(platforms, id: \.self) { platform in
                                        Button(action: {
                                            withAnimation {
                                                selectedPlatform = platform
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: platformIcon(for: platform))
                                                    .font(.system(size: 14))
                                                Text(platform)
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundColor(selectedPlatform == platform ? .white : .purple)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedPlatform == platform ?
                                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                                                LinearGradient(colors: [Color.purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                            )
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Review Text Area
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Your Vibe Review", systemImage: "text.bubble.fill")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                                
                                Text("\(reviewText.count)/500")
                                    .font(.caption)
                                    .foregroundColor(reviewText.count > 500 ? .red : .gray)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    colors: isTextFieldFocused ? [.purple, .pink] : [Color.gray.opacity(0.2)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: isTextFieldFocused ? 2 : 1
                                            )
                                    )
                                
                                TextEditor(text: $reviewText)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .focused($isTextFieldFocused)
                                    .onChange(of: reviewText) { newValue in
                                        if newValue.count > 500 {
                                            reviewText = String(newValue.prefix(500))
                                        }
                                    }
                                
                                if reviewText.isEmpty {
                                    Text("Share your experience with this vibe...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(minHeight: 150)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Submit Button
                        Button(action: submitReview) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSubmitting ? "Posting..." : "Post Vibe Review")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: reviewText.isEmpty ? [Color.gray] : [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: reviewText.isEmpty ? Color.clear : Color.purple.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(reviewText.isEmpty || isSubmitting)
                        
                        Color.clear.frame(height: 20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text("Vibe Review")
                            .font(.headline)
                    }
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
        .alert("Review Posted! 🎉", isPresented: $showSuccessAlert) {
            Button("Great!") {
                isPresented = false
                onReviewSubmitted()
            }
        } message: {
            Text("Your vibe review has been posted successfully!")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Instagram": return "camera.fill"
        case "TikTok": return "music.note"
        case "Facebook": return "f.circle"
        default: return "app"
        }
    }
    
    private func submitReview() {
        guard !reviewText.isEmpty, let offerId = offer.id else { return }
        
        isSubmitting = true
        
        influencerService.submitReview(
            offerId: offerId,
            businessId: offer.businessId,
            businessName: offer.businessName,
            platform: selectedPlatform,
            rating: rating,
            reviewText: reviewText
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    showSuccessAlert = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}


// MARK: - Enhanced Header with Better Aesthetics (keeping existing implementation)
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

// Keep existing helper components...
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

