// Path: vibeIn/InfluencerPortal/InfluencerSearchView.swift

import SwiftUI
import MapKit
import FirebaseFirestore

// MARK: - Search Mode Enum
enum InfluencerSearchMode {
    case businesses
    case events
}

// MARK: - Influencer Search View (Discover Tab)
struct InfluencerSearchView: View {
    @State private var searchText = ""
    @State private var searchMode: InfluencerSearchMode = .businesses
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var events: [VibeEvent] = [] // Placeholder for events
    @State private var isLoading = false
    @State private var selectedOffer: FirebaseOffer?
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var filteredOffers: [FirebaseOffer] {
        if searchText.isEmpty {
            return businessOffers
        }
        return businessOffers.filter { offer in
            offer.businessName.localizedCaseInsensitiveContains(searchText) ||
            offer.businessAddress.localizedCaseInsensitiveContains(searchText) ||
            offer.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredEvents: [VibeEvent] {
        if searchText.isEmpty {
            return events
        }
        return events.filter { event in
            event.name.localizedCaseInsensitiveContains(searchText) ||
            event.location.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            // Vibe gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.pink.opacity(0.2),
                    Color.purple.opacity(0.3),
                    Color.orange.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                        
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Discover Offers")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Find collaboration opportunities")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                
                // Toggle with vibe style
                InfluencerVibeToggle(selectedMode: $searchMode)
                    .padding(.horizontal, 40)
                
                // Search Bar
                HStack {
                    Image(systemName: "sparkle.magnifyingglass")
                        .foregroundColor(.pink.opacity(0.6))
                    TextField(searchMode == .businesses ? "Search offers..." : "Search events...", text: $searchText)
                        .foregroundColor(.black)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: Color.pink.opacity(0.1), radius: 10, y: 5)
                .padding(.horizontal, 40)
                
                // Results
                if isLoading {
                    InfluencerVibeLoadingIndicator()
                        .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if searchMode == .businesses {
                                if filteredOffers.isEmpty {
                                    InfluencerVibeEmptyState(
                                        icon: "gift.fill",
                                        title: searchText.isEmpty ? "No offers yet" : "No results found",
                                        subtitle: searchText.isEmpty ? "New offers will appear here" : "Try a different search"
                                    )
                                } else {
                                    ForEach(filteredOffers) { offer in
                                        NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)) {
                                            InfluencerOfferCardView(offer: offer)
                                        }
                                    }
                                }
                            } else {
                                if filteredEvents.isEmpty {
                                    InfluencerVibeEmptyState(
                                        icon: "calendar.badge.plus",
                                        title: searchText.isEmpty ? "No events yet" : "No results found",
                                        subtitle: searchText.isEmpty ? "Upcoming events will appear here" : "Try a different search"
                                    )
                                } else {
                                    ForEach(filteredEvents) { event in
                                        VibeEventCard(event: event)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Add padding for bottom navigation
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .padding(.bottom, 80) // Ensure content doesn't overlap bottom navigation
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        
        // Load active offers
        let db = Firestore.firestore()
        db.collection("offers")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.businessOffers = documents.compactMap { doc in
                        try? doc.data(as: FirebaseOffer.self)
                    }.filter { !$0.isExpired }
                }
                
                // For now, events are empty - you can implement this later
                self.events = []
                self.isLoading = false
            }
    }
}

// MARK: - Influencer Vibe Toggle
struct InfluencerVibeToggle: View {
    @Binding var selectedMode: InfluencerSearchMode
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([InfluencerSearchMode.businesses, .events], id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: mode == .businesses ? "gift.fill" : "calendar.badge.plus")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Text(mode == .businesses ? "Offers" : "Events")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(selectedMode == mode ? .white : .gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Influencer Offer Card View
struct InfluencerOfferCardView: View {
    let offer: FirebaseOffer
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.8), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(offer.businessName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(offer.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    // Spots left
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text("\(offer.availableSpots) spots")
                            .font(.system(size: 11, design: .rounded))
                    }
                    .foregroundColor(.purple)
                    
                    // Time left
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(timeRemaining(until: offer.validUntil.dateValue()))
                            .font(.system(size: 11, design: .rounded))
                    }
                    .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.2), Color.purple.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.purple.opacity(0.1), radius: 10, y: 5)
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

// MARK: - Vibe Event Card (Placeholder)
struct VibeEventCard: View {
    let event: VibeEvent
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.8), Color.pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(event.location)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text(event.date)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.2), Color.pink.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Influencer Vibe Loading
struct InfluencerVibeLoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Finding vibes...")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.gray)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Influencer Vibe Empty State
struct InfluencerVibeEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
            
            Text(subtitle)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// Note: VibeEvent model is defined in InfluencerView.swift
