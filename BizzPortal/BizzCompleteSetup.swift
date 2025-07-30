// Path: vibeIn/BizzPortal/BizzCompleteSetup.swift

import SwiftUI
import FirebaseFirestore

struct BizzCompleteSetupButton: View {
    let businessName: String
    let address: String
    let placeID: String?
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    let liveGoogleReviews: [GPlaceDetails.Review]
    let categoryData: CategoryData? // NEW: Added category data
    
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
                    Text("Creating...")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                } else {
                    Text("Complete Setup")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.blue.opacity(0.3), radius: 15, y: 8)
        }
        .disabled(firebaseService.isLoading)
        .scaleEffect(firebaseService.isLoading ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: firebaseService.isLoading)
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
        
        firebaseService.createBusinessWithCategoryData(
            name: businessName,
            address: address,
            placeID: placeID ?? "",
            category: categoryData?.mainCategory ?? "General",
            offer: "Free Appetizer for Reviews",
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            googleReviews: liveGoogleReviews,
            categoryData: categoryData
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
