// Path: vibeIn/BizzPortal/CreateOfferView.swift

import SwiftUI

struct CreateOfferView: View {
    let business: FirebaseBusiness
    @State private var selectedPlatforms: Set<OfferPlatform> = []
    @State private var offerDescription = ""
    @State private var validUntilDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
    @State private var validUntilTime = Date()
    @State private var navigateToPreview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            CreateOfferBackground()
            CreateOfferContent(
                business: business,
                selectedPlatforms: $selectedPlatforms,
                offerDescription: $offerDescription,
                validUntilDate: $validUntilDate,
                validUntilTime: $validUntilTime,
                navigateToPreview: $navigateToPreview
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Offer")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            OfferPreviewView(
                business: business,
                offerData: OfferData(
                    platforms: selectedPlatforms,
                    description: offerDescription,
                    validUntilDate: validUntilDate,
                    validUntilTime: validUntilTime
                )
            )
        }
    }
}

// MARK: - Offer Data Models
enum OfferPlatform: String, CaseIterable, Identifiable {
    case google = "Google"
    case apple = "Apple Maps"
    case social = "Social Media"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .google: return "globe"
        case .apple: return "applelogo"
        case .social: return "camera.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .google: return .blue
        case .apple: return .gray
        case .social: return .pink
        }
    }
}

struct OfferData {
    let platforms: Set<OfferPlatform>
    let description: String
    let validUntilDate: Date
    let validUntilTime: Date
    
    var combinedDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: validUntilDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: validUntilTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? validUntilDate
    }
}

// MARK: - Create Offer Components
struct CreateOfferBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.3),
                Color.pink.opacity(0.4),
                Color.orange.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct CreateOfferContent: View {
    let business: FirebaseBusiness
    @Binding var selectedPlatforms: Set<OfferPlatform>
    @Binding var offerDescription: String
    @Binding var validUntilDate: Date
    @Binding var validUntilTime: Date
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                CreateOfferHeader()
                CreateOfferForm(
                    business: business,
                    selectedPlatforms: $selectedPlatforms,
                    offerDescription: $offerDescription,
                    validUntilDate: $validUntilDate,
                    validUntilTime: $validUntilTime,
                    navigateToPreview: $navigateToPreview
                )
            }
        }
    }
}

struct CreateOfferHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .shadow(radius: 8)
            
            Text("Create Your Offer")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Attract influencers with compelling offers")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

struct CreateOfferForm: View {
    let business: FirebaseBusiness
    @Binding var selectedPlatforms: Set<OfferPlatform>
    @Binding var offerDescription: String
    @Binding var validUntilDate: Date
    @Binding var validUntilTime: Date
    @Binding var navigateToPreview: Bool
    
    private var isFormValid: Bool {
        !selectedPlatforms.isEmpty && !offerDescription.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 20) {
            PlatformSelectionSection(selectedPlatforms: $selectedPlatforms)
            OfferDescriptionSection(offerDescription: $offerDescription)
            ValiditySection(
                validUntilDate: $validUntilDate,
                validUntilTime: $validUntilTime
            )
            NextButton(
                isEnabled: isFormValid,
                navigateToPreview: $navigateToPreview
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

struct PlatformSelectionSection: View {
    @Binding var selectedPlatforms: Set<OfferPlatform>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Platforms")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                ForEach(OfferPlatform.allCases) { platform in
                    PlatformCheckbox(
                        platform: platform,
                        isSelected: selectedPlatforms.contains(platform)
                    ) {
                        if selectedPlatforms.contains(platform) {
                            selectedPlatforms.remove(platform)
                        } else {
                            selectedPlatforms.insert(platform)
                        }
                    }
                }
            }
        }
    }
}

struct PlatformCheckbox: View {
    let platform: OfferPlatform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: platform.icon)
                    .foregroundColor(platform.color)
                    .font(.title2)
                    .frame(width: 30)
                
                Text(platform.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct OfferDescriptionSection: View {
    @Binding var offerDescription: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Offer Description")
                .font(.headline)
                .foregroundColor(.black)
            
            TextEditor(text: $offerDescription)
                .frame(height: 120)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .overlay(
                    Group {
                        if offerDescription.isEmpty {
                            Text("E.g., 'Free appetizer for Google review' or '20% off for social media post'")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}

struct ValiditySection: View {
    @Binding var validUntilDate: Date
    @Binding var validUntilTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Valid Until")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                DatePicker(
                    "Date",
                    selection: $validUntilDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                
                DatePicker(
                    "Time",
                    selection: $validUntilTime,
                    displayedComponents: .hourAndMinute
                )
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}

struct NextButton: View {
    let isEnabled: Bool
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        Button(action: {
            navigateToPreview = true
        }) {
            HStack(spacing: 12) {
                Text("Next - Preview Offer")
                    .font(.headline)
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isEnabled ?
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
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
    }
}
