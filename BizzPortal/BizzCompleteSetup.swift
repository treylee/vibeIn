// Path: vibeIn/BizzPortal/Components/BizzCompleteSetupButton.swift

import SwiftUI
import FirebaseFirestore

struct BizzCompleteSetupButton: View {
    let businessName: String
    let address: String
    let placeID: String?
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    let liveGoogleReviews: [GPlaceDetails.Review]
    
    @StateObject private var firebaseService = FirebaseBusinessService.shared
    @StateObject private var userService = FirebaseUserService.shared
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var navigateToPortal = false
    
    var body: some View {
        Button(action: {
            createBusiness()
        }) {
            HStack(spacing: 12) {
                if firebaseService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Saving to Firebase...")
                        .font(.headline)
                } else {
                    Text("Complete Setup")
                        .font(.headline)
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(firebaseService.isLoading)
        .alert("Success! 🎉", isPresented: $showSuccessAlert) {
            Button("Continue to Portal") {
                navigateToPortal = true
            }
        } message: {
            Text("Your business has been saved and is now live in the influencer portal!")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Try Again") { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(isPresented: $navigateToPortal) {
            BizzPortalView()
        }
    }
    
    private func createBusiness() {
        guard !businessName.isEmpty else {
            showError("Business name is required")
            return
        }
        
        firebaseService.createBusiness(
            name: businessName,
            address: address,
            placeID: placeID ?? "",
            category: "Restaurant",
            offer: "Free Appetizer for Reviews",
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            googleReviews: liveGoogleReviews
        ) { result in
            switch result {
            case .success(let message):
                alertMessage = message
                showSuccessAlert = true
                print("✅ Business creation successful")
                
            case .failure(let error):
                alertMessage = error.localizedDescription
                showErrorAlert = true
                print("❌ Business creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showErrorAlert = true
    }
}
