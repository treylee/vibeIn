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
            
            VStack(spacing: 12) {
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
                                .frame(width: 60, height: 60)
                                .blur(radius: 15)
                            
                            Image(systemName: searchMode == .businesses ? "sparkle.magnifyingglass" : "calendar.badge.plus")
                                .font(.system(size: 35, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: searchMode == .businesses ? [.pink, .purple] : [.orange, .pink],
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
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                        Text(searchMode == .businesses ? "Find collaboration opportunities" : "Connect with your community")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.gray)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.top, isSearchFocused ? 50 : 30)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                
                // Circular Toggle - more compact when searching
                CircularInfluencerToggle(selectedMode: $searchMode, isCompact: isSearchFocused)
                    .padding(.horizontal, isSearchFocused ? 50 : 40)
                    .scaleEffect(isSearchFocused ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                
                // Only show search bar for businesses tab
                if searchMode == .businesses {
                    // Search Bar with animation and magnifying glass
                    HStack(spacing: 12) {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.pink.opacity(0.6))
                                    .rotationEffect(.degrees(isSearchFocused ? 360 : 0))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSearchFocused)
                                
                                TextField("Search offers...", text: $searchText)
                                    .foregroundColor(.black)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            isSearchFocused = true
                                        }
                                    }
                                    .onChange(of: searchText) { newValue in
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
                    .offset(y: isSearchFocused ? -20 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
                }
                
                // Results Section
                if searchMode == .businesses {
                    // Business Offers Results
                    if isLoading {
                        InfluencerVibeLoadingIndicator()
                            .padding(.top, 20)
                            .transition(.opacity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
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
                                
                                // Extra padding at the bottom
                                Color.clear
                                    .frame(height: 100)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 5)
                    }
                } else {
                    // Events Coming Soon Display (Integrated)
                    EventsComingSoonContent()
                }
            }
        }
        .onAppear {
            if searchMode == .businesses {
                loadData()
            }
        }
        .onChange(of: searchMode) { oldValue, newValue in
            if newValue == .businesses {
                loadData()
            }
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
                Text("Notify Me When Available")
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
                        Text("Notify Me")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .disabled(email.isEmpty)
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
            
            Text("Coming Q2 2025")
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

// No longer needed - removed VibeEvent struct as we're showing coming soon
