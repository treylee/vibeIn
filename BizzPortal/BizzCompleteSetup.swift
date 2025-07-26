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
    @State private var navigateToRegisteredPortal = false
    @State private var createdBusiness: FirebaseBusiness?
    
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
            Button("View Dashboard") {
                navigateToRegisteredPortal = true
            }
        } message: {
            Text("Your business has been created successfully! View your dashboard to manage offers and see analytics.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Try Again") { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(isPresented: $navigateToRegisteredPortal) {
            // Navigate to the full app with bottom navigation
            BizzNavigationContainer()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func createBusiness() {
        guard !businessName.isEmpty else {
            showError("Business name is required")
            return
        }
        
        firebaseService.createBusinessWithId(
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
            case .success(let (message, businessId)):
                print("✅ Business created with ID: \(businessId)")
                
                // Update user's hasCreatedBusiness status with the actual business ID
                if let currentUser = self.userService.currentUser {
                    self.userService.updateUserAfterBusinessCreation(businessId: businessId) { success in
                        if success {
                            print("✅ User updated with business ID: \(businessId)")
                            
                            // Load the business immediately after creation
                            self.firebaseService.getBusinessById(businessId: businessId) { business in
                                if let business = business {
                                    self.createdBusiness = business
                                    print("✅ Business loaded: \(business.name)")
                                }
                            }
                        } else {
                            print("❌ Failed to update user with business creation")
                        }
                    }
                }
                
                self.alertMessage = message
                self.showSuccessAlert = true
                
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showErrorAlert = true
                print("❌ Business creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showErrorAlert = true
    }
}
