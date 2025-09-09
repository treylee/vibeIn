// Path: vibeIn/BizzPortal/BizzDashboardView.swift

import SwiftUI
import MapKit
import AVFoundation
import FirebaseFirestore

struct BusinessDashboardView: View {
    let business: FirebaseBusiness
    @State private var showQRScanner = false
    @State private var showCreateOffer = false
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var loadingOffers = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var vibesDropdownOpen = false
    @State private var selectedTimeframe = "This Week"
    @State private var hasInitialized = false
    @State private var refreshTrigger = UUID()
    @State private var showPremiumUpgrade = false
    @EnvironmentObject var navigationState: BizzNavigationState
    
    var body: some View {
        ZStack {
            // Professional gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Dashboard Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dashboard")
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                                
                                Text("Manage your business presence")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // Simple QR Scanner Button
                    SimpleScanQRButton(
                        businessId: (navigationState.userBusiness ?? business).id ?? "",
                        showQRScanner: $showQRScanner
                    )
                    .padding(.horizontal)
                    
                    // Active Offers Section
                    ActiveOffersSection(
                        businessOffers: businessOffers,
                        loadingOffers: loadingOffers,
                        showCreateOffer: $showCreateOffer
                    )
                    .id(refreshTrigger)
                    
                    // Business Details Section
                    BusinessDetailsSection(
                        business: navigationState.userBusiness ?? business
                    )
                    .padding(.horizontal)
                    
                    // Menu Section
                    MenuSection(
                        business: navigationState.userBusiness ?? business
                    )
                    .padding(.horizontal)
                    
                    // Category & Tags Section
                    CategoryAndTagsSection(
                        business: navigationState.userBusiness ?? business
                    )
                    .padding(.horizontal)
                    
                    // Reviews & Vibes Section
                    HStack(spacing: 16) {
                        ReviewsCard(business: navigationState.userBusiness ?? business)
                        VibesCard(isOpen: $vibesDropdownOpen)
                    }
                    .padding(.horizontal)
                    
                    // Location Card
                    LocationCard(
                        business: navigationState.userBusiness ?? business,
                        mapRegion: mapRegion
                    )
                    .padding(.horizontal)
                    
                    // PREMIUM ANALYTICS SECTION - AT BOTTOM
                    PremiumAnalyticsSection(
                        business: navigationState.userBusiness ?? business,
                        selectedTimeframe: $selectedTimeframe,
                        showPremiumUpgrade: $showPremiumUpgrade
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCreateOffer) {
            NavigationStack {
                CreateOfferView(business: navigationState.userBusiness ?? business)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showCreateOffer = false
                            }
                            .foregroundColor(.purple)
                        }
                    }
            }
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeModal()
        }
        .onAppear {
            if !hasInitialized {
                loadBusinessOffers()
                setupMapRegion()
                hasInitialized = true
                
                let currentBusiness = navigationState.userBusiness ?? business
                print("📊 Dashboard initialized for business: \(currentBusiness.name)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferCreated"))) { _ in
            print("🔄 Reloading offers after creation")
            loadBusinessOffers()
            showCreateOffer = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferRedeemed"))) { _ in
            print("🔄 Reloading after redemption - refreshing entire view")
            loadBusinessOffers()
            refreshTrigger = UUID()
        }
    }
    
    // MARK: - Load Business Offers
    private func loadBusinessOffers() {
        guard let businessId = business.id else {
            print("❌ No business ID available")
            return
        }
        
        loadingOffers = true
        print("🔍 Loading offers for businessId: \(businessId)")
        
        FirebaseOfferService.shared.getOffersForBusiness(businessId: businessId) { offers in
            DispatchQueue.main.async {
                self.businessOffers = offers
                self.loadingOffers = false
                print("✅ Loaded \(offers.count) offers for business \(businessId)")
            }
        }
    }
    
    // MARK: - Setup Map Region
    private func setupMapRegion() {
        if let lat = business.latitude, let lon = business.longitude {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        } else {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

// MARK: - Simple Scan QR Button (NO STATS - Just Scanner)
struct SimpleScanQRButton: View {
    let businessId: String
    @Binding var showQRScanner: Bool
    @State private var showPermissionAlert = false
    
    var body: some View {
        Button(action: {
            checkCameraPermission()
        }) {
            HStack(spacing: 16) {
                // QR Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan QR Code")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text("Redeem influencer offers")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.purple.opacity(0.1), radius: 10, y: 5)
        }
        .fullScreenCover(isPresented: $showQRScanner) {
            BizzQRScannerView(businessId: businessId)
        }
        .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to scan QR codes.")
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showQRScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showQRScanner = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
}

// MARK: - Premium Analytics Section
struct PremiumAnalyticsSection: View {
    let business: FirebaseBusiness
    @Binding var selectedTimeframe: String
    @Binding var showPremiumUpgrade: Bool
    @State private var isPremium = false // Would come from subscription service
    
    var body: some View {
        VStack(spacing: 20) {
            // Section Header with Premium Badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Performance Analytics")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if !isPremium {
                    Button(action: { showPremiumUpgrade = true }) {
                        Text("Upgrade")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(6)
                    }
                }
            }
            
            // Locked Content Preview
            ZStack {
                // Blurred preview content
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                    Spacer()
                                }
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 24)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 12)
                            }
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                    Spacer()
                                }
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 28)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 12)
                            }
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                }
                .blur(radius: 8)
                
                // Lock Overlay
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 8) {
                        Text("Unlock Premium Analytics")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Get detailed insights and real-time metrics")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: { showPremiumUpgrade = true }) {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.95))
                )
            }
            .frame(minHeight: 400)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.yellow.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Premium Upgrade Modal
struct PremiumUpgradeModal: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Upgrade to Premium")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Unlock powerful analytics and insights")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Real-time performance metrics")
                            FeatureRow(icon: "person.3.fill", title: "User Insights", description: "Track active users and engagement")
                            FeatureRow(icon: "eye.fill", title: "View Tracking", description: "Monitor page views and reach")
                            FeatureRow(icon: "arrow.triangle.turn.up.right.diamond.fill", title: "Conversion Metrics", description: "Measure your success rate")
                        }
                        .padding(.horizontal)
                        
                        // CTA Button
                        Button(action: {
                            // Handle subscription
                        }) {
                            Text("Start Free Trial")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarItems(
                trailing: Button("Close") { dismiss() }
                    .foregroundColor(.purple)
            )
        }
    }
}

// MARK: - Feature Row Helper
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40)
            
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
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct BusinessDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessDashboardView(
            business: FirebaseBusiness(
                id: "test123",
                name: "Test Restaurant",
                address: "123 Main St",
                placeID: "test",
                category: "Restaurant",
                offer: "Free appetizer",
                createdAt: Timestamp(),
                isVerified: true,
                imageURL: nil,
                videoURL: nil,
                mediaType: nil,
                phone: "(555) 123-4567",
                hours: "9AM - 10PM",
                website: "www.test.com",
                rating: 4.5,
                reviewCount: 127,
                missionStatement: "Great food for everyone",
                menuItems: nil,
                latitude: 37.7749,
                longitude: -122.4194,
                mainCategory: "Food & Dining",
                subtypes: ["Restaurant", "Fine Dining"],
                customTags: []
            )
        )
        .environmentObject(BizzNavigationState())
    }
}
