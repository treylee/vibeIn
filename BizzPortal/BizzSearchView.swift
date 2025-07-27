// Path: vibeIn/BizzPortal/BizzSearchView.swift

import SwiftUI
import FirebaseFirestore

// MARK: - Search Mode Enum
enum BizzSearchMode {
    case businesses
    case influencers
}

// MARK: - Search View
struct BizzSearchView: View {
    @State private var searchText = ""
    @State private var searchMode: BizzSearchMode = .businesses
    @State private var businesses: [FirebaseBusiness] = []
    @State private var influencers: [FirebaseInfluencer] = []
    @State private var isLoading = false
    @State private var selectedInfluencer: FirebaseInfluencer?
    
    @EnvironmentObject var navigationState: BizzNavigationState
    
    var filteredBusinesses: [FirebaseBusiness] {
        if searchText.isEmpty {
            return businesses
        }
        return businesses.filter { business in
            business.name.localizedCaseInsensitiveContains(searchText) ||
            business.address.localizedCaseInsensitiveContains(searchText) ||
            business.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredInfluencers: [FirebaseInfluencer] {
        if searchText.isEmpty {
            return influencers
        }
        return influencers.filter { influencer in
            influencer.userName.localizedCaseInsensitiveContains(searchText) ||
            influencer.categories.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            influencer.city.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            // Vibe gradient background - matching existing style
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
                // Header matching existing style
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
                    
                    Text("Discover Vibes")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Find businesses and influencers")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                
                // Toggle with vibe style
                VibeToggle(selectedMode: $searchMode)
                    .padding(.horizontal, 40)
                
                // Search Bar matching existing style
                HStack {
                    Image(systemName: "sparkle.magnifyingglass")
                        .foregroundColor(.pink.opacity(0.6))
                    TextField(searchMode == .businesses ? "Search businesses..." : "Search influencers...", text: $searchText)
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
                    VibeLoadingIndicator()
                        .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if searchMode == .businesses {
                                if filteredBusinesses.isEmpty {
                                    VibeEmptyState(
                                        icon: "building.2",
                                        title: searchText.isEmpty ? "No businesses yet" : "No results found",
                                        subtitle: searchText.isEmpty ? "Businesses will appear here" : "Try a different search"
                                    )
                                } else {
                                    ForEach(filteredBusinesses) { business in
                                        VibeBusinessCard(business: business)
                                    }
                                }
                            } else {
                                if filteredInfluencers.isEmpty {
                                    VibeEmptyState(
                                        icon: "person.3.fill",
                                        title: searchText.isEmpty ? "No influencers yet" : "No results found",
                                        subtitle: searchText.isEmpty ? "Influencers will appear here" : "Try a different search"
                                    )
                                } else {
                                    ForEach(filteredInfluencers) { influencer in
                                        VibeInfluencerCard(
                                            influencer: influencer,
                                            onTap: {
                                                selectedInfluencer = influencer
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .padding(.bottom, 80)
        .onAppear {
            loadData()
        }
        .sheet(item: $selectedInfluencer) { influencer in
            VibeInfluencerSheet(influencer: influencer)
        }
    }
    
    private func loadData() {
        isLoading = true
        
        // Load all businesses from Firebase
        let db = Firestore.firestore()
        
        // Load businesses
        db.collection("businesses")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.businesses = documents.compactMap { doc in
                        try? doc.data(as: FirebaseBusiness.self)
                    }
                }
                
                // Load influencers
                db.collection("influencers")
                    .getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
                            self.influencers = documents.compactMap { doc in
                                try? doc.data(as: FirebaseInfluencer.self)
                            }
                        }
                        self.isLoading = false
                    }
            }
    }
}

// MARK: - Vibe Toggle
struct VibeToggle: View {
    @Binding var selectedMode: BizzSearchMode
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([BizzSearchMode.businesses, .influencers], id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: mode == .businesses ? "building.2" : "person.3.fill")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Text(mode == .businesses ? "Businesses" : "Influencers")
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

// MARK: - Vibe Business Card
struct VibeBusinessCard: View {
    let business: FirebaseBusiness
    
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
                
                Image(systemName: iconForCategory(business.category))
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(business.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(business.address)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text(business.category)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.1))
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
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "restaurant": return "fork.knife"
        case "cafe": return "cup.and.saucer"
        case "retail": return "bag.fill"
        case "fitness": return "figure.run"
        case "beauty": return "sparkles"
        default: return "building.2"
        }
    }
}

// MARK: - Vibe Influencer Card
struct VibeInfluencerCard: View {
    let influencer: FirebaseInfluencer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Image
                AsyncImage(url: URL(string: influencer.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(influencer.userName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                        
                        if influencer.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("\(influencer.city), \(influencer.state)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Label(influencer.displayFollowers, systemImage: "person.2.fill")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.purple)
                    }
                }
                
                Spacer()
                
                // Engagement
                VStack(alignment: .trailing, spacing: 2) {
                    Text(influencer.engagementRateDisplay)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Engagement")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.gray)
                }
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vibe Loading
struct VibeLoadingIndicator: View {
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

// MARK: - Vibe Empty State
struct VibeEmptyState: View {
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

// MARK: - Vibe Influencer Sheet
struct VibeInfluencerSheet: View {
    let influencer: FirebaseInfluencer
    @Environment(\.dismiss) private var dismiss
    @State private var showStartVibeModal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.orange.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            AsyncImage(url: URL(string: influencer.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Text(influencer.userName)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                    
                                    if influencer.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text("\(influencer.city), \(influencer.state)")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top)
                        
                        // Stats
                        HStack(spacing: 16) {
                            VibeStatBox(
                                value: influencer.displayFollowers,
                                label: "Reach",
                                color: .purple
                            )
                            
                            VibeStatBox(
                                value: influencer.engagementRateDisplay,
                                label: "Engagement",
                                color: .pink
                            )
                            
                            VibeStatBox(
                                value: "\(influencer.totalReviews)",
                                label: "Reviews",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Vibes With")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(influencer.categories, id: \.self) { category in
                                        Text(category)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.purple)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.purple.opacity(0.1))
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Contact Button - FIXED WITH ACTION
                        Button(action: {
                            print("🎯 Start a Vibe button clicked for influencer: \(influencer.userName)")
                            showStartVibeModal = true
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Start a Vibe")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
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
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .sheet(isPresented: $showStartVibeModal) {
            StartVibeModal(
                influencer: influencer,
                selectedOffer: nil
            )
        }
    }
}

// MARK: - Vibe Stat Box
struct VibeStatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
