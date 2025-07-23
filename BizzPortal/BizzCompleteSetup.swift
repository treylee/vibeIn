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
    @State private var navigateToDashboard = false
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
                navigateToDashboard = true
            }
        } message: {
            Text("Your business has been created successfully! View your dashboard to manage offers and see analytics.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Try Again") { }
        } message: {
            Text(alertMessage)
        }
        .navigationDestination(isPresented: $navigateToDashboard) {
            // Navigate to the container with dashboard tab selected and pass the created business
            BizzNavigationContainerWithDashboard(initialBusiness: createdBusiness)
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

// MARK: - Special Navigation Container that starts with Dashboard
struct BizzNavigationContainerWithDashboard: View {
    let initialBusiness: FirebaseBusiness? // Pass the created business
    @State private var selectedTab: BizzTab = .dashboard // Start with dashboard
    @StateObject private var navigationState = BizzNavigationState()
    @StateObject private var userService = FirebaseUserService.shared
    @StateObject private var businessService = FirebaseBusinessService.shared
    @State private var showBottomBar = true
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main Content
                ZStack {
                    // Search View
                    BizzSearchView()
                        .opacity(selectedTab == .search ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    
                    // Home View
                    BizzPortalView()
                        .navigationBarHidden(true)
                        .opacity(selectedTab == .home ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    
                    // Dashboard View
                    if selectedTab == .dashboard {
                        if let business = navigationState.userBusiness ?? initialBusiness {
                            BusinessDashboardView(business: business)
                                .transition(.opacity)
                                .onAppear {
                                    print("📊 Dashboard Tab: Showing BusinessDashboardView for \(business.name)")
                                }
                        } else {
                            // Loading state while we fetch the business
                            ZStack {
                                BusinessDashboardBackground()
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                    Text("Loading your dashboard...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .environmentObject(navigationState)
                
                // Bottom Navigation Bar - Conditional display
                if showBottomBar {
                    VibeBottomNavigationBar(selectedTab: $selectedTab)
                        .environmentObject(navigationState)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
            .onPreferenceChange(ShowBottomBarPreferenceKey.self) { value in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBottomBar = value
                }
            }
        }
        .onAppear {
            // Set the initial business if provided
            if let business = initialBusiness {
                navigationState.userBusiness = business
                print("📊 Dashboard: Set initial business - \(business.name)")
            } else {
                loadUserBusiness()
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            print("📱 Tab changed from \(oldValue.rawValue) to \(newValue.rawValue)")
            if newValue == .dashboard {
                print("📊 Dashboard selected - Business: \(navigationState.userBusiness?.name ?? "nil")")
            }
        }
    }
    
    private func loadUserBusiness() {
        guard let currentUser = userService.currentUser,
              currentUser.hasCreatedBusiness else {
            navigationState.userBusiness = nil
            print("📊 Dashboard: No business to load")
            return
        }
        
        userService.getUserBusiness { business in
            self.navigationState.userBusiness = business
            print("📊 Dashboard: Business loaded - \(business?.name ?? "nil")")
        }
    }
}
