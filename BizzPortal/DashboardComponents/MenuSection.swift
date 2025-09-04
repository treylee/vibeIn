// Path: vibeIn/BizzPortal/Components/MenuSection.swift

import SwiftUI

// MARK: - Menu Section
struct MenuSection: View {
    let business: FirebaseBusiness
    var onBusinessUpdated: ((String) -> Void)?
    
    @State private var isExpanded = false
    @State private var isEditing = false
    @State private var menuItems: [MenuItem] = []
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var selectedMenuItemForImage: MenuItem?
    @State private var showingMenuItemImagePicker = false
    @State private var tempMenuItemImage: UIImage?
    @State private var isSaving = false
    @State private var hasLoadedInitialData = false
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
            // Only load once on initial appear
            if !hasLoadedInitialData {
                loadMenuItems()
                hasLoadedInitialData = true
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
        if let businessMenuItems = business.menuItems {
            menuItems = businessMenuItems.map { itemData in
                MenuItem(
                    name: itemData["name"] ?? "",
                    price: itemData["price"] ?? "",
                    description: itemData["description"] ?? "",
                    image: nil
                )
            }
            print("📋 Loaded \(menuItems.count) menu items")
        }
        
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
        
        let validMenuItems = menuItems.filter { !$0.name.isEmpty }
        
        businessService.updateMenuItemsWithImages(
            businessId: businessId,
            menuItems: validMenuItems
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Menu saved successfully!"
                    self.isEditing = false
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
