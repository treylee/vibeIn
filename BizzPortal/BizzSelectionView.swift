import SwiftUI

struct BizzSelectionView: View {
    @State private var businessName = ""
    @State private var selectedPlace: GooglePlace? = nil
    @State private var searchResults: [GooglePlace] = []
    @State private var isSearching = false
    @State private var navigateToAddress = false
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            BusinessNameBackground()
            BusinessNameContent(
                businessName: $businessName,
                selectedPlace: $selectedPlace,
                searchResults: $searchResults,
                isSearching: $isSearching,
                navigateToAddress: $navigateToAddress,
                showingResults: $showingResults,
                searchAction: searchGooglePlaces
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
        }
        .navigationDestination(isPresented: $navigateToAddress) {
            if let place = selectedPlace {
                BusinessConfirmationView(selectedPlace: place)
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
}

// MARK: - Business Name Input Components
struct BusinessNameBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.4),
                Color.pink.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BusinessNameContent: View {
    @Binding var businessName: String
    @Binding var selectedPlace: GooglePlace?
    @Binding var searchResults: [GooglePlace]
    @Binding var isSearching: Bool
    @Binding var navigateToAddress: Bool
    @Binding var showingResults: Bool
    let searchAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            BusinessNameHeader()
            BusinessSearchSection(
                businessName: $businessName,
                selectedPlace: $selectedPlace,
                searchResults: $searchResults,
                showingResults: $showingResults,
                navigateToAddress: $navigateToAddress,
                searchAction: searchAction
            )
            Spacer()
        }
    }
}

struct BusinessNameHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text("Find your business")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Search for your business on Google")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct BusinessSearchSection: View {
    @Binding var businessName: String
    @Binding var selectedPlace: GooglePlace?
    @Binding var searchResults: [GooglePlace]
    @Binding var showingResults: Bool
    @Binding var navigateToAddress: Bool
    let searchAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                BusinessSearchBar(
                    businessName: $businessName,
                    searchResults: $searchResults,
                    showingResults: $showingResults,
                    searchAction: searchAction
                )
                
                if showingResults && !searchResults.isEmpty {
                    BusinessSearchResults(
                        searchResults: searchResults,
                        selectedPlace: $selectedPlace,
                        businessName: $businessName,
                        showingResults: $showingResults
                    )
                }
                
                if let selected = selectedPlace {
                    SelectedBusinessCard(selectedPlace: selected)
                }
            }
            
            BusinessActionButtons(
                selectedPlace: selectedPlace,
                navigateToAddress: $navigateToAddress
            )
        }
        .padding(.horizontal, 40)
    }
}

struct BusinessSearchBar: View {
    @Binding var businessName: String
    @Binding var searchResults: [GooglePlace]
    @Binding var showingResults: Bool
    let searchAction: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black.opacity(0.7))
            
            TextField("e.g., June's Pizza Oakland", text: $businessName)
                .font(.title3)
                .foregroundColor(.black)
                .onChange(of: businessName) { newValue in
                    if newValue.count > 2 {
                        searchAction(newValue)
                    } else {
                        searchResults = []
                        showingResults = false
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white) // Made completely opaque
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

struct BusinessSearchResults: View {
    let searchResults: [GooglePlace]
    @Binding var selectedPlace: GooglePlace?
    @Binding var businessName: String
    @Binding var showingResults: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(searchResults, id: \.placeId) { place in
                    Button(action: {
                        selectedPlace = place
                        businessName = place.name
                        showingResults = false
                    }) {
                        BusinessSearchResultCard(place: place)
                    }
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct BusinessSearchResultCard: View {
    let place: GooglePlace
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(place.formattedAddress)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(2)
                
                if place.isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Google Verified")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            Spacer()
            Image(systemName: "arrow.right.circle")
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white) // Made completely opaque
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

struct SelectedBusinessCard: View {
    let selectedPlace: GooglePlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Selected Business:")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedPlace.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(selectedPlace.formattedAddress)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                
                if selectedPlace.isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                        Text("Google Verified Business")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white) // Made completely opaque
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                )
        )
    }
}

struct BusinessActionButtons: View {
    let selectedPlace: GooglePlace?
    @Binding var navigateToAddress: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            let buttonBackground = selectedPlace == nil ?
                  Color.gray.opacity(0.5) :
                  Color.pink
            
            Button(action: {
                if selectedPlace != nil {
                    navigateToAddress = true
                }
            }) {
                HStack {
                    Text("Continue with Selected Business")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(buttonBackground)
                )
            }
            .disabled(selectedPlace == nil)
            
            Button(action: {
                // Allow manual entry for new businesses
            }) {
                Text("Can't find your business? Add manually")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
