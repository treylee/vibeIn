// Path: vibeIn/BizzPortal/BizzPortalViewRegistered.swift

import SwiftUI

struct BizzPortalViewRegistered: View {
    @StateObject private var userService = FirebaseUserService.shared
    @StateObject private var businessService = FirebaseBusinessService.shared
    @State private var userBusiness: FirebaseBusiness?
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var loadingOffers = false
    @State private var hasInitialized = false
    @EnvironmentObject var navigationState: BizzNavigationState
    
    var body: some View {
        ZStack {
            PortalBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header with logo
                    VStack(spacing: 20) {
                        VibeINLogo()
                        
                        if let user = userService.currentUser {
                            UserBadge(userName: user.userName)
                        }
                    }
                    .padding(.top, 60)
                    
                    // Current Offers Section - Use navigationState.userBusiness or local userBusiness
                    if let business = navigationState.userBusiness ?? userBusiness {
                        CurrentOffersSection(
                            businessOffers: businessOffers,
                            loadingOffers: loadingOffers
                        )
                    }
                    
                    // Business Dashboard Section for registered users
                    if let business = navigationState.userBusiness ?? userBusiness {
                        VStack(spacing: 20) {
                            BusinessCard(business: business)
                            
                            // Dashboard button that switches tabs
                            Button(action: {
                                // Switch to dashboard tab
                                navigationState.selectedTab = .dashboard
                            }) {
                                DashboardButton()
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        LoadingBusinessView()
                    }
                    
                    // Bottom padding for navigation bar
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only initialize once
            if !hasInitialized {
                // Only load if navigationState doesn't have business
                if navigationState.userBusiness == nil {
                    loadUserBusiness()
                } else {
                    userBusiness = navigationState.userBusiness
                }
                loadBusinessOffers()
                hasInitialized = true
            }
        }
    }
    
    private func loadUserBusiness() {
        guard let currentUser = userService.currentUser,
              currentUser.hasCreatedBusiness else {
            userBusiness = nil
            return
        }
        
        userService.getUserBusiness { business in
            // Only update if different
            if self.userBusiness?.id != business?.id {
                self.userBusiness = business
                // Update navigation state if needed
                if self.navigationState.userBusiness == nil {
                    self.navigationState.userBusiness = business
                }
                print("🏢 BizzPortalRegistered: Business loaded - \(business?.name ?? "nil")")
            }
        }
    }
    
    private func loadBusinessOffers() {
        guard let currentUser = userService.currentUser,
              let businessId = currentUser.businessId else {
            return
        }
        
        loadingOffers = true
        FirebaseOfferService.shared.getOffersForBusiness(businessId: businessId) { offers in
            DispatchQueue.main.async {
                self.businessOffers = offers
                self.loadingOffers = false
                print("✅ Loaded \(offers.count) offers for portal view")
            }
        }
    }
}

// MARK: - Current Offers Section
struct CurrentOffersSection: View {
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    
    private var activeOffers: [FirebaseOffer] {
        businessOffers.filter { $0.isActive && !$0.isExpired }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Active Offers")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    if activeOffers.isEmpty {
                        Text("No active offers")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("\(activeOffers.count) offer\(activeOffers.count == 1 ? "" : "s") running")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                
                Spacer()
                
                if !activeOffers.isEmpty {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(.horizontal, 20)
            
            // Offers Scroll View
            if loadingOffers {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    Spacer()
                }
                .padding()
            } else if activeOffers.isEmpty {
                EmptyOffersPortalCard()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(activeOffers) { offer in
                            CompactOfferCard(offer: offer)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Compact Offer Card
struct CompactOfferCard: View {
    let offer: FirebaseOffer
    
    var participationPercentage: Double {
        guard offer.maxParticipants > 0 else { return 0 }
        return Double(offer.participantCount) / Double(offer.maxParticipants)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(offer.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Participation count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(offer.participantCount)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("joined")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * participationPercentage, height: 8)
                }
            }
            .frame(height: 8)
            
            // Footer
            HStack {
                // Platforms
                HStack(spacing: 6) {
                    ForEach(offer.platforms.prefix(2), id: \.self) { platform in
                        Image(systemName: platformIcon(for: platform))
                            .font(.caption)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                    if offer.platforms.count > 2 {
                        Text("+\(offer.platforms.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Time remaining
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(timeRemaining(until: offer.validUntil.dateValue()))
                        .font(.caption2)
                }
                .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.purple.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Apple Maps": return "applelogo"
        case "Social Media": return "camera.fill"
        default: return "app"
        }
    }
    
    private func timeRemaining(until date: Date) -> String {
        let timeInterval = date.timeIntervalSince(Date())
        let days = Int(timeInterval / 86400)
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)d left"
        } else if hours > 0 {
            return "\(hours)h left"
        } else {
            return "Ending soon"
        }
    }
}

// MARK: - Empty Offers Portal Card
struct EmptyOffersPortalCard: View {
    @EnvironmentObject var navigationState: BizzNavigationState
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("No Active Offers")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("Create offers to attract influencers")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button(action: {
                    navigationState.selectedTab = .dashboard
                }) {
                    Text("Go to Dashboard →")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.purple)
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "gift")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}
