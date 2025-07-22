// Path: vibeIn/BizzPortal/OfferPreviewView.swift

import SwiftUI
import FirebaseFirestore

struct OfferPreviewView: View {
    let business: FirebaseBusiness
    let offerData: OfferData
    @State private var agreedToTerms = false
    @State private var isCreatingOffer = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var navigateToPortal = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            OfferPreviewBackground()
            OfferPreviewContent(
                business: business,
                offerData: offerData,
                agreedToTerms: $agreedToTerms,
                isCreatingOffer: isCreatingOffer,
                createOfferAction: createOffer
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Offer Preview")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationDestination(isPresented: $navigateToPortal) {
            BizzPortalView()
        }
        .alert("Offer Created! 🎉", isPresented: $showSuccessAlert) {
            Button("Back to Portal") {
                navigateToPortal = true
            }
        } message: {
            Text("Your offer is now live and visible to influencers!")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createOffer() {
        guard agreedToTerms else { return }
        
        isCreatingOffer = true
        
        // Create offer object for Firebase
        let newOffer = FirebaseOffer(
            businessId: business.id ?? "",
            businessName: business.name,
            businessAddress: business.address,
            title: "Special Offer",
            description: offerData.description,
            platforms: Array(offerData.platforms.map { $0.rawValue }),
            validUntil: Timestamp(date: offerData.combinedDateTime),
            isActive: true,
            participantCount: 0,
            maxParticipants: 100
        )
        
        FirebaseOfferService.shared.createOffer(newOffer) { result in
            isCreatingOffer = false
            
            switch result {
            case .success:
                showSuccessAlert = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Offer Preview Components
struct OfferPreviewBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.4),
                Color.pink.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct OfferPreviewContent: View {
    let business: FirebaseBusiness
    let offerData: OfferData
    @Binding var agreedToTerms: Bool
    let isCreatingOffer: Bool
    let createOfferAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                OfferPreviewHeader()
                OfferPreviewCard(
                    business: business,
                    offerData: offerData
                )
                TermsAndConditionsSection(agreedToTerms: $agreedToTerms)
                GoLiveButton(
                    isEnabled: agreedToTerms && !isCreatingOffer,
                    isLoading: isCreatingOffer,
                    action: createOfferAction
                )
            }
        }
    }
}

struct OfferPreviewHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .shadow(radius: 8)
            
            Text("Offer Preview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Review your offer before going live")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

struct OfferPreviewCard: View {
    let business: FirebaseBusiness
    let offerData: OfferData
    
    var body: some View {
        VStack(spacing: 20) {
            OfferBusinessInfo(business: business)
            OfferDetailsPreview(offerData: offerData)
            OfferPlatformsPreview(platforms: offerData.platforms)
            OfferValidityPreview(validUntil: offerData.combinedDateTime)
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

struct OfferBusinessInfo: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(business.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            
            Text(business.address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct OfferDetailsPreview: View {
    let offerData: OfferData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
                Text("Offer Details")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            Text(offerData.description)
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct OfferPlatformsPreview: View {
    let platforms: Set<OfferPlatform>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "app.connected.to.app.below.fill")
                    .foregroundColor(.blue)
                Text("Available On")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(Array(platforms)) { platform in
                    PlatformBadge(platform: platform)
                }
                Spacer()
            }
        }
    }
}

struct PlatformBadge: View {
    let platform: OfferPlatform
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: platform.icon)
                .foregroundColor(platform.color)
                .font(.caption)
            Text(platform.rawValue)
                .font(.caption)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(platform.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct OfferValidityPreview: View {
    let validUntil: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.purple)
                Text("Valid Until")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(validUntil))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("at \(formatTime(validUntil))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(timeRemaining(until: validUntil))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeRemaining(until date: Date) -> String {
        let timeInterval = date.timeIntervalSince(Date())
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") left"
        } else {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") left"
        }
    }
}

struct TermsAndConditionsSection: View {
    @Binding var agreedToTerms: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Terms & Conditions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By creating this offer, you agree to:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        TermItem(text: "Honor all offer redemptions during the valid period")
                        TermItem(text: "Provide the described service or discount to participants")
                        TermItem(text: "Maintain professional communication with influencers")
                        TermItem(text: "Comply with platform guidelines and local laws")
                        TermItem(text: "Pay applicable fees as outlined in our pricing")
                        
                        Text("Additional Notes:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.top, 8)
                        
                        TermItem(text: "Offers cannot be modified once live")
                        TermItem(text: "You can deactivate offers early if needed")
                        TermItem(text: "Participant limit helps manage your capacity")
                    }
                }
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            
            Button(action: {
                agreedToTerms.toggle()
            }) {
                HStack {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .foregroundColor(agreedToTerms ? .green : .gray)
                        .font(.title2)
                    
                    Text("I agree to the Terms & Conditions")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct TermItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.blue)
                .fontWeight(.bold)
            Text(text)
                .font(.footnote)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct GoLiveButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Creating Offer...")
                        .font(.headline)
                } else {
                    Text("🚀 GO LIVE!")
                        .font(.headline)
                        .fontWeight(.bold)
                    Image(systemName: "rocket.fill")
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isEnabled ?
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [.gray, .gray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
