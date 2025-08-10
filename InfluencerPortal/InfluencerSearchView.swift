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
    @State private var isSearchFocused = false
    @State private var showResults = false
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @EnvironmentObject var navigationState: InfluencerNavigationState
        
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
            
            VStack(spacing: 12) { // Reduced spacing
                // Compact Header - animate when searching
                VStack(spacing: 8) {
                    if !isSearchFocused {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60) // Much smaller
                                .blur(radius: 15)
                            
                            Image(systemName: "sparkle.magnifyingglass")
                                .font(.system(size: 35, weight: .light)) // Smaller icon
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                    
                    if !isSearchFocused {
                        Text(searchMode == .businesses ? "Discover Offers" : "Discover Events")
                            .font(.system(size: 20, weight: .semibold, design: .rounded)) // Smaller
                            .foregroundStyle(
                                LinearGradient(
                                    colors: searchMode == .businesses ?
                                        [.pink, .purple] :
                                        [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: searchMode)
                    }
                    
                    if !isSearchFocused {
                        Text("Find collaboration opportunities")
                            .font(.system(size: 12, design: .rounded)) // Smaller
                            .foregroundColor(.gray)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.top, isSearchFocused ? 50 : 30) // Move up when searching
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                
                // Circular Toggle - more compact when searching
                CircularInfluencerToggle(selectedMode: $searchMode, isCompact: isSearchFocused)
                    .padding(.horizontal, isSearchFocused ? 50 : 40)
                    .scaleEffect(isSearchFocused ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                
                // Search Bar with animation and magnifying glass
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.pink.opacity(0.6))
                                .rotationEffect(.degrees(isSearchFocused ? 360 : 0))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSearchFocused)
                            
                            TextField(searchMode == .businesses ? "Search offers..." : "Search events...", text: $searchText)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isSearchFocused = true
                                    }
                                }
                                .onChange(of: searchText) { newValue in
                                    // Animate results appearance when typing
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showResults = !newValue.isEmpty
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    withAnimation {
                                        searchText = ""
                                        showResults = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(isSearchFocused ? 1.0 : 0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: isSearchFocused ?
                                                    [Color.pink.opacity(0.5), Color.purple.opacity(0.5)] :
                                                    [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: isSearchFocused ? 2 : 1
                                        )
                                )
                        )
                        .shadow(color: isSearchFocused ? Color.purple.opacity(0.2) : Color.pink.opacity(0.1),
                                radius: isSearchFocused ? 15 : 10,
                                y: 5)
                    }
                    
                    // Animated magnifying glass that appears on the right when typing
                    if !searchText.isEmpty {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(15))
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale),
                                removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale)
                            ))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: searchText)
                    }
                }
                .padding(.horizontal, isSearchFocused ? 20 : 40)
                .offset(y: isSearchFocused ? -20 : 0) // Move up when searching
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                
                // Results - takes up more space
                if isLoading {
                    InfluencerVibeLoadingIndicator()
                        .padding(.top, 20)
                        .transition(.opacity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) { // Tighter spacing
                            if searchMode == .businesses {
                                if filteredOffers.isEmpty {
                                    if searchText.isEmpty && !isSearchFocused {
                                        InfluencerVibeEmptyState(
                                            icon: "gift.fill",
                                            title: "No offers yet",
                                            subtitle: "New offers will appear here"
                                        )
                                        .transition(.opacity)
                                    } else if !searchText.isEmpty {
                                        InfluencerVibeEmptyState(
                                            icon: "magnifyingglass",
                                            title: "No results found",
                                            subtitle: "Try a different search"
                                        )
                                        .scaleEffect(0.9)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                } else {
                                    ForEach(Array(filteredOffers.enumerated()), id: \.element.id) { index, offer in
                                        NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)
                                            .environmentObject(navigationState)
                                        ) {
                                            InfluencerOfferCardView(offer: offer)
                                                .transition(.asymmetric(
                                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)
                                                ))
                                                .animation(
                                                    .spring(response: 0.3, dampingFraction: 0.7)
                                                    .delay(Double(index) * 0.05),
                                                    value: searchText
                                                )
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
                                    .transition(.opacity)
                                } else {
                                    ForEach(Array(filteredEvents.enumerated()), id: \.element.id) { index, event in
                                        VibeEventCard(event: event)
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)
                                            ))
                                            .animation(
                                                .spring(response: 0.3, dampingFraction: 0.7)
                                                .delay(Double(index) * 0.05),
                                                value: searchText
                                            )
                                    }
                                }
                            }
                            
                            // Extra padding at the bottom
                            Color.clear
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 5) // Minimal top padding for more list space
                }
            }
        }
        .onAppear {
            loadData()
        }
        .onTapGesture {
            // Dismiss keyboard and reset focus when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if searchText.isEmpty {
                    isSearchFocused = false
                }
            }
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
                
                withAnimation {
                    self.isLoading = false
                }
            }
    }
}

// MARK: - Circular Toggle (Elegant dark design)
struct CircularInfluencerToggle: View {
    @Binding var selectedMode: InfluencerSearchMode
    let isCompact: Bool
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 2) {
            // Offers button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedMode = .businesses
                }
            }) {
                ZStack {
                    Circle()
                        .fill(selectedMode == .businesses ?
                            Color.black :
                            Color.black.opacity(0.05)
                        )
                        .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
                    
                    if selectedMode == .businesses {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.6), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
                    }
                    
                    VStack(spacing: 1) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        if !isCompact {
                            Text("Offers")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                        }
                    }
                    .foregroundColor(selectedMode == .businesses ? .white : .black.opacity(0.4))
                }
            }
            .scaleEffect(selectedMode == .businesses ? 1.05 : 1.0)
            
            // Events button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedMode = .events
                }
            }) {
                ZStack {
                    Circle()
                        .fill(selectedMode == .events ?
                            Color.black :
                            Color.black.opacity(0.05)
                        )
                        .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
                    
                    if selectedMode == .events {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.6), Color.pink.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: isCompact ? 38 : 44, height: isCompact ? 38 : 44)
                    }
                    
                    VStack(spacing: 1) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        if !isCompact {
                            Text("Events")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                        }
                    }
                    .foregroundColor(selectedMode == .events ? .white : .black.opacity(0.4))
                }
            }
            .scaleEffect(selectedMode == .events ? 1.05 : 1.0)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
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
