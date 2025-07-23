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
            BizzSelectionBackground()
            
            VStack(spacing: 0) {
                BizzSelectionHeader()
                    .padding(.bottom, 10)
                
                VStack(spacing: 20) {
                    BizzSearchBar(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        showingResults: $showingResults,
                        searchAction: searchGooglePlaces
                    )
                    
                    if isSearching {
                        BizzLoadingView()
                    } else if showingResults && !searchResults.isEmpty {
                        BizzPlacesList(
                            places: searchResults,
                            onSelect: selectPlace
                        )
                        .frame(maxHeight: .infinity) // Make list take more space
                    } else if !showingResults {
                        BizzEmptyStateView()
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
    
    private func searchGooglePlaces(query: String) {
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


// MARK: - Supporting Views

struct BizzSelectionBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BizzSelectionHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 50)) // Reduced from 80
                .foregroundColor(.blue)
                .shadow(radius: 8)
            
            Text("Find Your Business")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Search for your business on Google")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

struct BizzSearchBar: View {
    @Binding var searchText: String
    @Binding var searchResults: [GooglePlace]
    @Binding var showingResults: Bool
    let searchAction: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Enter business name...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
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
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BizzPlacesList: View {
    let places: [GooglePlace]
    let onSelect: (GooglePlace) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(places, id: \.placeId) { place in
                    BizzPlaceCard(place: place) {
                        onSelect(place)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct BizzPlaceCard: View {
    let place: GooglePlace
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(place.formattedAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        if place.isVerified {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Verified")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BizzLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Searching for businesses...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BizzEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Search for your business")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Enter your business name above to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
