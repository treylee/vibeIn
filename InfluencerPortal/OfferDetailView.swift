// Path: vibeIn/InfluencerPortal/OfferDetailView.swift

import SwiftUI

struct OfferDetailView: View {
    let offer: FirebaseOffer
    @State private var showJoinConfirmation = false
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    // Platforms
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Review Platforms", systemImage: "app.badge")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 12) {
                            ForEach(offer.platforms, id: \.self) { platform in
                                HStack(spacing: 6) {
                                    Image(systemName: platformIcon(for: platform))
                                    Text(platform)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(platformColor(for: platform))
                                .cornerRadius(20)
                            }
                        }
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
                
                // Join Button
                if offer.availableSpots > 0 && !offer.isExpired {
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
        .alert("Join Offer", isPresented: $showJoinConfirmation) {
            ForEach(offer.platforms, id: \.self) { platform in
                Button(platform) {
                    joinOffer(platform: platform)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Which platform will you leave a review on?")
        }
    }
    
    private func joinOffer(platform: String) {
        guard let influencer = influencerService.currentInfluencer,
              let offerId = offer.id else { return }
        
        offerService.joinOffer(
            offerId: offerId,
            businessId: offer.businessId,
            influencerId: influencer.influencerId,
            influencerName: influencer.userName,
            platform: platform
        ) { result in
            switch result {
            case .success:
                // Update influencer stats
                influencerService.updateInfluencerStats(completedOffer: false, newReview: false)
                dismiss()
            case .failure(let error):
                print("Error joining offer: \(error)")
            }
        }
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Apple Maps": return "applelogo"
        case "Social Media": return "camera.fill"
        default: return "app"
        }
    }
    
    private func platformColor(for platform: String) -> Color {
        switch platform {
        case "Google": return .blue
        case "Apple Maps": return .black
        case "Social Media": return .purple
        default: return .gray
        }
    }
}
