// Path: vibeIn/InfluencerPortal/InfluencerRestaurantDetailView.swift

import SwiftUI
import MapKit

struct InfluencerRestaurantDetailView: View {
    let offer: FirebaseOffer
    @State private var business: FirebaseBusiness?
    @State private var isLoadingBusiness = true
    @State private var navigateToOffer = false
    @State private var hasJoinedOffer = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedTab = 0
    @State private var googleReviews: [GPlaceDetails.Review] = []
    @State private var loadingReviews = false
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoadingBusiness {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        Text("Loading vibe details...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                } else if let business = business {
                    // Restaurant Header
                    RestaurantHeaderSection(
                        business: business,
                        offer: offer
                    )
                    
                    // Media Section
                    if business.hasMedia {
                        RestaurantMediaSection(business: business)
                    }
                    
                    // Map Section
                    RestaurantMapSection(
                        business: business,
                        mapRegion: $mapRegion
                    )
                    
                    // Offer Preview Card
                    RestaurantOfferPreviewCard(
                        offer: offer,
                        navigateToOffer: $navigateToOffer
                    )
                    
                    // Info Tabs
                    RestaurantInfoTabs(
                        selectedTab: $selectedTab,
                        business: business,
                        googleReviews: googleReviews,
                        loadingReviews: loadingReviews
                    )
                    
                    // Join Now Button
                    JoinNowButton(navigateToOffer: $navigateToOffer, hasJoined: hasJoinedOffer)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Discover")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Your Vibe")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .navigationDestination(isPresented: $navigateToOffer) {
            OfferDetailView(offer: offer)
        }
        .onAppear {
            loadBusinessDetails()
            checkIfAlreadyJoined()
        }
    }
    
    private func loadBusinessDetails() {
        FirebaseBusinessService.shared.getBusinessById(businessId: offer.businessId) { fetchedBusiness in
            self.business = fetchedBusiness
            self.isLoadingBusiness = false
            
            // Setup map region if we have coordinates
            if let business = fetchedBusiness,
               let lat = business.latitude,
               let lon = business.longitude {
                self.mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            
            // Load Google reviews if we have a place ID
            if let placeID = fetchedBusiness?.placeID {
                loadGoogleReviews(placeID: placeID)
            }
        }
    }
    
    private func loadGoogleReviews(placeID: String) {
        loadingReviews = true
        GooglePlacesService.shared.fetchPlaceDetails(for: placeID) { reviews, _, _, _ in
            self.googleReviews = reviews
            self.loadingReviews = false
        }
    }
    
    private func checkIfAlreadyJoined() {
        guard let influencer = influencerService.currentInfluencer,
              let offerId = offer.id else { return }
        
        offerService.hasInfluencerJoinedOffer(
            influencerId: influencer.influencerId,
            offerId: offerId
        ) { hasJoined in
            DispatchQueue.main.async {
                self.hasJoinedOffer = hasJoined
            }
        }
    }
}

// MARK: - Restaurant Header Section
struct RestaurantHeaderSection: View {
    let business: FirebaseBusiness
    let offer: FirebaseOffer
    
    var body: some View {
        VStack(spacing: 16) {
            // Vibe Badge
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Featured Vibe")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            
            // Business Name
            Text(business.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Category & Rating
            HStack(spacing: 20) {
                Label(business.category, systemImage: "fork.knife")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let rating = business.rating, rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(business.displayRating)
                            .fontWeight(.semibold)
                        Text("(\(business.displayReviewCount))")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
            }
            
            // Address
            Text(business.address)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Business Hours
            if let hours = business.hours {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text(hours)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Media Section
struct RestaurantMediaSection: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photos & Videos")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let imageURL = business.imageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .frame(width: 250, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if business.mediaType == "video", let videoURL = business.videoURL {
                        VideoThumbnailView(videoURL: videoURL)
                    }
                    
                    // Placeholder for more media
                    ForEach(0..<2) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 250, height: 180)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("More coming soon")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct VideoThumbnailView: View {
    let videoURL: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.8))
            .frame(width: 250, height: 180)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    Text("Video Available")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            )
    }
}

// MARK: - Map Section
struct RestaurantMapSection: View {
    let business: FirebaseBusiness
    @Binding var mapRegion: MKCoordinateRegion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion, annotationItems: [business]) { item in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: item.latitude ?? 37.7749,
                    longitude: item.longitude ?? -122.4194
                )) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(item.name)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Directions Button
            Button(action: openInMaps) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
    }
    
    private func openInMaps() {
        // Implementation for opening in maps
    }
}

// MARK: - Offer Preview Card
struct RestaurantOfferPreviewCard: View {
    let offer: FirebaseOffer
    @Binding var navigateToOffer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Special Offer", systemImage: "gift.fill")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(offer.description)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(offer.availableSpots)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("spots left")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // Platforms
            HStack(spacing: 8) {
                ForEach(offer.platforms, id: \.self) { platform in
                    HStack(spacing: 4) {
                        Image(systemName: platformIcon(for: platform))
                            .font(.caption2)
                        Text(platform)
                            .font(.caption2)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: { navigateToOffer = true }) {
                    Text("View Details")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * offer.participationProgress,
                            height: 6
                        )
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.pink.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
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

// MARK: - Info Tabs
struct RestaurantInfoTabs: View {
    @Binding var selectedTab: Int
    let business: FirebaseBusiness
    let googleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Tab Selector
            Picker("Info", selection: $selectedTab) {
                Text("Details").tag(0)
                Text("Reviews").tag(1)
                Text("Menu").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Tab Content
            VStack(alignment: .leading, spacing: 16) {
                switch selectedTab {
                case 0:
                    BusinessDetailsTab(business: business)
                case 1:
                    ReviewsTab(
                        googleReviews: googleReviews,
                        loadingReviews: loadingReviews,
                        reviewCount: business.reviewCount ?? 0
                    )
                case 2:
                    MenuTab()
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BusinessDetailsTab: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RestaurantDetailRow(icon: "phone.fill", title: "Phone", value: business.phone ?? "Not available")
            RestaurantDetailRow(icon: "globe", title: "Website", value: business.website ?? "Not available")
            RestaurantDetailRow(icon: "clock.fill", title: "Hours", value: business.hours ?? "Not available")
            RestaurantDetailRow(icon: "map.fill", title: "Address", value: business.address)
            
            if business.isVerified {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Verified Business")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct RestaurantDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
}

struct ReviewsTab: View {
    let googleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    let reviewCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if loadingReviews {
                HStack {
                    Spacer()
                    ProgressView("Loading reviews...")
                    Spacer()
                }
                .padding()
            } else if googleReviews.isEmpty {
                Text("No reviews available yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(googleReviews.prefix(5), id: \.text.text) { review in
                    GoogleReviewCard(review: review)
                }
                
                if googleReviews.count > 5 {
                    Text("+ \(googleReviews.count - 5) more reviews")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top)
                }
            }
        }
    }
}

struct GoogleReviewCard: View {
    let review: GPlaceDetails.Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.authorAttribution?.displayName ?? "Anonymous")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let rating = review.rating {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(index < rating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
            }
            
            Text(review.text.text)
                .font(.caption)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(3)
            
            if let time = review.publishTime {
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MenuTab: View {
    let sampleMenuItems = [
        ("Appetizers", ["Spring Rolls", "Nachos", "Bruschetta", "Calamari"]),
        ("Main Courses", ["Grilled Salmon", "Pasta Carbonara", "Steak Frites", "Vegetarian Bowl"]),
        ("Desserts", ["Tiramisu", "Chocolate Cake", "Ice Cream", "Fruit Tart"])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sampleMenuItems, id: \.0) { category, items in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Text("• \(item)")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                            Spacer()
                            Text("$\(Int.random(in: 8...25))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if category != sampleMenuItems.last?.0 {
                    Divider()
                }
            }
        }
    }
}

// MARK: - Join Now Button (Updated with matching aesthetic)
struct JoinNowButton: View {
    @Binding var navigateToOffer: Bool
    let hasJoined: Bool
    
    var body: some View {
        Button(action: { navigateToOffer = true }) {
            HStack(spacing: 12) {
                Image(systemName: hasJoined ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 20))
                Text(hasJoined ? "View Offer Details" : "Join This Offer")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: hasJoined ?
                        [Color.pink.opacity(0.8), Color.orange.opacity(0.8)] :
                        [Color.orange, Color.pink]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: hasJoined ? Color.pink.opacity(0.3) : Color.orange.opacity(0.3), radius: 10, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasJoined)
    }
}
