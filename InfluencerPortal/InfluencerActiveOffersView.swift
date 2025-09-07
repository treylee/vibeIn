// Path: vibeIn/InfluencerPortal/InfluencerActiveOffersView.swift

import SwiftUI
import FirebaseFirestore

// MARK: - Active Offers View (Updated to show joined offers and vibe messages)
struct InfluencerActiveOffersView: View {
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @State private var joinedOffers: [FirebaseOffer] = []
    @State private var vibeMessages: [VibeMessage] = []
    @State private var isLoadingJoined = true
    @State private var isLoadingMessages = true
    @State private var selectedSegment = 0
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var body: some View {
        VStack(spacing: 0) {
            // Segment Control
            Picker("Offers", selection: $selectedSegment) {
                Text("My Active Offers").tag(0)
                Text("Vibe Messages").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
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
                        // Show vibe messages
                        if isLoadingMessages {
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
            loadOffers()
            loadVibeMessages()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferJoined"))) { _ in
            // Reload offers when a new one is joined
            loadOffers()
        }
    }
    
    private func loadOffers() {
        guard let influencer = influencerService.currentInfluencer else { return }
        
        // Load joined offers
        isLoadingJoined = true
        offerService.getInfluencerActiveOffers(influencerId: influencer.influencerId) { offers in
            self.joinedOffers = offers
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

struct InfluencerJoinedOfferCard: View {
    let offer: FirebaseOffer
    
    // ADD THESE STATE VARIABLES HERE (at the top of the struct)
    @State private var showQRCode = false
    @State private var isRedeemed = false
    @State private var checkingStatus = true
    @StateObject private var offerService = FirebaseOfferService.shared
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    
    var body: some View {
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
                
                // Status Badge - ADD THIS
                if checkingStatus {
                    ProgressView()
                        .frame(height: 20)
                } else if isRedeemed {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Redeemed")
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
            
            // ... rest of your existing card content ...
            
            // ADD THIS QR CODE BUTTON (add this after your existing content)
            Button(action: {
                if !isRedeemed {
                    showQRCode = true
                }
            }) {
                HStack {
                    Image(systemName: isRedeemed ? "checkmark.circle" : "qrcode")
                    Text(isRedeemed ? "Already Redeemed" : "Show QR Code")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(isRedeemed ? .gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isRedeemed ?
                            LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                          startPoint: .leading,
                                          endPoint: .trailing) :
                            LinearGradient(colors: [.purple, .pink],
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                )
            }
            .disabled(isRedeemed)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .onAppear {
            checkRedemptionStatus()
        }
        // ADD THE FULLSCREENCOVER HERE (at the end, after all modifiers)
        .fullScreenCover(isPresented: $showQRCode) {
            if let influencer = influencerService.currentInfluencer {
                OfferQRCodeView(offer: offer, influencer: influencer)
            }
        }
    }
    
    // ADD THIS FUNCTION to check redemption status
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
    struct InfluencerJoinedOfferCard: View {
        let offer: FirebaseOffer
        @State private var showQRCode = false
        @State private var isRedeemed = false
        @State private var checkingStatus = true
        @StateObject private var offerService = FirebaseOfferService.shared
        @StateObject private var influencerService = FirebaseInfluencerService.shared
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // ... existing header code ...
                
                // Add Redemption Status
                if checkingStatus {
                    ProgressView()
                        .frame(height: 20)
                } else if isRedeemed {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Redeemed")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
                }
                
                // ... existing content ...
                
                // Add QR Code Button
                Button(action: {
                    if !isRedeemed {
                        showQRCode = true
                    }
                }) {
                    HStack {
                        Image(systemName: isRedeemed ? "checkmark.circle" : "qrcode")
                        Text(isRedeemed ? "Already Redeemed" : "Show QR Code")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(isRedeemed ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isRedeemed ?
                                LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                              startPoint: .leading,
                                              endPoint: .trailing) :
                                LinearGradient(colors: [.purple, .pink],
                                              startPoint: .leading,
                                              endPoint: .trailing)
                            )
                    )
                }
                .disabled(isRedeemed)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            .onAppear {
                checkRedemptionStatus()
            }
            .fullScreenCover(isPresented: $showQRCode) {
                if let influencer = influencerService.currentInfluencer {
                    OfferQRCodeView(offer: offer, influencer: influencer)
                }
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
}
