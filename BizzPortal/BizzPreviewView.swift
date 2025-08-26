// Path: vibeIn/BizzPortal/BizzPreviewView.swift

import SwiftUI
import MapKit

// MARK: - Category Data Model
struct CategoryData {
    let mainCategory: String
    let subtypes: [String]
    let customTags: [String]
}

// MARK: - Enhanced Menu Item Model
struct MenuItem: Identifiable {
    let id = UUID()
    var name: String
    var price: String
    var description: String
    var image: UIImage? = nil
}

struct BizzPreviewView: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData?
    
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var showingMenuImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var menuImage: UIImage? = nil
    @State private var showMapView = true
    @State private var selectedContentTab = 0
    @State private var liveGoogleReviews: [GPlaceDetails.Review] = []
    @State private var loadingReviews = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Editable fields
    @State private var menuItems: [MenuItem] = []
    @State private var businessHours = "10AM - 10PM"
    @State private var phoneNumber = ""
    @State private var missionStatement = ""
    @State private var isEditingMenu = false
    @State private var isEditingDetails = false
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var selectedMenuItemForImage: MenuItem? = nil
    @State private var showingMenuItemImagePicker = false
    
    @State private var tempMenuItemImage: UIImage? = nil
    
    init(businessName: String, address: String, placeID: String? = nil, categoryData: CategoryData? = nil) {
        self.businessName = businessName
        self.address = address
        self.placeID = placeID ?? "ChIJ7YbfORN-hYARoy9V0MUxYy4"
        self.categoryData = categoryData
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            BizzPreviewContent(
                businessName: businessName,
                address: address,
                placeID: placeID,
                categoryData: categoryData,
                showingImagePicker: $showingImagePicker,
                showingVideoPicker: $showingVideoPicker,
                selectedImage: $selectedImage,
                selectedVideoURL: $selectedVideoURL,
                showMapView: $showMapView,
                selectedContentTab: $selectedContentTab,
                liveGoogleReviews: liveGoogleReviews,
                loadingReviews: loadingReviews,
                mapRegion: mapRegion,
                menuItems: $menuItems,
                menuImage: $menuImage,
                showingMenuImagePicker: $showingMenuImagePicker,
                businessHours: $businessHours,
                phoneNumber: $phoneNumber,
                missionStatement: $missionStatement,
                isEditingMenu: $isEditingMenu,
                isEditingDetails: $isEditingDetails,
                saveMenuData: saveMenuData,
                saveDetailsData: saveDetailsData,
                selectedMenuItemForImage: $selectedMenuItemForImage,
                showingMenuItemImagePicker: $showingMenuItemImagePicker
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Preview")
                    .font(.headline)
            }
        }
        .onAppear {
            loadGoogleReviews()
            if menuItems.isEmpty {
                menuItems.append(MenuItem(name: "", price: "", description: ""))
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) {
                selectedVideoURL = nil
                showMapView = false
            }
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker(selectedVideoURL: $selectedVideoURL) {
                selectedImage = nil
                showMapView = false
            }
        }
        .sheet(isPresented: $showingMenuImagePicker) {
            ImagePicker(selectedImage: $menuImage)
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
        .alert("Saved!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private func loadGoogleReviews() {
        guard let placeID = placeID else { return }
        
        loadingReviews = true
        GooglePlacesService.shared.fetchPlaceDetails(for: placeID) { reviews, _, _, _ in
            self.liveGoogleReviews = reviews
            self.loadingReviews = false
        }
    }
    
    private func saveMenuData() {
        saveAlertMessage = "Menu saved successfully!"
        showingSaveAlert = true
        isEditingMenu = false
    }
    
    private func saveDetailsData() {
        saveAlertMessage = "Business details saved successfully!"
        showingSaveAlert = true
        isEditingDetails = false
    }
}

// Using the existing ImagePicker from MediaPickers.swift
// No need to redefine it here

// MARK: - Bizz Preview Content
struct BizzPreviewContent: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData?
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var showMapView: Bool
    @Binding var selectedContentTab: Int
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    let mapRegion: MKCoordinateRegion
    @Binding var menuItems: [MenuItem]
    @Binding var menuImage: UIImage?
    @Binding var showingMenuImagePicker: Bool
    @Binding var businessHours: String
    @Binding var phoneNumber: String
    @Binding var missionStatement: String
    @Binding var isEditingMenu: Bool
    @Binding var isEditingDetails: Bool
    let saveMenuData: () -> Void
    let saveDetailsData: () -> Void
    @Binding var selectedMenuItemForImage: MenuItem?
    @Binding var showingMenuItemImagePicker: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                BizzPreviewHeader()
                
                BizzPreviewCard(
                    businessName: businessName,
                    address: address,
                    placeID: placeID,
                    categoryData: categoryData,
                    showingImagePicker: $showingImagePicker,
                    showingVideoPicker: $showingVideoPicker,
                    selectedImage: $selectedImage,
                    selectedVideoURL: $selectedVideoURL,
                    showMapView: $showMapView,
                    selectedContentTab: $selectedContentTab,
                    liveGoogleReviews: liveGoogleReviews,
                    loadingReviews: loadingReviews,
                    mapRegion: mapRegion,
                    menuItems: $menuItems,
                    menuImage: $menuImage,
                    showingMenuImagePicker: $showingMenuImagePicker,
                    businessHours: $businessHours,
                    phoneNumber: $phoneNumber,
                    missionStatement: $missionStatement,
                    isEditingMenu: $isEditingMenu,
                    isEditingDetails: $isEditingDetails,
                    saveMenuData: saveMenuData,
                    saveDetailsData: saveDetailsData,
                    selectedMenuItemForImage: $selectedMenuItemForImage,
                    showingMenuItemImagePicker: $showingMenuItemImagePicker
                )
            }
        }
    }
}

// MARK: - Bizz Preview Card
struct BizzPreviewCard: View {
    let businessName: String
    let address: String
    let placeID: String?
    let categoryData: CategoryData?
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var showMapView: Bool
    @Binding var selectedContentTab: Int
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    let mapRegion: MKCoordinateRegion
    @Binding var menuItems: [MenuItem]
    @Binding var menuImage: UIImage?
    @Binding var showingMenuImagePicker: Bool
    @Binding var businessHours: String
    @Binding var phoneNumber: String
    @Binding var missionStatement: String
    @Binding var isEditingMenu: Bool
    @Binding var isEditingDetails: Bool
    let saveMenuData: () -> Void
    let saveDetailsData: () -> Void
    @Binding var selectedMenuItemForImage: MenuItem?
    @Binding var showingMenuItemImagePicker: Bool
    
    private var hasSelectedMedia: Bool {
        return selectedImage != nil || selectedVideoURL != nil
    }
    
    private func getMediaToggleTitle() -> String {
        if selectedImage != nil {
            return "Photo View"
        } else if selectedVideoURL != nil {
            return "Video View"
        }
        return "Media View"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            BizzBasicInfo(businessName: businessName, address: address)
            
            if let categoryData = categoryData {
                BizzCategoryPreview(categoryData: categoryData)
            }
            
            if hasSelectedMedia {
                BizzMediaToggleSection(
                    showMapView: $showMapView,
                    getMediaToggleTitle: getMediaToggleTitle
                )
            }
            
            BizzMediaDisplaySection(
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL,
                showMapView: showMapView,
                hasSelectedMedia: hasSelectedMedia,
                mapRegion: mapRegion
            )
            
            BizzAttachmentOptionsSection(
                showingImagePicker: $showingImagePicker,
                showingVideoPicker: $showingVideoPicker,
                showMapView: $showMapView,
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL
            )
            
            BizzOfferPreviewSection()
            
            // Enhanced Content Tabs Section
            BizzEnhancedContentTabsSection(
                selectedContentTab: $selectedContentTab,
                menuItems: $menuItems,
                menuImage: $menuImage,
                showingMenuImagePicker: $showingMenuImagePicker,
                businessHours: $businessHours,
                phoneNumber: $phoneNumber,
                missionStatement: $missionStatement,
                liveGoogleReviews: liveGoogleReviews,
                loadingReviews: loadingReviews,
                isEditingMenu: $isEditingMenu,
                isEditingDetails: $isEditingDetails,
                saveMenuData: saveMenuData,
                saveDetailsData: saveDetailsData,
                selectedMenuItemForImage: $selectedMenuItemForImage,
                showingMenuItemImagePicker: $showingMenuItemImagePicker
            )
            
            // Complete Setup Button
            BizzEnhancedCompleteSetupButton(
                businessName: businessName,
                address: address,
                placeID: placeID,
                selectedImage: selectedImage,
                selectedVideoURL: selectedVideoURL,
                liveGoogleReviews: liveGoogleReviews,
                categoryData: categoryData,
                menuItems: menuItems,
                menuImage: menuImage,
                businessHours: businessHours,
                phoneNumber: phoneNumber,
                missionStatement: missionStatement
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

// MARK: - Enhanced Content Tabs Section
struct BizzEnhancedContentTabsSection: View {
    @Binding var selectedContentTab: Int
    @Binding var menuItems: [MenuItem]
    @Binding var menuImage: UIImage?
    @Binding var showingMenuImagePicker: Bool
    @Binding var businessHours: String
    @Binding var phoneNumber: String
    @Binding var missionStatement: String
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    @Binding var isEditingMenu: Bool
    @Binding var isEditingDetails: Bool
    let saveMenuData: () -> Void
    let saveDetailsData: () -> Void
    @Binding var selectedMenuItemForImage: MenuItem?
    @Binding var showingMenuItemImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Modern Tab Selector
            HStack(spacing: 0) {
                ForEach(Array(["Menu", "Details", "Reviews"].enumerated()), id: \.offset) { index, title in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedContentTab = index
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.system(size: 14, weight: selectedContentTab == index ? .semibold : .regular))
                                .foregroundColor(selectedContentTab == index ? .purple : .gray)
                            
                            Rectangle()
                                .fill(selectedContentTab == index ? Color.purple : Color.clear)
                                .frame(height: 2)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedContentTab)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            if selectedContentTab == 0 {
                ModernMenuTab(
                    menuItems: $menuItems,
                    menuImage: $menuImage,
                    showingMenuImagePicker: $showingMenuImagePicker,
                    isEditing: $isEditingMenu,
                    saveAction: saveMenuData,
                    selectedMenuItemForImage: $selectedMenuItemForImage,
                    showingMenuItemImagePicker: $showingMenuItemImagePicker
                )
            } else if selectedContentTab == 1 {
                ModernDetailsTab(
                    businessHours: $businessHours,
                    phoneNumber: $phoneNumber,
                    missionStatement: $missionStatement,
                    isEditing: $isEditingDetails,
                    saveAction: saveDetailsData
                )
            } else if selectedContentTab == 2 {
                BizzLiveGoogleReviewsContent(
                    liveGoogleReviews: liveGoogleReviews,
                    loadingReviews: loadingReviews
                )
            }
        }
    }
}

// MARK: - Modern Menu Tab with Item Images
struct ModernMenuTab: View {
    @Binding var menuItems: [MenuItem]
    @Binding var menuImage: UIImage?
    @Binding var showingMenuImagePicker: Bool
    @Binding var isEditing: Bool
    let saveAction: () -> Void
    @Binding var selectedMenuItemForImage: MenuItem?
    @Binding var showingMenuItemImagePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            menuHeader
            
            // Menu Header Image
            if isEditing || menuImage != nil {
                menuImageSection
            }
            
            // Menu Items
            menuItemsList
        }
    }
    
    private var menuHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Menu")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                    )
                Text("Showcase your best dishes")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                if isEditing {
                    saveAction()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditing.toggle()
                    }
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                    Text(isEditing ? "Save" : "Edit")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: isEditing ? [.green, .teal] : [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
            }
        }
    }
    
    private var menuImageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                Text("Menu Photo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                if isEditing {
                    showingMenuImagePicker = true
                }
            }) {
                if let image = menuImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .cornerRadius(16)
                        .clipped()
                } else if isEditing {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.1))
                            .frame(height: 120)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.title)
                                .foregroundColor(.purple)
                            Text("Add Menu Photo")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .disabled(!isEditing)
        }
    }
    
    private var menuItemsList: some View {
        VStack(spacing: 16) {
            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, _ in
                ModernMenuItemCard(
                    item: $menuItems[index],
                    index: index,
                    isEditing: isEditing,
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
            
            if isEditing {
                addMenuItemButton
            }
        }
    }
    
    private var addMenuItemButton: some View {
        Button(action: {
            withAnimation {
                menuItems.append(MenuItem(name: "", price: "", description: ""))
            }
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add Menu Item")
                    .font(.headline)
            }
            .foregroundStyle(
                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
            )
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.purple.opacity(0.05))
            )
        }
    }
}

// MARK: - Modern Menu Item Card
struct ModernMenuItemCard: View {
    @Binding var item: MenuItem
    let index: Int
    let isEditing: Bool
    let onDelete: () -> Void
    let onImageTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Item Number
            itemNumberBadge
            
            // Item Image
            itemImageButton
            
            // Item Details
            itemDetailsSection
            
            // Delete button
            if isEditing {
                deleteButton
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var itemNumberBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var itemImageButton: some View {
        Button(action: {
            if isEditing {
                onImageTap()
            }
        }) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .clipped()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isEditing ? "photo.badge.plus" : "photo")
                        .font(.title2)
                        .foregroundColor(isEditing ? .purple : .gray.opacity(0.5))
                }
            }
        }
        .disabled(!isEditing)
    }
    
    private var itemDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                TextField("Item name", text: $item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 8) {
                    TextField("$0.00", text: $item.price)
                        .font(.system(size: 14, weight: .medium))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $item.description)
                        .font(.system(size: 12))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                Text(item.name.isEmpty ? "Menu Item \(index + 1)" : item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                if !item.price.isEmpty {
                    Text(item.price.hasPrefix("$") ? item.price : "$\(item.price)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash.fill")
                .font(.system(size: 16))
                .foregroundColor(.red)
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// MARK: - Modern Details Tab
struct ModernDetailsTab: View {
    @Binding var businessHours: String
    @Binding var phoneNumber: String
    @Binding var missionStatement: String
    @Binding var isEditing: Bool
    let saveAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Business Details")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                    Text("Essential information for customers")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    if isEditing {
                        saveAction()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditing.toggle()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        Text(isEditing ? "Save" : "Edit")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: isEditing ? [.green, .teal] : [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            
            VStack(spacing: 16) {
                // Business Hours
                ModernDetailCard(
                    icon: "clock.fill",
                    iconColor: .blue,
                    title: "Business Hours",
                    value: $businessHours,
                    placeholder: "e.g., Mon-Fri 9AM-9PM",
                    isEditing: isEditing
                )
                
                // Phone Number
                ModernDetailCard(
                    icon: "phone.fill",
                    iconColor: .green,
                    title: "Contact Number",
                    value: $phoneNumber,
                    placeholder: "(555) 123-4567",
                    isEditing: isEditing,
                    keyboardType: .phonePad
                )
                
                // Mission Statement
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.quote")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Our Mission")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("What makes your business special")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    if isEditing {
                        TextEditor(text: $missionStatement)
                            .font(.system(size: 14))
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Text(missionStatement.isEmpty ? "Tell your story..." : missionStatement)
                            .font(.system(size: 14))
                            .foregroundColor(missionStatement.isEmpty ? .gray : .black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.05))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            }
        }
    }
}

// MARK: - Modern Detail Card
struct ModernDetailCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var value: String
    let placeholder: String
    let isEditing: Bool
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if isEditing {
                    TextField(placeholder, text: $value)
                        .font(.system(size: 16, weight: .medium))
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(keyboardType)
                } else {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(value.isEmpty ? .gray : .black)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isEditing ? iconColor.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Keep all other existing components below...
// (BizzPreviewHeader, BizzCategoryPreview, BizzBasicInfo, etc.)

struct BizzPreviewHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Preview Your")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            Text("Business Page")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.top, 20)
    }
}

// Continue with remaining components...
// (Include all the other existing components from the original file)

struct BizzCategoryPreview: View {
    let categoryData: CategoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.purple)
                Text("Categories & Tags")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Main:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(categoryData.mainCategory)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                
                let allTags = categoryData.subtypes + categoryData.customTags
                if !allTags.isEmpty {
                    Text("Tags:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BizzBasicInfo: View {
    let businessName: String
    let address: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(businessName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            
            Text(address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

struct BizzMediaToggleSection: View {
    @Binding var showMapView: Bool
    let getMediaToggleTitle: () -> String
    
    var body: some View {
        let toggleBackground = RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
        
        HStack(spacing: 0) {
            Button(action: { showMapView = true }) {
                Text("Map View")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showMapView ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(showMapView ? Color.blue : Color.clear)
                    )
            }
            
            Button(action: { showMapView = false }) {
                Text(getMediaToggleTitle())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(!showMapView ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(!showMapView ? Color.blue : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(toggleBackground)
    }
}

struct BizzMediaDisplaySection: View {
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    let showMapView: Bool
    let hasSelectedMedia: Bool
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        let mapOverlay = VStack {
            Spacer()
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                Text("Your Business Location")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                Spacer()
            }
            .padding()
        }
        
        if !hasSelectedMedia || showMapView {
            Map(coordinateRegion: .constant(mapRegion))
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(mapOverlay)
        } else {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            } else if let videoURL = selectedVideoURL {
                VStack(spacing: 12) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Video: \(videoURL.lastPathComponent)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct BizzAttachmentOptionsSection: View {
    @Binding var showingImagePicker: Bool
    @Binding var showingVideoPicker: Bool
    @Binding var showMapView: Bool
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    
    enum AttachmentType: CaseIterable {
        case image, video, map
        
        var title: String {
            switch self {
            case .image: return "Add Photo"
            case .video: return "Add Video"
            case .map: return "Add Map"
            }
        }
        
        var icon: String {
            switch self {
            case .image: return "photo.fill"
            case .video: return "video.fill"
            case .map: return "map.fill"
            }
        }
    }
    
    private func handleAttachmentSelection(_ type: AttachmentType) {
        switch type {
        case .image:
            showingImagePicker = true
        case .video:
            showingVideoPicker = true
        case .map:
            showMapView = true
        }
    }
    
    private func isAttachmentSelected(_ type: AttachmentType) -> Bool {
        switch type {
        case .image:
            return selectedImage != nil
        case .video:
            return selectedVideoURL != nil
        case .map:
            return true
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add content to your page:")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(AttachmentType.allCases, id: \.self) { attachment in
                    Button(action: {
                        handleAttachmentSelection(attachment)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: attachment.icon)
                                .font(.title2)
                                .foregroundColor(isAttachmentSelected(attachment) ? .white : .black)
                            Text(attachment.title)
                                .font(.caption)
                                .foregroundColor(isAttachmentSelected(attachment) ? .white : .black)
                        }
                        .padding()
                        .frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isAttachmentSelected(attachment) ? Color.blue : Color.white.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isAttachmentSelected(attachment) ? Color.blue : Color.gray.opacity(0.3), lineWidth: isAttachmentSelected(attachment) ? 2 : 1)
                                )
                        )
                    }
                }
            }
        }
    }
}

struct BizzOfferPreviewSection: View {
    var body: some View {
        let joinOfferButton = RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                AngularGradient(gradient: Gradient(colors: [.pink, .blue, .purple, .orange]), center: .center),
                lineWidth: 3
            )
        
        VStack(spacing: 12) {
            Text("Sample Offer: Free Appetizer for Reviews")
                .font(.headline)
                .foregroundColor(.black)
            
            Text("0 out of 100 people joined")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Text("Join Offer")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(joinOfferButton)
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct BizzLiveGoogleReviewsContent: View {
    let liveGoogleReviews: [GPlaceDetails.Review]
    let loadingReviews: Bool
    
    var body: some View {
        if loadingReviews {
            VStack {
                ProgressView("Loading Google Reviews...")
                    .padding()
            }
        } else if liveGoogleReviews.isEmpty {
            VStack {
                Text("No Google reviews available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(liveGoogleReviews, id: \.text.text) { review in
                    BizzLiveReviewCard(review: review)
                }
            }
        }
    }
}

struct BizzLiveReviewCard: View {
    let review: GPlaceDetails.Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorAttribution?.displayName ?? "Anonymous")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Google")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if let rating = review.rating {
                    BizzLiveStarRating(rating: rating)
                }
            }
            
            Text(review.text.text)
                .font(.body)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            if let publishTime = review.publishTime {
                Text(publishTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

struct BizzLiveStarRating: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(index < rating ? .yellow : .gray.opacity(0.5))
                    .font(.caption)
            }
        }
    }
}

// MARK: - Enhanced Complete Setup Button
struct BizzEnhancedCompleteSetupButton: View {
    let businessName: String
    let address: String
    let placeID: String?
    let selectedImage: UIImage?
    let selectedVideoURL: URL?
    let liveGoogleReviews: [GPlaceDetails.Review]
    let categoryData: CategoryData?
    let menuItems: [MenuItem]
    let menuImage: UIImage?
    let businessHours: String
    let phoneNumber: String
    let missionStatement: String
    
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
            BizzNavigationContainer()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func createBusiness() {
        guard !businessName.isEmpty else {
            showError("Business name is required")
            return
        }
        
        // Prepare menu data for storage (including images)
        let menuData = menuItems.filter { !$0.name.isEmpty }.map { item in
            var itemData: [String: String] = [
                "name": item.name,
                "price": item.price,
                "description": item.description
            ]
            // Note: Item images would need to be uploaded separately and URLs stored
            return itemData
        }
        
        firebaseService.createBusinessWithEnhancedData(
            name: businessName,
            address: address,
            placeID: placeID ?? "",
            category: categoryData?.mainCategory ?? "General",
            offer: "Free Appetizer for Reviews",
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            menuImage: menuImage,
            googleReviews: liveGoogleReviews,
            categoryData: categoryData,
            menuItems: menuData,
            businessHours: businessHours,
            phoneNumber: phoneNumber,
            missionStatement: missionStatement
        ) { result in
            switch result {
            case .success(let (message, businessId)):
                print("✅ Business created with ID: \(businessId)")
                
                if let currentUser = self.userService.currentUser {
                    self.userService.updateUserAfterBusinessCreation(businessId: businessId) { success in
                        if success {
                            print("✅ User updated with business ID: \(businessId)")
                            
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
