// Path: vibeIn/BizzPortal/BizzPortalView.swift

import SwiftUI

struct BizzPortalView: View {
    @StateObject private var userService = FirebaseUserService.shared
    @StateObject private var businessService = FirebaseBusinessService.shared
    @State private var searchText = ""
    @State private var navigateToSearch = false
    @State private var navigateToDashboard = false
    @State private var userBusiness: FirebaseBusiness?
    
    var body: some View {
        NavigationStack {
            ZStack {
                BizzPortalBackground()
                BizzPortalContent(
                    currentUser: userService.currentUser,
                    userBusiness: userBusiness,
                    searchText: $searchText,
                    navigateToSearch: $navigateToSearch,
                    navigateToDashboard: $navigateToDashboard,
                    isLoadingUser: userService.isLoading
                )
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSearch) {
                BizzSelectionView()
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                if let business = userBusiness {
                    BusinessDashboardView(business: business)
                }
            }
            .onAppear {
                loadUserBusiness()
            }
            .onChange(of: userService.currentUser) { oldValue, newValue in
                loadUserBusiness()
            }
        }
    }
    
    private func loadUserBusiness() {
        guard let currentUser = userService.currentUser,
              currentUser.hasCreatedBusiness else { return }
        
        userService.getUserBusiness { business in
            self.userBusiness = business
        }
    }
}

// MARK: - Bizz Portal Components
struct BizzPortalBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.3),
                Color.blue.opacity(0.4),
                Color.teal.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BizzPortalContent: View {
    let currentUser: FirebaseUser?
    let userBusiness: FirebaseBusiness?
    @Binding var searchText: String
    @Binding var navigateToSearch: Bool
    @Binding var navigateToDashboard: Bool
    let isLoadingUser: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                BizzPortalHeader(currentUser: currentUser, isLoading: isLoadingUser)
                BusinessExploreSection(searchText: $searchText)
                BusinessActionSection(
                    currentUser: currentUser,
                    userBusiness: userBusiness,
                    navigateToSearch: $navigateToSearch,
                    navigateToDashboard: $navigateToDashboard
                )
                BusinessListSection()
            }
            .padding()
        }
    }
}

struct BizzPortalHeader: View {
    let currentUser: FirebaseUser?
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            VStack(spacing: 12) {
                Text("Business Portal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Setting up your account...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else if let user = currentUser {
                    VStack(spacing: 4) {
                        Text("Welcome back, \(user.userName)! 👋")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Member since \(user.formattedJoinDate)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}

struct BusinessExploreSection: View {
    @Binding var searchText: String
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var filteredBusinesses: [FirebaseBusiness] {
        businessService.getFilteredBusinesses(searchText: searchText)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Explore Businesses")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search businesses...", text: $searchText)
                    .foregroundColor(.black)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            // Search Results Preview
            if !searchText.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Found \(filteredBusinesses.count) businesses")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                    
                    if filteredBusinesses.isEmpty {
                        Text("No businesses match your search")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(filteredBusinesses.prefix(3)) { business in
                            SearchResultCard(business: business)
                        }
                        
                        if filteredBusinesses.count > 3 {
                            Text("+ \(filteredBusinesses.count - 3) more results")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct SearchResultCard: View {
    let business: FirebaseBusiness
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(business.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(business.category)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                    Text(business.displayRating)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if !business.offer.isEmpty {
                    Text("Has Offer")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

struct BusinessActionSection: View {
    let currentUser: FirebaseUser?
    let userBusiness: FirebaseBusiness?
    @Binding var navigateToSearch: Bool
    @Binding var navigateToDashboard: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if let user = currentUser {
                if user.canCreateBusiness {
                    // User can create their first business
                    CreateBusinessButton(navigateToSearch: $navigateToSearch)
                } else if let business = userBusiness {
                    // User has a business - show dashboard button
                    DashboardButton(
                        business: business,
                        navigateToDashboard: $navigateToDashboard
                    )
                } else {
                    // User has created business but we're loading it
                    LoadingBusinessCard()
                }
            } else {
                // Loading user
                LoadingUserCard()
            }
        }
    }
}

struct CreateBusinessButton: View {
    @Binding var navigateToSearch: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ready to grow your business?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button(action: {
                navigateToSearch = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Join - Create Your Business")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .teal]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct DashboardButton: View {
    let business: FirebaseBusiness
    @Binding var navigateToDashboard: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Business Active")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(business.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(business.address)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    Spacer()
                }
            }
            
            Button(action: {
                navigateToDashboard = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                    Text("Dashboard")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct LoadingBusinessCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                Text("Loading your business...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct LoadingUserCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                Text("Setting up your account...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct BusinessListSection: View {
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("All Businesses (\(businessService.businesses.count))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if businessService.businesses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No businesses yet")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Be the first to create one!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(businessService.businesses.prefix(5)) { business in
                        BusinessDisplayCard(business: business)
                    }
                    
                    if businessService.businesses.count > 5 {
                        Text("+ \(businessService.businesses.count - 5) more businesses")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                }
            }
        }
    }
}

struct BusinessDisplayCard: View {
    let business: FirebaseBusiness
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(business.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(business.displayRating)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(business.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !business.offer.isEmpty {
                    Text(business.offer)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(2)
                }
                
               
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                if business.hasMedia {
                    Image(systemName: business.mediaType == "video" ? "video.fill" : "photo.fill")
                        .foregroundColor(business.mediaType == "video" ? .purple : .blue)
                        .font(.title2)
                } else {
                    Image(systemName: "map.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                
                Text("\(business.reviewCount ?? 0) reviews")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
