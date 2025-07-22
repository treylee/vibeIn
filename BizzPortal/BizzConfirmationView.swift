// Path: vibeIn/BizzPortal/BusinessConfirmationView.swift

import SwiftUI

struct BusinessConfirmationView: View {
    let selectedPlace: GooglePlace
    @State private var navigateToPreview = false
    
    var body: some View {
        ZStack {
            BusinessConfirmationBackground()
            BusinessConfirmationContent(
                selectedPlace: selectedPlace,
                navigateToPreview: $navigateToPreview
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPreview) {
            BizzPreviewView(
                businessName: selectedPlace.name,
                address: selectedPlace.formattedAddress,
                placeID: selectedPlace.placeId
            )
        }
    }
}

// MARK: - Business Confirmation Components
struct BusinessConfirmationBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.teal.opacity(0.3),
                Color.blue.opacity(0.4),
                Color.purple.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BusinessConfirmationContent: View {
    let selectedPlace: GooglePlace
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            BusinessConfirmationHeader()
            BusinessConfirmationDetails(
                selectedPlace: selectedPlace,
                navigateToPreview: $navigateToPreview
            )
            Spacer()
        }
    }
}

struct BusinessConfirmationHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text("Confirm Your Business")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Is this information correct?")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct BusinessConfirmationDetails: View {
    let selectedPlace: GooglePlace
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            BusinessInfoCard(selectedPlace: selectedPlace)
            ConfirmationButton(navigateToPreview: $navigateToPreview)
        }
        .padding(.horizontal, 40)
    }
}

struct BusinessInfoCard: View {
    let selectedPlace: GooglePlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedPlace.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(selectedPlace.formattedAddress)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
            
            if selectedPlace.isVerified {
                HStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.green)
                    Text("Google Verified Business")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

struct ConfirmationButton: View {
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        let confirmButtonBackground = LinearGradient(
            gradient: Gradient(colors: [.teal, .blue]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        Button(action: {
            navigateToPreview = true
        }) {
            HStack {
                Text("Looks Good - Continue")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(confirmButtonBackground)
            )
        }
    }
}
