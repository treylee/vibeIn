// Path: vibeIn/BizzPortal/BizzSelectionView.swift

import SwiftUI
import MapKit

struct BizzSelectionView: View {
    @State private var searchText = ""
    @State private var selectedPlace: GooglePlace?
    @State private var searchResults: [GooglePlace] = []
    @State private var isSearching = false
    @State private var navigateToPreview = false
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            // Enhanced gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header
                EnhancedBizzHeader()
                    .padding(.bottom, 10)
                
                VStack(spacing: 20) {
                    // Enhanced Search Bar
                    EnhancedBizzSearchBar(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        showingResults: $showingResults,
                        searchAction: searchGooglePlaces
                    )
                    
                    // Search Tips (only show when not searching)
                    if !showingResults && !isSearching {
                        SearchTipsScroll()
                    }
                    
                    // Content Area
                    if isSearching {
                        EnhancedBizzLoadingView()
                    } else if showingResults && !searchResults.isEmpty {
                        EnhancedBizzPlacesList(
                            places: searchResults,
                            onSelect: selectPlace
                        )
                        .frame(maxHeight: .infinity)
                    } else if showingResults && searchResults.isEmpty {
                        BizzNoResultsView(searchText: searchText)
                    } else if !showingResults {
                        EnhancedBizzEmptyStateView()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToPreview) {
            if let place = selectedPlace {
                BizzPreviewView(
                    businessName: place.name,
                    address: place.formattedAddress
                )
            }
        }
    }
    
    private func searchGooglePlaces(_ query: String) {
        isSearching = true
        
        let apiKey = "AIzaSyAAshRagNAxT1UbDIiCsR8m4ri4Z-eji5Q"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQuery)&type=establishment&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data) else {
                    searchResults = []
                    showingResults = true
                    return
                }
                
                searchResults = response.results.map { result in
                    GooglePlace(
                        placeId: result.place_id,
                        name: result.name,
                        formattedAddress: result.formatted_address,
                        isVerified: result.business_status == "OPERATIONAL"
                    )
                }
                showingResults = true
            }
        }.resume()
    }
    
    private func selectPlace(_ place: GooglePlace) {
        selectedPlace = place
        navigateToPreview = true
    }
}

// MARK: - Enhanced Header
struct EnhancedBizzHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Find Your")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Business")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 8)
            }
            .padding(.horizontal, 20)
            
            Text("Search for your business on Google")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

// MARK: - Enhanced Search Bar
struct EnhancedBizzSearchBar: View {
    @Binding var searchText: String
    @Binding var searchResults: [GooglePlace]
    @Binding var showingResults: Bool
    let searchAction: (String) -> Void
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Enter business name...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFieldFocused)
                    .onChange(of: searchText) { newValue in
                        if newValue.count > 2 {
                            searchAction(newValue)
                        } else {
                            searchResults = []
                            showingResults = false
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                        showingResults = false
                        isSearchFieldFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            
            if !searchText.isEmpty {
                Button(action: {
                    isSearchFieldFocused = false
                    searchAction(searchText)
                }) {
                    Text("Search")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Search Tips
struct SearchTipsScroll: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SearchTipPill(icon: "location", text: "Use full address")
                SearchTipPill(icon: "building.2", text: "Include business type")
                SearchTipPill(icon: "map", text: "Add city name")
                SearchTipPill(icon: "magnifyingglass", text: "Be specific")
            }
        }
    }
}

struct SearchTipPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Enhanced Places List
struct EnhancedBizzPlacesList: View {
    let places: [GooglePlace]
    let onSelect: (GooglePlace) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(places, id: \.placeId) { place in
                    EnhancedBizzPlaceCard(place: place) {
                        onSelect(place)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Enhanced Place Card
struct EnhancedBizzPlaceCard: View {
    let place: GooglePlace
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Business Icon
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                
                // Business Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(place.formattedAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if place.isVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Verified Business")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Loading View
struct EnhancedBizzLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.5)
            
            Text("Searching for businesses...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - No Results View
struct BizzNoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.crop.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No results found")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("We couldn't find '\(searchText)'.\nTry searching with a different name or address.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
}

// MARK: - Enhanced Empty State View
struct EnhancedBizzEmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("Search for your business")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Enter your business name above to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Feature Cards
            VStack(spacing: 16) {
                FeatureHighlightCard(
                    icon: "gift.fill",
                    title: "Create Offers",
                    description: "Design compelling offers",
                    color: .purple
                )
                
                FeatureHighlightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Performance",
                    description: "Monitor your success",
                    color: .blue
                )
                
                FeatureHighlightCard(
                    icon: "person.3.fill",
                    title: "Connect",
                    description: "Build relationships",
                    color: .pink
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }
}

struct FeatureHighlightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}
