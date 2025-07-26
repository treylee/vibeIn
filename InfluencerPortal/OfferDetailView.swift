// Path: vibeIn/InfluencerPortal/OfferDetailView.swift

import SwiftUI

struct OfferDetailView: View {
    let offer: FirebaseOffer
    @State private var showJoinConfirmation = false
    @State private var agreedToTerms = false
    @State private var isJoining = false
    @State private var hasJoinedOffer = false
    @State private var showAlreadyJoinedAlert = false
    @State private var showSuccessAlert = false
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationState: InfluencerNavigationState
    @Binding var shouldNavigateToPortal: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text(offer.businessName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(offer.businessAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Offer Card
                VStack(spacing: 20) {
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Offer Details", systemImage: "gift.fill")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text(offer.description)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.05))
                            .cornerRadius(12)
                    }
                    
                    // Requirements Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Requirements", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("To claim this offer, you must:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(offer.platforms, id: \.self) { platform in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.square.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text("Leave a review on \(platform)")
                                        .font(.subheadline)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Visit the business to redeem")
                                    .font(.subheadline)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Complete by \(offer.formattedValidUntil)")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Validity
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Valid Until", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text(offer.formattedValidUntil)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    // Participation
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Participation", systemImage: "person.3.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        HStack {
                            Text("\(offer.participantCount) / \(offer.maxParticipants) spots filled")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(offer.availableSpots) remaining")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * offer.participationProgress,
                                        height: 8
                                    )
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                
                // Join Button or Status
                if hasJoinedOffer {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("You've joined this offer")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else if offer.availableSpots > 0 && !offer.isExpired && !isJoining {
                    Button(action: { showJoinConfirmation = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Join This Offer")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else if isJoining {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Joining...")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    Text(offer.isExpired ? "This offer has expired" : "No spots available")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkIfAlreadyJoined()
        }
        .sheet(isPresented: $showJoinConfirmation) {
            JoinOfferConsentView(
                offer: offer,
                agreedToTerms: $agreedToTerms,
                onJoin: joinOffer,
                onCancel: { showJoinConfirmation = false }
            )
        }
        .alert("Already Joined", isPresented: $showAlreadyJoinedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You have already joined this offer. Check your active offers to see the details.")
        }
        .alert("Success! 🎉", isPresented: $showSuccessAlert) {
            Button("View My Offers") {
                // Set flag to navigate to portal
                shouldNavigateToPortal = true
                // Dismiss this view
                dismiss()
            }
        } message: {
            Text("You've successfully joined this offer! You can find it in your active offers.")
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
    
    private func joinOffer() {
        guard let influencer = influencerService.currentInfluencer,
              let offerId = offer.id else {
            print("❌ Missing influencer or offer ID")
            return
        }
        
        // Check again if already joined
        if hasJoinedOffer {
            showAlreadyJoinedAlert = true
            showJoinConfirmation = false
            return
        }
        
        isJoining = true
        showJoinConfirmation = false
        
        print("🎯 Joining offer: \(offerId) for all platforms: \(offer.platforms)")
        
        // Join for all platforms at once
        let platform = offer.platforms.joined(separator: ", ")
        
        offerService.joinOffer(
            offerId: offerId,
            businessId: offer.businessId,
            influencerId: influencer.influencerId,
            influencerName: influencer.userName,
            platform: platform
        ) { result in
            DispatchQueue.main.async {
                self.isJoining = false
                
                switch result {
                case .success(let message):
                    print("✅ Successfully joined offer: \(message)")
                    self.hasJoinedOffer = true
                    
                    // Update influencer stats (increment joinedOffers)
                    influencerService.updateInfluencerStats(completedOffer: false, newReview: false)
                    
                    // Post notification to refresh offers
                    NotificationCenter.default.post(name: NSNotification.Name("OfferJoined"), object: nil)
                    
                    // Show success alert
                    self.showSuccessAlert = true
                    
                case .failure(let error):
                    print("❌ Error joining offer: \(error.localizedDescription)")
                    // Check if it's because they already joined
                    if error.localizedDescription.contains("already joined") {
                        self.hasJoinedOffer = true
                        self.showAlreadyJoinedAlert = true
                    }
                }
            }
        }
    }
}

// MARK: - Join Offer Consent View
struct JoinOfferConsentView: View {
    let offer: FirebaseOffer
    @Binding var agreedToTerms: Bool
    let onJoin: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        
                        Text("Offer Agreement")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Please review and agree to the terms")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Business Info
                    VStack(spacing: 8) {
                        Text(offer.businessName)
                            .font(.headline)
                        Text(offer.businessAddress)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Terms Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("By joining this offer, I agree to:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ConsentItem(
                                icon: "star.fill",
                                text: "Leave honest reviews on: \(offer.platforms.joined(separator: ", "))",
                                color: .yellow
                            )
                            
                            ConsentItem(
                                icon: "storefront",
                                text: "Visit \(offer.businessName) to redeem this offer",
                                color: .blue
                            )
                            
                            ConsentItem(
                                icon: "calendar",
                                text: "Complete all requirements by \(offer.formattedValidUntil)",
                                color: .orange
                            )
                            
                            ConsentItem(
                                icon: "camera.fill",
                                text: "Post about my experience on my social media channels",
                                color: .purple
                            )
                            
                            ConsentItem(
                                icon: "hand.raised.fill",
                                text: "Not abuse or resell this offer",
                                color: .red
                            )
                            
                            ConsentItem(
                                icon: "checkmark.shield.fill",
                                text: "Maintain professional conduct during my visit",
                                color: .green
                            )
                        }
                        .padding()
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Agreement Toggle
                    Button(action: { agreedToTerms.toggle() }) {
                        HStack {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreedToTerms ? .purple : .gray)
                                .font(.title2)
                            
                            Text("I agree to all terms and conditions")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(agreedToTerms ? Color.purple : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: onJoin) {
                            Text("Join Offer")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    agreedToTerms ?
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.gray],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(!agreedToTerms)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Consent Item
struct ConsentItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
