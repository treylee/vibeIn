// Path: vibeIn/InfluencerPortal/InfluencerActiveOffersView.swift

import SwiftUI
import FirebaseFirestore

// MARK: - Active Offers View (Updated with Premium Badge)
struct InfluencerActiveOffersView: View {
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @State private var joinedOffers: [FirebaseOffer] = []
    @State private var vibeMessages: [VibeMessage] = []
    @State private var isLoadingJoined = true
    @State private var isLoadingMessages = true
    @State private var selectedSegment = 0
    @State private var hasLoadedData = false
    @State private var isPremium = false  // ADDED: Premium status (default false)
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Segment Control with Premium Badge
            HStack(spacing: 0) {
                // My Active Offers Tab
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSegment = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Text("My Active Offers")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedSegment == 0 ? .purple : .gray)
                        
                        Rectangle()
                            .fill(selectedSegment == 0 ?
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedSegment)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Vibe Messages Tab with Premium Badge
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSegment = 1
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Vibe Messages")
                                .font(.system(size: 14, weight: .semibold))
                            
                            if !isPremium {
                                // Premium Badge
                                HStack(spacing: 2) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.orange, .yellow],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.yellow.opacity(0.15),
                                                    Color.orange.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.yellow.opacity(0.4),
                                                    Color.orange.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                                .shadow(color: .yellow.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                        }
                        .foregroundColor(selectedSegment == 1 ? .purple : .gray)
                        
                        Rectangle()
                            .fill(selectedSegment == 1 ?
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(height: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedSegment)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 20) {
                    if selectedSegment == 0 {
                        // Show joined offers
                        if isLoadingJoined {
                            ProgressView("Loading your offers...")
                                .padding(.top, 60)
                        } else if joinedOffers.isEmpty {
                            EmptyJoinedOffersState()
                                .padding(.top, 60)
                        } else {
                            ForEach(joinedOffers) { offer in
                                InfluencerJoinedOfferCard(offer: offer)
                                    .environmentObject(navigationState)
                            }
                        }
                    } else {
                        // Show vibe messages or premium prompt
                        if !isPremium {
                            // ADDED: Premium Feature Display (from separate component)
                            PremiumVibeMessagesPrompt()
                                .padding(.top, 40)
                        } else if isLoadingMessages {
                            ProgressView("Loading messages...")
                                .padding(.top, 60)
                        } else if vibeMessages.isEmpty {
                            EmptyVibeMessagesState()
                                .padding(.top, 60)
                        } else {
                            ForEach(vibeMessages) { message in
                                VibeMessageCard(message: message)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Only load once
            if !hasLoadedData {
                loadOffers()
                // Only load messages if premium
                if isPremium {
                    loadVibeMessages()
                }
                hasLoadedData = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferJoined"))) { _ in
            // Reload offers when a new one is joined
            loadOffers()
        }
        .onChange(of: selectedSegment) { oldValue, newValue in
            // Load messages when switching to messages tab if premium
            if newValue == 1 && isPremium && vibeMessages.isEmpty {
                loadVibeMessages()
            }
        }
    }
    
    // In InfluencerActiveOffersView, update the loadOffers function:

    private func loadOffers() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        // Load joined offers
        isLoadingJoined = true
        
        // Create mock Hash Kitchen offer
        var mockHashKitchenOffer = FirebaseOffer(
            businessId: "test-business-hash",
            businessName: "Hash Kitchen",
            businessAddress: "123 Main St, Phoenix, AZ 85001",
            title: "Free Appetizer Special",
            description: "Free appetizer with any entree purchase - Try our famous hash browns!",
            platforms: ["Google", "Instagram"],
            validUntil: Timestamp(date: Date().addingTimeInterval(7 * 24 * 60 * 60)), // 7 days from now
            isActive: true,
            participantCount: 5,
            maxParticipants: 20
        )
        mockHashKitchenOffer.id = "mock-hash-kitchen-active"
        
        offerService.getInfluencerActiveOffers(influencerId: influencer.influencerId) { offers in
            // Add mock offer to the beginning of the real offers
            var allOffers = [mockHashKitchenOffer]
            allOffers.append(contentsOf: offers)
            
            self.joinedOffers = allOffers
            self.isLoadingJoined = false
        }
    }
    
    private func loadVibeMessages() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        isLoadingMessages = true
        
        // Query messages where influencerId matches
        let db = Firestore.firestore()
        db.collection("vibe_messages")
            .whereField("influencerId", isEqualTo: influencer.influencerId)
            .order(by: "sentAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error loading vibe messages: \(error.localizedDescription)")
                    self.isLoadingMessages = false
                    return
                }
                
                self.vibeMessages = snapshot?.documents.compactMap { document in
                    try? document.data(as: VibeMessage.self)
                } ?? []
                
                self.isLoadingMessages = false
                print("✅ Loaded \(self.vibeMessages.count) vibe messages")
            }
    }
}

// MARK: - Vibe Message Card
struct VibeMessageCard: View {
    let message: VibeMessage
    @State private var business: FirebaseBusiness?
    @State private var isLoadingBusiness = false
    @State private var navigateToBusinessDetail = false
    
    var body: some View {
        Button(action: {
            navigateToBusinessDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "building.2")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(message.businessName)
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        
                        Text("Sent \(formatDate(message.sentAt.dateValue()))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    StatusBadge(status: message.status)
                }
                
                // Message Preview
                Text(message.message)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.05), Color.pink.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                
                // Email Notice
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Full details sent to your email")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 8)
                
                // Action Row
                HStack {
                    // View Business Button
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption)
                        Text("View Business")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.purple)
                    
                    Spacer()
                    
                    // Tap to view indicator
                    Text("Tap to open")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadBusinessDetails()
        }
        .background(
            NavigationLink(
                destination: business != nil ? AnyView(BusinessDetailView(business: business!)) : AnyView(EmptyView()),
                isActive: $navigateToBusinessDetail,
                label: { EmptyView() }
            )
        )
    }
    
    private func loadBusinessDetails() {
        guard business == nil else { return }
        
        isLoadingBusiness = true
        FirebaseBusinessService.shared.getBusinessById(businessId: message.businessId) { fetchedBusiness in
            self.business = fetchedBusiness
            self.isLoadingBusiness = false
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Business Detail View for Vibe Messages
struct BusinessDetailView: View {
    let business: FirebaseBusiness
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(business.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(business.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(.top)
                
                // Business Info
                VStack(spacing: 20) {
                    // Address
                    InfoRow(icon: "location.fill", title: "Address", value: business.address)
                    
                    // Hours
                    if let hours = business.hours {
                        InfoRow(icon: "clock.fill", title: "Hours", value: hours)
                    }
                    
                    // Rating
                    if let rating = business.rating {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.headline)
                            Text("(\(business.reviewCount ?? 0) reviews)")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Current Offer
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Current Offer", systemImage: "gift.fill")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text(business.offer)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.05))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Contact Section
                VStack(spacing: 16) {
                    Text("Interested in collaborating?")
                        .font(.headline)
                    
                    Text("Check your email for the full message and contact details from \(business.name)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        // Open mail app
                        if let url = URL(string: "mailto:") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Open Email", systemImage: "envelope.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Info Row Helper
struct InfoRow: View {
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
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
        case "pending": return .orange
        case "responded": return .blue
        case "accepted": return .green
        case "declined": return .red
        default: return .gray
        }
    }
    
    var statusIcon: String {
        switch status {
        case "pending": return "clock"
        case "responded": return "bubble.left"
        case "accepted": return "checkmark.circle"
        case "declined": return "xmark.circle"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(status.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor)
        .cornerRadius(6)
    }
}

// MARK: - Empty Vibe Messages State
struct EmptyVibeMessagesState: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "envelope.open")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("No messages yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Business owners will message you here!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Influencer Joined Offer Card (COMPLETE REPLACEMENT)
struct InfluencerJoinedOfferCard: View {
    let offer: FirebaseOffer
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    @State private var showQRCode = false
    @State private var showCompletionView = false  // ADD THIS
    @State private var isRedeemed = false
    @State private var checkingStatus = true
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var body: some View {
        NavigationLink(destination: InfluencerRestaurantDetailView(offer: offer)
            .environmentObject(navigationState)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with Business Name and Status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.businessName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text(offer.businessAddress)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    if checkingStatus {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if isRedeemed {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                            Text("Redeemed")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Active")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                
                // Offer Description
                Text(offer.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Platforms
                HStack(spacing: 8) {
                    Text("Review on:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(offer.platforms, id: \.self) { platform in
                        PlatformChip(platform: platform)
                    }
                    
                    Spacer()
                }
                
                // Valid Until
                Text("Valid until: \(offer.formattedValidUntil)")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Divider()
                
                // Action Buttons (UPDATED SECTION)
                // Action Buttons (FIXED ALIGNMENT)
                HStack(spacing: 12) {
                    // QR Code Button
                    Button(action: {
                        if !isRedeemed {
                            showQRCode = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isRedeemed ? "checkmark.circle" : "qrcode")
                                .font(.system(size: 14))
                            Text(isRedeemed ? "Redeemed" : "Show QR")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(isRedeemed ? .gray : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    isRedeemed ?
                                    LinearGradient(colors: [Color.gray.opacity(0.3)],
                                                  startPoint: .leading,
                                                  endPoint: .trailing) :
                                    LinearGradient(colors: [.purple, .pink],
                                                  startPoint: .leading,
                                                  endPoint: .trailing)
                                )
                        )
                    }
                    .disabled(isRedeemed)
                    
                    // Complete Button
                    Button(action: {
                        showCompletionView = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 14))
                            Text("Complete")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(colors: [.green, .mint],
                                                  startPoint: .leading,
                                                  endPoint: .trailing)
                                )
                        )
                    }
                    .disabled(isRedeemed)
                    
    
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: isRedeemed ?
                        [Color.blue.opacity(0.05), Color.blue.opacity(0.02)] :
                        [Color.green.opacity(0.05), Color.green.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isRedeemed ? Color.blue.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
        .onAppear {
            checkRedemptionStatus()
        }
        .fullScreenCover(isPresented: $showQRCode) {
            if let influencer = influencerService.currentInfluencer {
                OfferQRCodeView(offer: offer, influencer: influencer)
            }
        }
        .sheet(isPresented: $showCompletionView) {
            OfferCompletionView(offer: offer)
        }
    }
    
    private func checkRedemptionStatus() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        offerService.checkRedemptionStatus(
            offerId: offer.id ?? "",
            influencerId: influencer.influencerId
        ) { redeemed in
            self.isRedeemed = redeemed
            self.checkingStatus = false
        }
    }
}
// MARK: - Empty Joined Offers State
struct EmptyJoinedOffersState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No active offers")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Join offers to see them here!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
