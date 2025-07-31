// Path: vibeIn/BizzPortal/BizzPreviewView.swift

import SwiftUI
import MapKit

// MARK: - Category Data Model
struct CategoryData {
    let mainCategory: String
    let subtypes: [String]
    let customTags: [String]
}

// MARK: - Sample Review Data (keeping only Apple reviews)
let sampleAppleReviews = [
    BizzReview(id: 5, author: "Jennifer K.", rating: 5, text: "Found this gem through the app! The service was outstanding and the food exceeded expectations. Perfect date night spot.", date: "1 week ago", platform: "Apple Maps"),
    BizzReview(id: 6, author: "Tom Wilson", rating: 4, text: "Great location and good food. The app made it easy to find and the offers were a nice bonus. Parking can be tricky though.", date: "3 weeks ago", platform: "Apple Maps"),
    BizzReview(id: 7, author: "Maria Garcia", rating: 5, text: "Love the integration with Apple Maps! Easy to navigate here and the restaurant lived up to the hype. Fresh ingredients and creative menu.", date: "2 weeks ago", platform: "Apple Maps"),
    BizzReview(id: 8, author: "Alex P.", rating: 4, text: "Discovered through Apple recommendations. Clean, modern space with excellent customer service. The signature burger is worth the visit.", date: "1 month ago", platform: "Apple Maps")
]

struct BizzReview: Identifiable {
    let id: Int
    let author: String
    let rating: Int
    let text: String
    let date: String
    let platform: String
}

struct BizzPreviewView: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData? // NEW: Added category data
    
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var showMapView = true
    @State private var selectedContentTab = 0
    @State private var liveGoogleReviews: [GPlaceDetails.Review] = []
    @State private var loadingReviews = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    init(businessName: String, address: String, placeID: String? = nil, categoryData: CategoryData? = nil) {
        self.businessName = businessName
        self.address = address
        self.placeID = placeID ?? "ChIJ7YbfORN-hYARoy9V0MUxYy4"
        self.categoryData = categoryData
    }
    
    var body: some View {
        ZStack {
            // Updated background to match app style
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
            
            BizzPreviewContent(
                businessName: businessName,
                address: address,
                placeID: placeID,
                categoryData: categoryData,
                showingImagePicker: $showingImagePicker,
                showingVideoPicker: $showingVideoPicker,
                selectedImage: $selectedImage,
                selectedVideoURL: $selectedVideoURL,
                showMapView: $showMapView,
                selectedContentTab: $selectedContentTab,
                liveGoogleReviews: liveGoogleReviews,
                loadingReviews: loadingReviews,
                mapRegion: mapRegion
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Preview")
                    .font(.headline)
            }
        }
        .onAppear {
            loadGoogleReviews()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) {
                selectedVideoURL = nil
                showMapView = false
            }
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker(selectedVideoURL: $selectedVideoURL) {
                selectedImage = nil
                showMapView = false
            }
        }
    }
    
    private func loadGoogleReviews() {
        guard let placeID = placeID else { return }
        
        loadingReviews = true
        GooglePlacesService.shared.fetchPlaceDetails(for: placeID) { reviews, _, _, _ in
            self.liveGoogleReviews = reviews
            self.loadingReviews = false
        }
    }
}

// MARK: - Bizz Preview Components
struct BizzPreviewBackground: View {
    var body: some View {
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
    }
}

struct BizzPreviewContent: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData?
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var showMapView: Bool
    @Binding var selectedContentTab: Int
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                BizzPreviewHeader()
                
                BizzPreviewCard(
                    businessName: businessName,
                    address: address,
                    placeID: placeID,
                    categoryData: categoryData,
                    showingImagePicker: $showingImagePicker,
                    showingVideoPicker: $showingVideoPicker,
                    selectedImage: $selectedImage,
                    selectedVideoURL: $selectedVideoURL,
                    showMapView: $showMapView,
                    selectedContentTab: $selectedContentTab,
                    liveGoogleReviews: liveGoogleReviews,
                    loadingReviews: loadingReviews,
                    mapRegion: mapRegion
                )
            }
        }
    }
}

struct BizzPreviewHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Preview Your")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            Text("Business Page")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.top, 20)
    }
}

struct BizzPreviewCard: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData?
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var showMapView: Bool
    @Binding var selectedContentTab: Int
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    let mapRegion: MKCoordinateRegion
    
    let sampleMenuItems = ["Signature Burger", "Truffle Fries", "Craft Beer", "House Salad", "Chocolate Cake"]
    
    private var hasSelectedMedia: Bool {
        return selectedImage != nil || selectedVideoURL != nil
    }
    
    private func getMediaToggleTitle() -> String {
        if selectedImage != nil {
            return "Photo View"
        } else if selectedVideoURL != nil {
            return "Video View"
        }
        return "Media View"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            BizzBasicInfo(businessName: businessName, address: address)
            
            // Display Category Data if available
            if let categoryData = categoryData {
                BizzCategoryPreview(categoryData: categoryData)
            }
            
            if hasSelectedMedia {
                BizzMediaToggleSection(
                    showMapView: $showMapView,
                    getMediaToggleTitle: getMediaToggleTitle
                )
            }
            
            BizzMediaDisplaySection(
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL,
                showMapView: showMapView,
                hasSelectedMedia: hasSelectedMedia,
                mapRegion: mapRegion
            )
            
            BizzAttachmentOptionsSection(
                showingImagePicker: $showingImagePicker,
                showingVideoPicker: $showingVideoPicker,
                showMapView: $showMapView,
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL
            )
            
            BizzOfferPreviewSection()
            
            BizzContentTabsSection(
                selectedContentTab: $selectedContentTab,
                sampleMenuItems: sampleMenuItems,
                liveGoogleReviews: liveGoogleReviews,
                loadingReviews: loadingReviews
            )
            
            // Complete Setup Button with category data
            BizzCompleteSetupButton(
                businessName: businessName,
                address: address,
                placeID: placeID,
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL,
                liveGoogleReviews: liveGoogleReviews,
                categoryData: categoryData
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// NEW: Category Preview Component
struct BizzCategoryPreview: View {
    let categoryData: CategoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.purple)
                Text("Categories & Tags")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Main Category
                HStack {
                    Text("Main:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(categoryData.mainCategory)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                
                // All tags (subtypes now includes custom tags)
                let allTags = categoryData.subtypes + categoryData.customTags  // Merge for display
                if !allTags.isEmpty {
                    Text("Tags:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
}

// Include all the other components from the original file...
// (BizzBasicInfo, BizzMediaToggleSection, BizzMediaDisplaySection, etc.)

struct BizzBasicInfo: View {
    let businessName: String
    let address: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(businessName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            
            Text(address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

struct BizzMediaToggleSection: View {
    @Binding var showMapView: Bool
    let getMediaToggleTitle: () -> String
    
    var body: some View {
        let toggleBackground = RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
        
        HStack(spacing: 0) {
            Button(action: { showMapView = true }) {
                Text("Map View")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showMapView ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(showMapView ? Color.blue : Color.clear)
                    )
            }
            
            Button(action: { showMapView = false }) {
                Text(getMediaToggleTitle())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(!showMapView ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(!showMapView ? Color.blue : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(toggleBackground)
    }
}

struct BizzMediaDisplaySection: View {
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    let showMapView: Bool
    let hasSelectedMedia: Bool
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        let mapOverlay = VStack {
            Spacer()
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                Text("Your Business Location")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                Spacer()
            }
            .padding()
        }
        
        if !hasSelectedMedia || showMapView {
            Map(coordinateRegion: .constant(mapRegion))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(mapOverlay)
        } else {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            } else if let videoURL = selectedVideoURL {
                VStack(spacing: 12) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Video: \(videoURL.lastPathComponent)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct BizzAttachmentOptionsSection: View {
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var showMapView: Bool
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    
    enum AttachmentType: CaseIterable {
        case image, video, map
        
        var title: String {
            switch self {
            case .image: return "Add Photo"
            case .video: return "Add Video"
            case .map: return "Add Map"
            }
        }
        
        var icon: String {
            switch self {
            case .image: return "photo.fill"
            case .video: return "video.fill"
            case .map: return "map.fill"
            }
        }
    }
    
    private func handleAttachmentSelection(_ type: AttachmentType) {
        switch type {
        case .image:
            showingImagePicker = true
        case .video:
            showingVideoPicker = true
        case .map:
            showMapView = true
        }
    }
    
    private func isAttachmentSelected(_ type: AttachmentType) -> Bool {
        switch type {
        case .image:
            return selectedImage != nil
        case .video:
            return selectedVideoURL != nil
        case .map:
            return true
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add content to your page:")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(AttachmentType.allCases, id: \.self) { attachment in
                    Button(action: {
                        handleAttachmentSelection(attachment)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: attachment.icon)
                                .font(.title2)
                                .foregroundColor(isAttachmentSelected(attachment) ? .white : .black)
                            Text(attachment.title)
                                .font(.caption)
                                .foregroundColor(isAttachmentSelected(attachment) ? .white : .black)
                        }
                        .padding()
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isAttachmentSelected(attachment) ? Color.blue : Color.white.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isAttachmentSelected(attachment) ? Color.blue : Color.gray.opacity(0.3), lineWidth: isAttachmentSelected(attachment) ? 2 : 1)
                                )
                        )
                    }
                }
            }
        }
    }
}

struct BizzOfferPreviewSection: View {
    var body: some View {
        let joinOfferButton = RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                AngularGradient(gradient: Gradient(colors: [.pink, .blue, .purple, .orange]), center: .center),
                lineWidth: 3
            )
        
        VStack(spacing: 12) {
            Text("Sample Offer: Free Appetizer for Reviews")
                .font(.headline)
                .foregroundColor(.black)
            
            Text("0 out of 100 people joined")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Text("Join Offer")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(joinOfferButton)
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct BizzContentTabsSection: View {
    @Binding var selectedContentTab: Int
    let sampleMenuItems: [String]
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Content", selection: $selectedContentTab) {
                Text("Menu").tag(0)
                Text("Details").tag(1)
                Text("Google").tag(2)
                Text("Apple").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedContentTab == 0 {
                // Show menu items directly
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sampleMenuItems, id: \.self) { item in
                        HStack {
                            Text("🍽️")
                            Text(item)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("$12.99")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                    }
                }
            } else if selectedContentTab == 1 {
                BizzDetailsTabContent()
            } else if selectedContentTab == 2 {
                BizzLiveGoogleReviewsContent(
                    liveGoogleReviews: liveGoogleReviews,
                    loadingReviews: loadingReviews
                )
            } else {
                BizzAppleReviewsContent()
            }
        }
    }
}

struct BizzDetailsTabContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Hours: 10AM - 10PM")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(12)
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text("(555) 123-4567")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(12)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("4.8 Rating • 127 Reviews")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(12)
        }
    }
}

struct BizzLiveGoogleReviewsContent: View {
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    
    var body: some View {
        if loadingReviews {
            VStack {
                ProgressView("Loading Google Reviews...")
                    .padding()
            }
        } else if liveGoogleReviews.isEmpty {
            VStack {
                Text("No Google reviews available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(liveGoogleReviews, id: \.text.text) { review in
                    BizzLiveReviewCard(review: review)
                }
            }
        }
    }
}

struct BizzAppleReviewsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sampleAppleReviews, id: \.id) { review in
                BizzReviewCard(review: review, platformColor: .gray)
            }
        }
    }
}

struct BizzLiveReviewCard: View {
    let review: GPlaceDetails.Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorAttribution?.displayName ?? "Anonymous")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Google")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if let rating = review.rating {
                    BizzLiveStarRating(rating: rating)
                }
            }
            
            Text(review.text.text)
                .font(.body)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            if let publishTime = review.publishTime {
                Text(publishTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

struct BizzLiveStarRating: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(index < rating ? .yellow : .gray.opacity(0.5))
                    .font(.caption)
            }
        }
    }
}

struct BizzReviewCard: View {
    let review: BizzReview
    let platformColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        Image(systemName: review.platform == "Google" ? "globe" : "applelogo")
                            .foregroundColor(platformColor)
                            .font(.caption)
                        Text(review.platform)
                            .font(.caption)
                            .foregroundColor(platformColor)
                    }
                }
                
                Spacer()
                
                BizzStarRating(rating: review.rating)
            }
            
            Text(review.text)
                .font(.body)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(review.date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

struct BizzStarRating: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(index < rating ? .yellow : .gray.opacity(0.5))
                    .font(.caption)
            }
        }
    }
}
