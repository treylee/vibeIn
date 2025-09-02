// Path: vibeIn/BizzPortal/BusinessDashboardView.swift

import SwiftUI
import MapKit


struct BusinessDashboardView: View {
    let business: FirebaseBusiness
    @State private var showCreateOffer = false
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var loadingOffers = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var vibesDropdownOpen = false
    @State private var selectedTimeframe = "This Week"
    @State private var refreshBusiness = false
    @EnvironmentObject var navigationState: BizzNavigationState
    
    // Add this function to refresh business data
    private func refreshBusinessData(businessId: String) {
        FirebaseBusinessService.shared.getBusinessById(businessId: businessId) { updatedBusiness in
            if let updatedBusiness = updatedBusiness {
                // Update the navigation state with refreshed business
                navigationState.userBusiness = updatedBusiness
                print("✅ Business data refreshed after update")
                print("   - Hours: \(updatedBusiness.hours ?? "not set")")
                print("   - Phone: \(updatedBusiness.phone ?? "not set")")
                print("   - Mission: \(updatedBusiness.missionStatement?.prefix(50) ?? "not set")...")
                print("   - Menu Items: \(updatedBusiness.menuItems?.count ?? 0)")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Professional gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Dashboard Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dash")
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                                
                                Text("AI Powered insights updated in real-time")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // Quick Stats Overview
                    QuickStatsRow(business: navigationState.userBusiness ?? business)
                    
                    // Active Offers Section
                    ActiveOffersSection(
                        businessOffers: businessOffers,
                        loadingOffers: loadingOffers,
                        showCreateOffer: $showCreateOffer
                    )
                    
                    // Analytics Grid
                    AnalyticsGridView(
                        business: navigationState.userBusiness ?? business,
                        selectedTimeframe: $selectedTimeframe
                    )
                    
                    // Business Details Section with refresh callback
                    BusinessDetailsSection(
                        business: navigationState.userBusiness ?? business,
                        onBusinessUpdated: refreshBusinessData
                    )
                    .padding(.horizontal)
                    
                    // Menu Section with refresh callback
                    MenuSection(
                        business: navigationState.userBusiness ?? business,
                        onBusinessUpdated: refreshBusinessData
                    )
                    .padding(.horizontal)
                    
                    // Category & Tags Section
                    CategoryAndTagsSection(
                        business: navigationState.userBusiness ?? business,
                        onTagsUpdated: refreshBusinessData
                    )
                    .padding(.horizontal)
                    
                    // Reviews & Vibes Section
                    HStack(spacing: 16) {
                        ReviewsCard(business: navigationState.userBusiness ?? business)
                        VibesCard(isOpen: $vibesDropdownOpen)
                    }
                    .padding(.horizontal)
                    
                    // Location Card
                    LocationCard(
                        business: navigationState.userBusiness ?? business,
                        mapRegion: mapRegion
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCreateOffer) {
            NavigationStack {
                CreateOfferView(business: navigationState.userBusiness ?? business)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showCreateOffer = false
                            }
                            .foregroundColor(.purple)
                        }
                    }
            }
        }
        .onAppear {
            if businessOffers.isEmpty {
                loadBusinessOffers()
            }
            setupMapRegion()
            
            // Log current business state
            let currentBusiness = navigationState.userBusiness ?? business
            print("📊 Dashboard loading for business: \(currentBusiness.name)")
            print("   - ID: \(currentBusiness.id ?? "no-id")")
            print("   - Hours: \(currentBusiness.hours ?? "not set")")
            print("   - Phone: \(currentBusiness.phone ?? "not set")")
            print("   - Mission: \(currentBusiness.missionStatement?.prefix(50) ?? "not set")...")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferCreated"))) { _ in
            print("🔄 Reloading offers after creation")
            loadBusinessOffers()
            showCreateOffer = false
        }
    }
    
    // MARK: - Load Business Offers
    private func loadBusinessOffers() {
        guard let businessId = business.id else {
            print("❌ No business ID available")
            return
        }
        
        loadingOffers = true
        print("🔍 Loading offers for businessId: \(businessId)")
        
        FirebaseOfferService.shared.getOffersForBusiness(businessId: businessId) { offers in
            DispatchQueue.main.async {
                self.businessOffers = offers
                self.loadingOffers = false
                print("✅ Loaded \(offers.count) offers for business \(businessId)")
                
                // Debug print each offer
                for (index, offer) in offers.enumerated() {
                    print("  Offer \(index + 1):")
                    print("    - ID: \(offer.id ?? "no-id")")
                    print("    - Title: \(offer.title)")
                    print("    - Description: \(offer.description)")
                    print("    - BusinessId: \(offer.businessId)")
                    print("    - Active: \(offer.isActive), Expired: \(offer.isExpired)")
                }
            }
        }
    }
    
    // MARK: - Setup Map Region
    private func setupMapRegion() {
        if let lat = business.latitude, let lon = business.longitude {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        } else {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

// MARK: - Editable Menu Item Row
struct EditableMenuItemRow: View {
    @Binding var item: MenuItem
    let index: Int
    let onDelete: () -> Void
    let onImageTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Item Number Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.8), Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Text("\(index + 1)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Item Image Button
            Button(action: onImageTap) {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                    }
                }
            }
            
            // Editable Fields
            VStack(spacing: 8) {
                TextField("Item name", text: $item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(6)
                
                HStack(spacing: 8) {
                    TextField("$0.00", text: $item.price)
                        .font(.system(size: 12, weight: .medium))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(6)
                        .frame(width: 80)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description (optional)", text: $item.description)
                        .font(.system(size: 12))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.03))
        .cornerRadius(10)
    }
}

// MARK: - Display Menu Item Row
struct DisplayMenuItemRow: View {
    let item: MenuItem
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Item Image or Number
            if let imageURL = getImageURL(from: item) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.isEmpty ? "Menu Item \(index + 1)" : item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Price
            if !item.price.isEmpty {
                Text(item.price.hasPrefix("$") ? item.price : "$\(item.price)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    // Helper function to extract imageURL if stored as string
    private func getImageURL(from item: MenuItem) -> String? {
        // If the MenuItem has been loaded from Firebase,
        // we might need to check if there's an imageURL stored
        // This is a placeholder - adjust based on your actual data structure
        return nil
    }
}

// MARK: - Enhanced Business Details Section with Working Save
struct BusinessDetailsSection: View {
    let business: FirebaseBusiness
    var onBusinessUpdated: ((String) -> Void)? // Callback to refresh business
    
    @State private var isEditing = false
    @State private var businessHours: String = ""
    @State private var phoneNumber: String = ""
    @State private var missionStatement: String = ""
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var isSaving = false
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Business Details")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(isEditing ? "Update your information" : "Essential information")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Edit/Save Button
                    Button(action: {
                        if isEditing {
                            saveDetailsData()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isEditing.toggle()
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isSaving ? "Saving..." : (isEditing ? "Save" : "Edit"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isEditing ? [.green, .teal] : [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                    .disabled(isSaving)
                }
            }
            
            VStack(spacing: 16) {
                // Business Hours Card
                HStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Business Hours")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        if isEditing {
                            TextField("e.g., Mon-Fri 9AM-9PM", text: $businessHours)
                                .font(.system(size: 16, weight: .medium))
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        } else {
                            Text(businessHours.isEmpty ? "Not set" : businessHours)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(businessHours.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Phone Number Card
                HStack(spacing: 16) {
                    Image(systemName: "phone.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contact Number")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        if isEditing {
                            TextField("(555) 123-4567", text: $phoneNumber)
                                .font(.system(size: 16, weight: .medium))
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.phonePad)
                                .padding(8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        } else {
                            Text(phoneNumber.isEmpty ? "Not set" : phoneNumber)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(phoneNumber.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color.green.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Mission Statement Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.quote")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Our Mission")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            Text("What makes your business special")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        }
                        
                        Spacer()
                    }
                    
                    if isEditing {
                        TextEditor(text: $missionStatement)
                            .font(.system(size: 14))
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Text(missionStatement.isEmpty ? "Tell your story..." : missionStatement)
                            .font(.system(size: 14))
                            .foregroundColor(missionStatement.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.05))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear {
            loadBusinessDetails()
        }
        .onChange(of: business) { _ in
            // Reload when business changes
            if !isEditing {
                loadBusinessDetails()
            }
        }
        .alert("Details Updated!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private func loadBusinessDetails() {
        // Load existing data from the business object
        businessHours = business.hours ?? ""
        phoneNumber = business.phone ?? ""
        missionStatement = business.missionStatement ?? ""
        
        print("📋 Loaded business details:")
        print("   - Hours: \(businessHours)")
        print("   - Phone: \(phoneNumber)")
        print("   - Mission: \(missionStatement.prefix(50))...")
    }
    
    private func saveDetailsData() {
        guard let businessId = business.id else {
            saveAlertMessage = "Error: Business ID not found"
            showingSaveAlert = true
            return
        }
        
        isSaving = true
        
        // Update business details in Firebase
        businessService.updateBusinessDetails(
            businessId: businessId,
            hours: businessHours,
            phone: phoneNumber,
            missionStatement: missionStatement
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Business details saved successfully!"
                    self.isEditing = false
                    
                    // Trigger refresh of business data
                    self.onBusinessUpdated?(businessId)
                    
                    print("✅ Business details saved successfully")
                } else {
                    self.saveAlertMessage = "Failed to save details. Please try again."
                    print("❌ Failed to save business details")
                }
                self.showingSaveAlert = true
            }
        }
    }
}

// MARK: - Enhanced Menu Section with Working Save
struct MenuSection: View {
    let business: FirebaseBusiness
    var onBusinessUpdated: ((String) -> Void)? // Callback to refresh business
    
    @State private var isExpanded = false
    @State private var isEditing = false
    @State private var menuItems: [MenuItem] = []
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var selectedMenuItemForImage: MenuItem?
    @State private var showingMenuItemImagePicker = false
    @State private var tempMenuItemImage: UIImage?
    @State private var isSaving = false
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Menu")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(isEditing ? "Edit your offerings" : "Your offerings")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Edit/Save Button
                    Button(action: {
                        if isEditing {
                            saveMenuData()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isEditing.toggle()
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isSaving ? "Saving..." : (isEditing ? "Save" : "Edit"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isEditing ? [.green, .teal] : [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                    .disabled(isSaving)
                    
                    // Expand/Collapse Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.1))
                            )
                    }
                }
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    if isEditing {
                        // Editable Menu Items
                        ForEach(Array(menuItems.enumerated()), id: \.offset) { index, _ in
                            EditableMenuItemRow(
                                item: $menuItems[index],
                                index: index,
                                onDelete: {
                                    withAnimation {
                                        if menuItems.indices.contains(index) {
                                            menuItems.remove(at: index)
                                        }
                                    }
                                },
                                onImageTap: {
                                    if menuItems.indices.contains(index) {
                                        selectedMenuItemForImage = menuItems[index]
                                        showingMenuItemImagePicker = true
                                    }
                                }
                            )
                        }
                        
                        // Add Menu Item Button
                        Button(action: {
                            withAnimation {
                                menuItems.append(MenuItem(name: "", price: "", description: ""))
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add Menu Item")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    } else {
                        // Display-only Menu Items
                        if menuItems.isEmpty {
                            Text("No menu items added yet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                                DisplayMenuItemRow(item: item, index: index)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear {
            loadMenuItems()
        }
        .onChange(of: business) { _ in
            // Reload when business changes
            if !isEditing {
                loadMenuItems()
            }
        }
        .sheet(isPresented: $showingMenuItemImagePicker) {
            ImagePicker(selectedImage: $tempMenuItemImage) {
                if let image = tempMenuItemImage,
                   let index = menuItems.firstIndex(where: { $0.id == selectedMenuItemForImage?.id }) {
                    menuItems[index].image = image
                    tempMenuItemImage = nil
                }
            }
        }
        .alert("Menu Updated!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private func loadMenuItems() {
        // Convert business menu items to MenuItem objects
        if let businessMenuItems = business.menuItems {
            menuItems = businessMenuItems.map { itemData in
                MenuItem(
                    name: itemData["name"] ?? "",
                    price: itemData["price"] ?? "",
                    description: itemData["description"] ?? "",
                    image: nil // Images will be loaded separately if needed
                )
            }
            
            print("📋 Loaded \(menuItems.count) menu items")
        }
        
        // If no menu items exist, start with one empty item
        if menuItems.isEmpty {
            menuItems.append(MenuItem(name: "", price: "", description: ""))
        }
    }
    
    private func saveMenuData() {
        guard let businessId = business.id else {
            saveAlertMessage = "Error: Business ID not found"
            showingSaveAlert = true
            return
        }
        
        isSaving = true
        
        // Filter out empty menu items before saving
        let validMenuItems = menuItems.filter { !$0.name.isEmpty }
        
        // Update menu items in Firebase
        businessService.updateMenuItemsWithImages(
            businessId: businessId,
            menuItems: validMenuItems
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Menu saved successfully!"
                    self.isEditing = false
                    
                    // Trigger refresh of business data
                    self.onBusinessUpdated?(businessId)
                    
                    print("✅ Menu saved with \(validMenuItems.count) items")
                } else {
                    self.saveAlertMessage = "Failed to save menu. Please try again."
                    print("❌ Failed to save menu")
                }
                self.showingSaveAlert = true
            }
        }
    }
}
// MARK: - Category & Tags Section (Updated with Save Button)
struct CategoryAndTagsSection: View {
    let business: FirebaseBusiness
    var onTagsUpdated: ((String) -> Void)?
    @State private var isEditing = false
    @State private var newTag = ""
    @State private var editableSubtypes: [String] = []
    @State private var showingCategoryEditor = false
    @State private var isSaving = false
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category & Tags")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(isEditing ? "Update your categories" : "Help customers find you")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                // Edit/Save Button (matching other sections)
                Button(action: {
                    if isEditing {
                        saveTags()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditing.toggle()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.system(size: 14))
                        }
                        Text(isSaving ? "Saving..." : (isEditing ? "Save" : "Edit"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isEditing ? [.green, .teal] : [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
                .disabled(isSaving)
            }
            
            // Main Category
            VStack(alignment: .leading, spacing: 12) {
                Label("Main Category", systemImage: "folder.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                
                HStack {
                    CategoryBadge(
                        category: business.mainCategory ?? business.category,
                        icon: iconForCategory(business.mainCategory ?? business.category),
                        color: colorForCategory(business.mainCategory ?? business.category)
                    )
                    
                    if isEditing {
                        Button(action: { showingCategoryEditor = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.caption)
                                Text("Change")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Subtypes/Tags
            VStack(alignment: .leading, spacing: 12) {
                Label("Tags", systemImage: "tag.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                
                DashboardFlowLayout(spacing: 8) {
                    // All subtypes (including custom tags)
                    ForEach(editableSubtypes, id: \.self) { subtype in
                        TagChip(
                            text: subtype,
                            color: isCustomTag(subtype) ? .orange : colorForCategory(business.mainCategory ?? business.category),
                            isRemovable: isEditing && isCustomTag(subtype),
                            onRemove: {
                                withAnimation {
                                    editableSubtypes.removeAll { $0 == subtype }
                                }
                            }
                        )
                    }
                    
                    // Add new tag field
                    if isEditing {
                        AddTagField(
                            newTag: $newTag,
                            onAdd: addNewTag
                        )
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(editableSubtypes.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                    Text("Total Tags")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(customTagCount)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Custom Tags")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingCategoryEditor) {
            CategoryEditorModal(
                currentCategory: business.mainCategory ?? business.category,
                currentSubtypes: editableSubtypes,
                onCategorySelected: { newCategory, newSubtypes in
                    // Update both category and subtypes
                    editableSubtypes = newSubtypes
                    
                    guard let businessId = business.id else { return }
                    
                    FirebaseBusinessService.shared.updateBusinessCategories(
                        businessId: businessId,
                        mainCategory: newCategory,
                        subtypes: newSubtypes,
                        customTags: []
                    ) { success in
                        if success {
                            print("✅ Categories updated successfully")
                            print("   - Main Category: \(newCategory)")
                            print("   - Subtypes: \(newSubtypes)")
                            showingCategoryEditor = false
                            // Notify parent to refresh the business
                            onTagsUpdated?(businessId)
                        } else {
                            print("❌ Failed to update categories")
                        }
                    }
                }
            )
        }
        .onAppear {
            // Initialize editable subtypes from business data
            editableSubtypes = business.subtypes ?? []
        }
        .alert("Tags Updated!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private var customTagCount: Int {
        let categorySubtypes = getCategorySubtypes(for: business.mainCategory ?? business.category)
        return editableSubtypes.filter { !categorySubtypes.contains($0) }.count
    }
    
    private func isCustomTag(_ tag: String) -> Bool {
        let categorySubtypes = getCategorySubtypes(for: business.mainCategory ?? business.category)
        return !categorySubtypes.contains(tag)
    }
    
    private func getCategorySubtypes(for category: String) -> [String] {
        // Define the standard subtypes for each category
        switch category.lowercased() {
        case "restaurant", "food & dining":
            return ["Restaurant", "Cafe", "Bakery", "Bar & Grill", "Fast Food", "Fine Dining", "Food Truck", "Catering", "Juice Bar", "Ice Cream Shop"]
        case "retail", "retail & shopping":
            return ["Clothing", "Shoes", "Accessories", "Home Goods", "Electronics", "Books", "Gifts", "Beauty Products", "Sporting Goods"]
        case "fitness", "health & wellness":
            return ["Gym & Fitness", "Yoga Studio", "Spa & Wellness", "Mental Health", "Nutrition", "Personal Training", "Meditation Center", "Health Food Store"]
        case "business & professional":
            return ["Consulting", "Finance", "Real Estate", "Legal Services", "Marketing Agency", "Accounting", "Insurance", "Co-working Space"]
        case "technology & innovation":
            return ["Software Development", "IT Services", "Electronics Store", "Computer Repair", "Gaming", "Web Design", "App Development", "Tech Support"]
        case "medicine & healthcare":
            return ["Clinic", "Pharmacy", "Dental", "Optometry", "Physical Therapy", "Veterinary", "Medical Supplies", "Alternative Medicine"]
        case "entertainment & leisure":
            return ["Movie Theater", "Gaming Lounge", "Bowling", "Arcade", "Live Music Venue", "Comedy Club", "Art Gallery", "Museum", "Escape Room"]
        default:
            return []
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "restaurant", "food & dining": return "fork.knife"
        case "cafe": return "cup.and.saucer"
        case "retail", "retail & shopping": return "bag.fill"
        case "fitness", "health & wellness": return "figure.run"
        case "beauty": return "sparkles"
        case "technology & innovation": return "cpu"
        case "business & professional": return "briefcase.fill"
        case "medicine & healthcare": return "cross.case.fill"
        case "entertainment & leisure": return "gamecontroller.fill"
        default: return "building.2"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "restaurant", "food & dining": return .orange
        case "cafe": return .brown
        case "retail", "retail & shopping": return .pink
        case "fitness", "health & wellness": return .green
        case "beauty": return .purple
        case "technology & innovation": return .blue
        case "business & professional": return .indigo
        case "medicine & healthcare": return .red
        case "entertainment & leisure": return .purple
        default: return .gray
        }
    }
    
    private func isTagInAnyCategory(_ tag: String) -> Bool {
        let allCategories = ["restaurant", "food & dining", "cafe", "retail", "retail & shopping",
                            "fitness", "health & wellness", "business & professional",
                            "technology & innovation", "medicine & healthcare",
                            "entertainment & leisure", "beauty"]
        
        for category in allCategories {
            if getCategorySubtypes(for: category).contains(tag) {
                return true
            }
        }
        return false
    }
    
    private func addNewTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !editableSubtypes.contains(trimmedTag) {
            withAnimation {
                editableSubtypes.append(trimmedTag)
                newTag = ""
            }
        }
    }
    
    private func saveTags() {
        // Update Firebase with new tags
        guard let businessId = business.id else {
            saveAlertMessage = "Error: Business ID not found"
            showingSaveAlert = true
            return
        }
        
        isSaving = true
        
        FirebaseBusinessService.shared.updateBusinessCategories(
            businessId: businessId,
            mainCategory: business.mainCategory ?? business.category,
            subtypes: editableSubtypes,
            customTags: [] // Empty since we're storing everything in subtypes
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Categories and tags saved successfully!"
                    self.isEditing = false
                    // Notify parent to refresh the business
                    self.onTagsUpdated?(businessId)
                    print("✅ Tags updated successfully")
                } else {
                    self.saveAlertMessage = "Failed to save tags. Please try again."
                    print("❌ Failed to update tags")
                }
                self.showingSaveAlert = true
            }
        }
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text(category)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let text: String
    let color: Color
    let isRemovable: Bool
    var onRemove: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            if isRemovable {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(color.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(15)
    }
}

// MARK: - Add Tag Field
struct AddTagField: View {
    @Binding var newTag: String
    let onAdd: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            TextField("Add tag", text: $newTag)
                .font(.system(size: 12))
                .focused($isFocused)
                .onSubmit {
                    onAdd()
                }
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
            }
            .disabled(newTag.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(15)
    }
}

// MARK: - Professional Navigation Bar
struct ProfessionalNavigationBar: View {
    let businessName: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dashboard")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(businessName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Simple icon without menu
                Image(systemName: "storefront.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        }
        .background(Color.white)
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    let business: FirebaseBusiness
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                icon: "eye.fill",
                value: "\(calculateTodayViews())",
                label: "Views Today",
                trend: "+12%",
                trendUp: true,
                color: .blue
            )
            
            QuickStatCard(
                icon: "star.fill",
                value: business.displayRating,
                label: "Avg Rating",
                trend: "↑ 0.2",
                trendUp: true,
                color: .orange
            )
            
            QuickStatCard(
                icon: "person.2.fill",
                value: "\(calculateActiveUsers())",
                label: "Active Now",
                trend: "+5",
                trendUp: true,
                color: .green
            )
        }
        .padding(.horizontal)
    }
    
    private func calculateTodayViews() -> Int {
        return 127 + Int.random(in: -10...20)
    }
    
    private func calculateActiveUsers() -> Int {
        return 8 + Int.random(in: -2...5)
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let trend: String
    let trendUp: Bool
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
                Text(trend)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(trendUp ? .green : .red)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            
            Text(label)
                .font(.caption)
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Active Offers Section (Updated)
struct ActiveOffersSection: View {
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    @Binding var showCreateOffer: Bool
    
    private var activeOffers: [FirebaseOffer] {
        businessOffers.filter { $0.isActive && !$0.isExpired }
    }
    
    private var allOffers: [FirebaseOffer] {
        businessOffers.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Offers")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text("\(activeOffers.count) active, \(allOffers.count) total")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                Button(action: { showCreateOffer = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("New Offer")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.2, blue: 0.6),
                                Color(red: 0.5, green: 0.3, blue: 0.7)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Offers List
            if loadingOffers {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if allOffers.isEmpty {
                EmptyOffersCard(showCreateOffer: $showCreateOffer)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(allOffers) { offer in
                            OfferCard(offer: offer)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Offer Card
struct OfferCard: View {
    let offer: FirebaseOffer
    
    var participationPercentage: Double {
        guard offer.maxParticipants > 0 else { return 0 }
        return Double(offer.participantCount) / Double(offer.maxParticipants)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Offer Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(offer.description)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Status Badge
                Text(offer.isExpired ? "Expired" : "Active")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(offer.isExpired ? Color.red : Color.green)
                    .cornerRadius(4)
            }
            
            // Platforms
            HStack(spacing: 8) {
                ForEach(offer.platforms, id: \.self) { platform in
                    HStack(spacing: 4) {
                        Image(systemName: platformIcon(for: platform))
                            .font(.caption2)
                        Text(platform)
                            .font(.caption2)
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(4)
                }
            }
            
            Divider()
            
            // Participation Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Participation")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    
                    Spacer()
                    
                    Text("\(offer.participantCount)/\(offer.maxParticipants)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.6),
                                        Color(red: 0.5, green: 0.3, blue: 0.7)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * participationPercentage, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
            
            // Valid Until
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text("Valid until \(offer.formattedValidUntil)")
                    .font(.caption2)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Apple Maps": return "applelogo"
        case "Social Media": return "camera.fill"
        default: return "app"
        }
    }
}

// MARK: - Empty Offers Card (Updated)
struct EmptyOffersCard: View {
    @Binding var showCreateOffer: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift")
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.85))
            
            VStack(spacing: 8) {
                Text("No Active Offers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Text("Create your first offer to attract influencers")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
            
            Button(action: { showCreateOffer = true }) {
                Text("Create First Offer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.4, green: 0.2, blue: 0.6), lineWidth: 1.5)
                    )
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.85))
                )
        )
    }
}

// MARK: - Analytics Grid View
struct AnalyticsGridView: View {
    let business: FirebaseBusiness
    @Binding var selectedTimeframe: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Performance Analytics")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Spacer()
                
                Menu {
                    Button("Today") { selectedTimeframe = "Today" }
                    Button("This Week") { selectedTimeframe = "This Week" }
                    Button("This Month") { selectedTimeframe = "This Month" }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedTimeframe)
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                }
            }
            .padding(.horizontal)
            
            // Analytics Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                AnalyticsCard(
                    title: "Total Views",
                    value: "\(calculateTotalViews())",
                    change: "+23%",
                    isPositive: true,
                    icon: "eye.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Engagement Rate",
                    value: "4.2%",
                    change: "+0.8%",
                    isPositive: true,
                    icon: "hand.tap.fill",
                    color: .purple
                )
                
                AnalyticsCard(
                    title: "New Reviews",
                    value: "\(calculateNewReviews())",
                    change: "+2",
                    isPositive: true,
                    icon: "star.bubble.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Conversion",
                    value: "12.5%",
                    change: "-1.2%",
                    isPositive: false,
                    icon: "arrow.triangle.turn.up.right.diamond.fill",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func calculateTotalViews() -> String {
        let views = 1240 + Int.random(in: -50...100)
        return views > 1000 ? "\(views/1000).\(views%1000/100)k" : "\(views)"
    }
    
    private func calculateNewReviews() -> Int {
        return 8 + Int.random(in: -2...4)
    }
}

// MARK: - Analytics Card
struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    Text(change)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(isPositive ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Reviews Card
struct ReviewsCard: View {
    let business: FirebaseBusiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.bubble.fill")
                    .foregroundColor(.orange)
                Text("Recent Reviews")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(business.displayRating)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        Text("\(business.reviewCount ?? 0) reviews")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    }
                }
                
                Text("\"Great atmosphere and service!\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Vibes Card
struct VibesCard: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Vibes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Spacer()
                
                Text("3 new")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple)
                    .cornerRadius(4)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                VibeQuickItem(text: "Instagram-Perfect", count: 12)
                VibeQuickItem(text: "Great Ambiance", count: 8)
                VibeQuickItem(text: "Photo Friendly", count: 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct VibeQuickItem: View {
    let text: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(text)
                .font(.caption)
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            Spacer()
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.8))
        }
    }
}

// MARK: - Location Card
struct LocationCard: View {
    let business: FirebaseBusiness
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                Text("Business Location")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            
            Map(coordinateRegion: .constant(mapRegion))
                .frame(height: 150)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.92), lineWidth: 1)
                )
            
            Text(business.address)
                .font(.caption)
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Supporting Views
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Business Dashboard Background (for compatibility)
struct BusinessDashboardBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.3),
                Color.teal.opacity(0.4),
                Color.blue.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Category Editor Modal
struct CategoryEditorModal: View {
    let currentCategory: String
    let currentSubtypes: [String]
    let onCategorySelected: (String, [String]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: MainCategory?
    @State private var selectedSubtypes: Set<String> = []
    @State private var newTag = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Main categories (same as in BizzTagSelectionView)
    enum MainCategory: String, CaseIterable {
        case business = "Business & Professional"
        case technology = "Technology & Innovation"
        case health = "Health & Wellness"
        case medicine = "Medicine & Healthcare"
        case food = "Food & Dining"
        case retail = "Retail & Shopping"
        case entertainment = "Entertainment & Leisure"
        
        var icon: String {
            switch self {
            case .business: return "briefcase.fill"
            case .technology: return "cpu"
            case .health: return "heart.fill"
            case .medicine: return "cross.case.fill"
            case .food: return "fork.knife"
            case .retail: return "bag.fill"
            case .entertainment: return "gamecontroller.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .business: return .blue
            case .technology: return .purple
            case .health: return .green
            case .medicine: return .red
            case .food: return .orange
            case .retail: return .pink
            case .entertainment: return .indigo
            }
        }
        
        var subtypes: [String] {
            switch self {
            case .business:
                return ["Consulting", "Finance", "Real Estate", "Legal Services", "Marketing Agency", "Accounting", "Insurance", "Co-working Space"]
            case .technology:
                return ["Software Development", "IT Services", "Electronics Store", "Computer Repair", "Gaming", "Web Design", "App Development", "Tech Support"]
            case .health:
                return ["Gym & Fitness", "Yoga Studio", "Spa & Wellness", "Mental Health", "Nutrition", "Personal Training", "Meditation Center", "Health Food Store"]
            case .medicine:
                return ["Clinic", "Pharmacy", "Dental", "Optometry", "Physical Therapy", "Veterinary", "Medical Supplies", "Alternative Medicine"]
            case .food:
                return ["Restaurant", "Cafe", "Bakery", "Bar & Grill", "Fast Food", "Fine Dining", "Food Truck", "Catering", "Juice Bar", "Ice Cream Shop"]
            case .retail:
                return ["Clothing", "Shoes", "Accessories", "Home Goods", "Electronics", "Books", "Gifts", "Beauty Products", "Sporting Goods"]
            case .entertainment:
                return ["Movie Theater", "Gaming Lounge", "Bowling", "Arcade", "Live Music Venue", "Comedy Club", "Art Gallery", "Museum", "Escape Room"]
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching tag selector
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.pink.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header matching tag selector style
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: 20)
                            
                            Image(systemName: "tag.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Update Your")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("Categories")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        Text("Select category and tags for your business")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Main Categories Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Main Category")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(MainCategory.allCases, id: \.self) { category in
                                        MainCategoryCard(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            action: {
                                                // When changing category, clear all selections and only keep custom tags
                                                if selectedCategory != category {
                                                    // Filter to keep only custom tags (not in any category's subtypes)
                                                    let customTags = Array(selectedSubtypes).filter { tag in
                                                        !isTagInAnyPredefinedCategory(tag)
                                                    }
                                                    selectedSubtypes = Set(customTags)
                                                }
                                                selectedCategory = category
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Subtypes Section
                            if let category = selectedCategory {
                                SubtypesSection(
                                    category: category,
                                    selectedSubtypes: $selectedSubtypes
                                )
                            }
                            
                            // Custom Tags Section
                            CustomTagsSection(selectedSubtypes: $selectedSubtypes)
                            
                            // Update Button
                            Button(action: {
                                if let category = selectedCategory {
                                    onCategorySelected(category.rawValue, Array(selectedSubtypes))
                                }
                            }) {
                                Text("Update Categories")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: selectedCategory != nil ? [.blue, .purple] : [.gray]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: selectedCategory != nil ? Color.blue.opacity(0.3) : Color.clear, radius: 10, y: 5)
                            }
                            .disabled(selectedCategory == nil)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.purple)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Pre-select current category
            selectedCategory = MainCategory.allCases.first { $0.rawValue == currentCategory }
            
            // Only load subtypes that belong to current category
            if let category = selectedCategory {
                // Only include tags that are part of the current category's predefined subtypes
                selectedSubtypes = Set(currentSubtypes.filter { tag in
                    category.subtypes.contains(tag)
                })
            } else {
                // If no category selected, start with empty set
                selectedSubtypes = []
            }
        }
    }
    
    // Helper function to check if a tag belongs to any predefined category
    private func isTagInAnyPredefinedCategory(_ tag: String) -> Bool {
        for category in MainCategory.allCases {
            if category.subtypes.contains(tag) {
                return true
            }
        }
        return false
    }
}

// MARK: - Main Category Card (matching BizzTagSelectionView style)
struct MainCategoryCard: View {
    let category: CategoryEditorModal.MainCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [category.color, category.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? category.color : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? category.color.opacity(0.5) : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? category.color.opacity(0.2) : Color.clear, radius: 5, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

// MARK: - Subtypes Section
struct SubtypesSection: View {
    let category: CategoryEditorModal.MainCategory
    @Binding var selectedSubtypes: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subtypes")
                    .font(.headline)
                
                Text("(\(selectedSubtypes.filter { category.subtypes.contains($0) }.count) selected)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            DashboardFlowLayout(spacing: 12) {
                // Only show category subtypes - NO custom tags here
                ForEach(category.subtypes, id: \.self) { subtype in
                    SubtypeChip(
                        text: subtype,
                        isSelected: selectedSubtypes.contains(subtype),
                        color: category.color,
                        isCustom: false,
                        action: {
                            if selectedSubtypes.contains(subtype) {
                                selectedSubtypes.remove(subtype)
                            } else {
                                selectedSubtypes.insert(subtype)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
        )
        .padding(.horizontal)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: category)
    }
}

// MARK: - Subtype Chip
struct SubtypeChip: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let isCustom: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
                Text(text)
                    .font(.subheadline)
                if isCustom {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                }
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                color :
                color.opacity(0.1)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Custom Tags Section
struct CustomTagsSection: View {
    @Binding var selectedSubtypes: Set<String>
    @State private var newTag = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Get all custom tags (not in any predefined category)
    var customTags: [String] {
        return Array(selectedSubtypes).filter { tag in
            !isTagInAnyPredefinedCategory(tag)
        }.sorted()
    }
    
    private func isTagInAnyPredefinedCategory(_ tag: String) -> Bool {
        for category in CategoryEditorModal.MainCategory.allCases {
            if category.subtypes.contains(tag) {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.orange)
                Text("Custom Tags")
                    .font(.headline)
                
                if !customTags.isEmpty {
                    Text("(\(customTags.count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Add your own custom tags")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Show existing custom tags
            if !customTags.isEmpty {
                DashboardFlowLayout(spacing: 8) {
                    ForEach(customTags, id: \.self) { tag in
                        HStack(spacing: 6) {
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                            Button(action: {
                                selectedSubtypes.remove(tag)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(15)
                    }
                }
                .padding(.bottom, 8)
            }
            
            HStack(spacing: 8) {
                TextField("e.g., organic, late-night", text: $newTag)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        addTag()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(newTag.isEmpty ? .gray : .orange)
                }
                .disabled(newTag.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: newTag.isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.05))
        )
        .padding(.horizontal)
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !selectedSubtypes.contains(trimmedTag) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedSubtypes.insert(trimmedTag)
                newTag = ""
            }
        }
    }
}

// MARK: - Dashboard Flow Layout (renamed to avoid conflict)
struct DashboardFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for row in result.rows {
            for item in row.items {
                let frame = CGRect(
                    x: bounds.minX + item.x,
                    y: bounds.minY + row.y,
                    width: item.width,
                    height: row.height
                )
                subviews[item.index].place(at: frame.origin, proposal: ProposedViewSize(frame.size))
            }
        }
    }
    
    struct FlowResult {
        var rows: [Row] = []
        var height: CGFloat = 0
        
        struct Row {
            var items: [Item] = []
            var y: CGFloat = 0
            var height: CGFloat = 0
        }
        
        struct Item {
            let index: Int
            let x: CGFloat
            let width: CGFloat
        }
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentRow = Row()
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && !currentRow.items.isEmpty {
                    currentRow.y = y
                    rows.append(currentRow)
                    y += currentRow.height + spacing
                    currentRow = Row()
                    x = 0
                }
                
                currentRow.items.append(Item(index: index, x: x, width: size.width))
                currentRow.height = max(currentRow.height, size.height)
                x += size.width + spacing
            }
            
            if !currentRow.items.isEmpty {
                currentRow.y = y
                rows.append(currentRow)
                y += currentRow.height
            }
            
            height = y
        }
    }
}
