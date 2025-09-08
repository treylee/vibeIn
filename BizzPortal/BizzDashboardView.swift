// Path: vibeIn/BizzPortal/BizzDashboardView.swift

import SwiftUI
import MapKit
import AVFoundation  
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
                            Text("Dash")
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                                
                                Text("AI Powered insights updated in real-time")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // Quick Stats Overview
                    QuickStatsRow(business: navigationState.userBusiness ?? business)
                    // Add after QuickStatsRow or in a prominent position
                    ScanQRButton(showQRScanner: $showQRScanner)
                        .padding(.horizontal)
                    
                    // Active Offers Section
                    ActiveOffersSection(
                        businessOffers: businessOffers,
                        loadingOffers: loadingOffers,
                        showCreateOffer: $showCreateOffer
                    )
                    
                    // Analytics Grid
                    AnalyticsGridView(
                        business: navigationState.userBusiness ?? business,
                        selectedTimeframe: $selectedTimeframe
                    )
                    
                    // Business Details Section without refresh callback
                    BusinessDetailsSection(
                        business: navigationState.userBusiness ?? business
                    )
                    .padding(.horizontal)
                    
                    // Menu Section without refresh callback
                    MenuSection(
                        business: navigationState.userBusiness ?? business
                    )
                    .padding(.horizontal)
                    
                    // Category & Tags Section without refresh callback
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
        .onAppear {
            // Only initialize once
            if !hasInitialized {
                loadBusinessOffers()
                setupMapRegion()
                hasInitialized = true
                
                // Log current business state
                let currentBusiness = navigationState.userBusiness ?? business
                print("📊 Dashboard initialized for business: \(currentBusiness.name)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferCreated"))) { _ in
            print("🔄 Reloading offers after creation")
            loadBusinessOffers()
            showCreateOffer = false
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
// MARK: - Scan QR Button Component
struct ScanQRButton: View {
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
            BizzQRScannerView()
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
