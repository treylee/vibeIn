// Path: vibeIn/BizzPortal/BusinessDashboardView.swift

import SwiftUI
import MapKit

struct BusinessDashboardView: View {
    let business: FirebaseBusiness
    @State private var navigateToCreateOffer = false
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var loadingOffers = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var vibesDropdownOpen = false
    
    var body: some View {
        ZStack {
            BusinessDashboardBackground()
            BusinessDashboardContent(
                business: business,
                businessOffers: businessOffers,
                loadingOffers: loadingOffers,
                mapRegion: mapRegion,
                vibesDropdownOpen: $vibesDropdownOpen,
                navigateToCreateOffer: $navigateToCreateOffer
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(business.name)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationDestination(isPresented: $navigateToCreateOffer) {
            CreateOfferView(business: business)
        }
        .onAppear {
            loadBusinessOffers()
            setupMapRegion()
        }
    }
    
    private func loadBusinessOffers() {
        guard let businessId = business.id else { return }
        
        loadingOffers = true
        FirebaseOfferService.shared.getOffersForBusiness(businessId: businessId) { offers in
            self.businessOffers = offers
            self.loadingOffers = false
        }
    }
    
    private func setupMapRegion() {
        if let lat = business.latitude, let lon = business.longitude {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        } else {
            // Default to San Francisco if no coordinates
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

// MARK: - Business Dashboard Components
struct BusinessDashboardBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.3),
                Color.teal.opacity(0.4),
                Color.blue.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BusinessDashboardContent: View {
    let business: FirebaseBusiness
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    let mapRegion: MKCoordinateRegion
    @Binding var vibesDropdownOpen: Bool
    @Binding var navigateToCreateOffer: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                BusinessDashboardHeader()
                BusinessPreviewCard(
                    business: business,
                    businessOffers: businessOffers,
                    loadingOffers: loadingOffers,
                    mapRegion: mapRegion,
                    vibesDropdownOpen: $vibesDropdownOpen,
                    navigateToCreateOffer: $navigateToCreateOffer
                )
            }
        }
    }
}

struct BusinessDashboardHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "storefront")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .shadow(radius: 8)
            
            Text("Your Business is Live! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Your business is now discoverable by influencers")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

struct BusinessPreviewCard: View {
    let business: FirebaseBusiness
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    let mapRegion: MKCoordinateRegion
    @Binding var vibesDropdownOpen: Bool
    @Binding var navigateToCreateOffer: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            BusinessBasicInfo(business: business)
            BusinessMediaDisplay(business: business, mapRegion: mapRegion)
            BusinessCurrentOffers(
                businessOffers: businessOffers,
                loadingOffers: loadingOffers
            )
            BusinessStatsSection(business: business)
            VibesSection(isOpen: $vibesDropdownOpen)
            BusinessAnalyticsSection(business: business)
            CreateOfferButton(navigateToCreateOffer: $navigateToCreateOffer)
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

struct BusinessBasicInfo: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 8) {
            Text(business.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            
            Text(business.address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Live on Platform")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}

struct BusinessMediaDisplay: View {
    let business: FirebaseBusiness
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        if let imageURL = business.imageURL, !imageURL.isEmpty {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .cornerRadius(12)
            .clipped()
        } else {
            // Always show map with Google Maps integration
            Map(coordinateRegion: .constant(mapRegion))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    VStack {
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
                )
        }
    }
}

struct BusinessCurrentOffers: View {
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    
    private var activeOffers: [FirebaseOffer] {
        businessOffers.filter { $0.isActive && !$0.isExpired }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
                Text("Current Offers")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text("\(activeOffers.count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if loadingOffers {
                ProgressView("Loading offers...")
                    .frame(height: 60)
            } else if activeOffers.isEmpty {
                VStack(spacing: 8) {
                    Text("No active offers")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Create your first offer to attract influencers!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 60)
            } else {
                ForEach(activeOffers.prefix(2)) { offer in
                    OfferSummaryCard(offer: offer)
                }
                
                if activeOffers.count > 2 {
                    Text("+ \(activeOffers.count - 2) more offers")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct OfferSummaryCard: View {
    let offer: FirebaseOffer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text("\(offer.participantCount)/\(offer.maxParticipants) joined")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Valid until")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(offer.formattedValidUntil)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 8)
    }
}

struct BusinessStatsSection: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Business Stats")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "star.fill",
                    value: business.displayRating,
                    label: "Rating",
                    color: .yellow
                )
                
                StatItem(
                    icon: "text.bubble.fill",
                    value: "\(business.reviewCount ?? 0)",
                    label: "Google Reviews",
                    color: .blue
                )
                
                StatItem(
                    icon: "eye.fill",
                    value: "\(generateRealisticViews())",
                    label: "Profile Views",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func generateRealisticViews() -> Int {
        // Generate realistic views based on business age and review count
        let baseViews = max(10, (business.reviewCount ?? 0) * 3)
        return baseViews + Int.random(in: 5...25)
    }
}

struct VibesSection: View {
    @Binding var isOpen: Bool
    
    private let sampleVibes = [
        VibeReview(
            author: "Sarah M.",
            rating: 5,
            text: "Amazing atmosphere! The lighting is perfect for photos and the staff is super accommodating.",
            vibe: "Instagram-Perfect",
            platform: "Instagram",
            date: "2 days ago"
        ),
        VibeReview(
            author: "Mike Chen",
            rating: 4,
            text: "Great for content creation. They even helped me get the perfect angle for my food shots!",
            vibe: "Content Creator Friendly",
            platform: "TikTok",
            date: "1 week ago"
        ),
        VibeReview(
            author: "Emma Davis",
            rating: 5,
            text: "The aesthetic here is unmatched. Every corner is picture-perfect, and the natural lighting is chef's kiss.",
            vibe: "Aesthetic Goals",
            platform: "Instagram",
            date: "3 days ago"
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isOpen.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Vibes")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(sampleVibes.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                    
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }
            
            if isOpen {
                VStack(spacing: 8) {
                    ForEach(sampleVibes, id: \.author) { vibe in
                        VibeCard(vibe: vibe)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}

struct VibeReview {
    let author: String
    let rating: Int
    let text: String
    let vibe: String
    let platform: String
    let date: String
}

struct VibeCard: View {
    let vibe: VibeReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(vibe.author)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < vibe.rating ? "star.fill" : "star")
                            .foregroundColor(index < vibe.rating ? .yellow : .gray.opacity(0.3))
                            .font(.caption)
                    }
                }
            }
            
            Text("\"\(vibe.text)\"")
                .font(.caption)
                .foregroundColor(.black)
                .italic()
            
            HStack {
                Text("Vibe: \(vibe.vibe)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(vibe.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
}

struct BusinessAnalyticsSection: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.indigo)
                Text("Business Analytics")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            AnalyticsChart()
            
            VStack(spacing: 12) {
                AnalyticsRow(
                    icon: "eye.circle.fill",
                    title: "Views Since Joining",
                    value: "\(calculateViewsSinceJoining())",
                    subtitle: "+12% vs last month",
                    color: .green,
                    isPositive: true
                )
                
                AnalyticsRow(
                    icon: "star.circle.fill",
                    title: "Reviews This Month",
                    value: "\(calculateRecentReviews())",
                    subtitle: "Average rating: \(business.displayRating)",
                    color: .yellow,
                    isPositive: true
                )
                
                AnalyticsRow(
                    icon: "quote.bubble.fill",
                    title: "What They're Saying",
                    value: "\"Amazing food & vibe!\"",
                    subtitle: "Most common words: delicious, cozy, perfect",
                    color: .blue,
                    isPositive: true
                )
            }
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func calculateViewsSinceJoining() -> Int {
        // Calculate days since business creation
        let daysSinceJoining = Calendar.current.dateComponents([.day], from: business.createdAt.dateValue(), to: Date()).day ?? 1
        
        // Base calculation: more views for longer presence and better rating
        let baseViews = max(50, daysSinceJoining * 15)
        let ratingMultiplier = (business.rating ?? 4.0) / 5.0
        
        return Int(Double(baseViews) * ratingMultiplier) + Int.random(in: 10...50)
    }
    
    private func calculateRecentReviews() -> Int {
        // Estimate recent reviews (could be pulled from Google Places API with real data)
        let totalReviews = business.reviewCount ?? 0
        return max(1, totalReviews / 5) // Roughly 20% of total reviews are recent
    }
}

struct AnalyticsChart: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile Views (Last 7 Days)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.indigo, .purple]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 20, height: CGFloat.random(in: 20...60))
                            .cornerRadius(2)
                        
                        Text(dayLabel(for: day))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 80)
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
    
    private func dayLabel(for day: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -6 + day, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct AnalyticsRow: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isPositive ? .green : .gray)
            }
            
            Spacer()
            
            if isPositive {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CreateOfferButton: View {
    @Binding var navigateToCreateOffer: Bool
    
    var body: some View {
        Button(action: {
            navigateToCreateOffer = true
        }) {
            HStack(spacing: 12) {
                Text("Create Offer - Up Your Renown!")
                    .font(.headline)
                Image(systemName: "plus.circle.fill")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
    }
}
