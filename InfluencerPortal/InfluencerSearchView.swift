// Path: vibeIn/InfluencerPortal/InfluencerSearchView.swift

import SwiftUI
import MapKit

struct InfluencerSearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var searchResults: [FirebaseOffer] = []
    @State private var isSearching = false
    @StateObject private var offerService = FirebaseOfferService.shared
    
    let categories = ["All", "Food & Dining", "Fashion", "Beauty", "Fitness", "Travel", "Tech", "Entertainment"]
    
    var filteredOffers: [FirebaseOffer] {
        let offers = searchText.isEmpty ? offerService.offers : offerService.offers.filter { offer in
            offer.businessName.localizedCaseInsensitiveContains(searchText) ||
            offer.description.localizedCaseInsensitiveContains(searchText) ||
            offer.businessAddress.localizedCaseInsensitiveContains(searchText)
        }
        
        if selectedCategory == "All" {
            return offers
        } else {
            // Filter by category if categories were implemented in offers
            return offers
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.05),
                        Color.pink.opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    InfluencerSearchHeader()
                    
                    // Search Bar
                    InfluencerSearchBar(searchText: $searchText)
                    
                    // Category Filter
                    CategoryFilterScrollView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                    
                    // Results
                    if filteredOffers.isEmpty {
                        EmptySearchResults()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredOffers) { offer in
                                    NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)) {
                                        InfluencerOfferCard(offer: offer)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Search Header
struct InfluencerSearchHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Discover Offers")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Find the perfect collaboration opportunities")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
}

// MARK: - Search Bar
struct InfluencerSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search businesses or offers...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Category Filter
struct CategoryFilterScrollView: View {
    let categories: [String]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

struct CategoryFilterChip: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Influencer Offer Card (renamed from SearchResultCard to avoid conflict)
struct InfluencerOfferCard: View {
    let offer: FirebaseOffer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.businessName)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text(offer.businessAddress)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Spots Available
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(offer.maxParticipants - offer.participantCount)")
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
            
            // Bottom Row
            HStack {
                // Platforms
                HStack(spacing: 8) {
                    ForEach(offer.platforms.prefix(3), id: \.self) { platform in
                        HStack(spacing: 2) {
                            Image(systemName: platformIcon(for: platform))
                                .font(.caption2)
                            Text(platform)
                                .font(.caption2)
                        }
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
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
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (Double(offer.participantCount) / Double(offer.maxParticipants)),
                            height: 4
                        )
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Apple Maps": return "applelogo"
        case "Social Media": return "camera.fill"
        default: return "app"
        }
    }
}

// MARK: - Empty State
struct EmptySearchResults: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No offers found")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
