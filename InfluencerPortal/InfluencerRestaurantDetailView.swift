import SwiftUI
import MapKit
import CoreLocation

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var selectedTab = 0
    @State private var reviews: [GPlaceDetails.Review] = []
    @State private var menuItems: [String] = []
    @State private var loading = true
    @State private var address: String? = nil
    @State private var coordinate: CLLocationCoordinate2D? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RestaurantHeader(
                    restaurant: restaurant,
                    address: address,
                    coordinate: coordinate
                )
                
                OfferSection(restaurant: restaurant)
                
                ContentTabs(
                    selectedTab: $selectedTab,
                    loading: loading,
                    menuItems: menuItems,
                    reviews: reviews
                )
            }
            .onAppear {
                loadRestaurantData()
            }
        }
    }
    
    private func loadRestaurantData() {
        GooglePlacesService.shared.fetchPlaceDetails(for: restaurant.placeID) { fetchedReviews, fetchedMenu, fetchedAddress, fetchedCoordinate in
            self.reviews = fetchedReviews
            self.menuItems = fetchedMenu
            self.address = fetchedAddress
            self.coordinate = fetchedCoordinate
            self.loading = false
        }
    }
}

// MARK: - Restaurant Detail Components
struct RestaurantHeader: View {
    let restaurant: Restaurant
    let address: String?
    let coordinate: CLLocationCoordinate2D?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(restaurant.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            if let address = address {
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let coordinate = coordinate {
                RestaurantMap(coordinate: coordinate)
            }
        }
        .padding(.top, 16)
    }
}

struct RestaurantMap: View {
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        ))
        .frame(height: 200)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct OfferSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Offer: \(restaurant.offer)")
                .font(.headline)
                .foregroundColor(.black)

            Text("0 out of 100 people joined")
                .font(.footnote)
                .foregroundColor(.gray)

            JoinOfferButton()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct JoinOfferButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Join")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            AngularGradient(
                                gradient: Gradient(colors: [.pink, .blue, .purple, .orange]),
                                center: .center
                            ),
                            lineWidth: 3
                        )
                )
        }
        .foregroundColor(.black)
        .padding(.horizontal)
    }
}

struct ContentTabs: View {
    @Binding var selectedTab: Int
    let loading: Bool
    let menuItems: [String]
    let reviews: [GPlaceDetails.Review]
    
    var body: some View {
        VStack(spacing: 16) {
            TabSelector(selectedTab: $selectedTab)
            
            if loading {
                ProgressView("Loading...")
                    .padding()
            } else {
                TabContent(
                    selectedTab: selectedTab,
                    menuItems: menuItems,
                    reviews: reviews
                )
            }
        }
    }
}

struct TabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        Picker("Content", selection: $selectedTab) {
            Text("Menu").tag(0)
            Text("Google").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

struct TabContent: View {
    let selectedTab: Int
    let menuItems: [String]
    let reviews: [GPlaceDetails.Review]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if selectedTab == 0 {
                MenuContent(menuItems: menuItems)
            } else {
                ReviewsContent(reviews: reviews)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MenuContent: View {
    let menuItems: [String]
    
    var body: some View {
        ForEach(menuItems, id: \.self) { item in
            Text("🍽️ \(item)")
                .padding()
                .background(Color.white.opacity(0.4))
                .cornerRadius(12)
        }
    }
}

struct ReviewsContent: View {
    let reviews: [GPlaceDetails.Review]
    
    var body: some View {
        ForEach(reviews, id: \.text.text) { review in
            ReviewCard(review: review)
        }
    }
}

struct ReviewCard: View {
    let review: GPlaceDetails.Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.authorAttribution?.displayName ?? "Anonymous")
                    .font(.headline)
                Spacer()
                Text("⭐️ \(review.rating ?? 0)")
                    .font(.subheadline)
            }
            
            Text(review.text.text)
                .font(.body)
            
            if let time = review.publishTime {
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
        }
        .padding()
        .background(Color.white.opacity(0.4))
        .cornerRadius(12)
    }
}
