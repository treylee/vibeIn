// Path: vibeIn/InfluencerPortal/InfluencerView.swift

import SwiftUI

struct InfluencerView: View {
    @State private var searchText = ""
    @StateObject private var firebaseService = FirebaseBusinessService.shared

    var body: some View {
        ZStack {
            SearchBackground()
            SearchContent(
                searchText: $searchText,
                firebaseService: firebaseService
            )
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Search View Components
struct SearchBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.purple, .blue, .teal, .orange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct SearchContent: View {
    @Binding var searchText: String
    @ObservedObject var firebaseService: FirebaseBusinessService
    
    var body: some View {
        VStack(spacing: 20) {
            SearchHeader()
            SearchBar(searchText: $searchText)
            FirebaseRestaurantList(
                searchText: searchText,
                firebaseService: firebaseService
            )
            TopRestaurantsButton()
        }
    }
}

struct SearchHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("X")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text("cash out vibes in.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 40)
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("What are you looking for?", text: $searchText)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
}

struct FirebaseRestaurantList: View {
    let searchText: String
    @ObservedObject var firebaseService: FirebaseBusinessService
    
    private var filteredBusinesses: [FirebaseBusiness] {
        return firebaseService.getFilteredBusinesses(searchText: searchText)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if firebaseService.isLoading && firebaseService.businesses.isEmpty {
                    LoadingView()
                } else if filteredBusinesses.isEmpty && !searchText.isEmpty {
                    NoSearchResultsView(searchText: searchText)
                } else if filteredBusinesses.isEmpty {
                    EmptyStateView()
                } else {
                    BusinessListContent(businesses: filteredBusinesses)
                }
            }
            .padding()
        }
    }
}

// MARK: - List Content Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            Text("Loading restaurants...")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
    }
}

struct NoSearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No restaurants found")
                .font(.headline)
                .foregroundColor(.white)
            Text("No results for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "storefront")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No restaurants yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Businesses will appear here when they complete setup")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct BusinessListContent: View {
    let businesses: [FirebaseBusiness]
    
    var body: some View {
        ForEach(businesses) { business in
            NavigationLink(destination: SimpleRestaurantDetailView(business: business)) {
                FirebaseRestaurantCard(business: business)
            }
        }
    }
}

// MARK: - Firebase Restaurant Card
struct FirebaseRestaurantCard: View {
    let business: FirebaseBusiness

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(business.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if !business.offer.isEmpty {
                        Text(business.offer)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                MediaIndicator(business: business)
            }
            
            BusinessRating(business: business)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct MediaIndicator: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 4) {
            if business.mediaType == "image" {
                Image(systemName: "photo.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            } else if business.mediaType == "video" {
                Image(systemName: "video.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
            }
            
            if business.hasMedia {
                Text("Media")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct BusinessRating: View {
    let business: FirebaseBusiness
    
    var body: some View {
        if let rating = business.rating, rating > 0,
           let reviewCount = business.reviewCount, reviewCount > 0 {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(business.displayRating)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("(\(business.displayReviewCount))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct TopRestaurantsButton: View {
    var body: some View {
        Button(action: {
            // Could implement sorting by rating or popularity
        }) {
            Text("Show Top Restaurants Nearby")
                .foregroundColor(.white)
        }
        .padding(.bottom)
    }
}

// MARK: - Simple Restaurant Detail View (for now)
struct SimpleRestaurantDetailView: View {
    let business: FirebaseBusiness
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(business.name)
                    .font(.largeTitle)
                    .bold()
                
                Text(business.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !business.offer.isEmpty {
                    Text("Offer: \(business.offer)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Show basic business info
                VStack(alignment: .leading, spacing: 12) {
                    if let hours = business.hours {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Hours: \(hours)")
                        }
                    }
                    
                    if let rating = business.rating {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(business.displayRating) • \(business.displayReviewCount)")
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(business.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
