// Path: vibeIn/InfluencerPortal/InfluencerActiveOffersView.swift

import SwiftUI

// MARK: - Active Offers View (Updated to show joined offers)
struct InfluencerActiveOffersView: View {
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @State private var joinedOffers: [FirebaseOffer] = []
    @State private var availableOffers: [FirebaseOffer] = []
    @State private var isLoadingJoined = true
    @State private var selectedSegment = 0
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        VStack(spacing: 0) {
            // Segment Control
            Picker("Offers", selection: $selectedSegment) {
                Text("My Active Offers").tag(0)
                Text("Available Offers").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    if selectedSegment == 0 {
                        // Show joined offers
                        if isLoadingJoined {
                            ProgressView("Loading your offers...")
                                .padding(.top, 60)
                        } else if joinedOffers.isEmpty {
                            EmptyJoinedOffersState()
                                .padding(.top, 60)
                        } else {
                            ForEach(joinedOffers) { offer in
                                InfluencerJoinedOfferCard(offer: offer)
                                    .environmentObject(navigationState)
                            }
                        }
                    } else {
                        // Show available offers
                        ForEach(availableOffers) { offer in
                            InfluencerAvailableOfferCard(offer: offer)
                                .environmentObject(navigationState)
                        }
                        
                        if availableOffers.isEmpty {
                            EmptyOffersState()
                                .padding(.top, 60)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadOffers()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferJoined"))) { _ in
            // Reload offers when a new one is joined
            loadOffers()
        }
    }
    
    private func loadOffers() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        // Load joined offers
        isLoadingJoined = true
        offerService.getInfluencerActiveOffers(influencerId: influencer.influencerId) { offers in
            self.joinedOffers = offers
            self.isLoadingJoined = false
            
            // Filter available offers to exclude joined ones
            let joinedOfferIds = Set(offers.compactMap { $0.id })
            self.availableOffers = offerService.offers.filter { offer in
                guard let offerId = offer.id else { return false }
                return !joinedOfferIds.contains(offerId) &&
                       offer.availableSpots > 0 &&
                       !offer.isExpired
            }
        }
    }
}

// MARK: - Joined Offer Card
struct InfluencerJoinedOfferCard: View {
    let offer: FirebaseOffer
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)
            .environmentObject(navigationState)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Status Badge
                HStack {
                    Label("Active", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("Complete by \(offer.formattedValidUntil)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                
                // Business Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.businessName)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(offer.businessAddress)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // Offer Description
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(2)
                
                // Platforms to review on
                HStack(spacing: 8) {
                    Text("Review on:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(offer.platforms, id: \.self) { platform in
                        PlatformChip(platform: platform)
                    }
                    
                    Spacer()
                }
                
                // Action Button
                HStack {
                    Spacer()
                    Text("View Details")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.green.opacity(0.05), Color.green.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Available Offer Card
struct InfluencerAvailableOfferCard: View {
    let offer: FirebaseOffer
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
                        Text("\(offer.availableSpots)")
                            .font(.title3)
                            .fontWeight(.bold)
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

// MARK: - Empty Joined Offers State
struct EmptyJoinedOffersState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No active offers")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Join offers from the Available tab to see them here!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
