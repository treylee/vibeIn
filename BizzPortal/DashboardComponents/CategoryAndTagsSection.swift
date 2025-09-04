// Path: vibeIn/BizzPortal/Components/CategoryAndTagsSection.swift

import SwiftUI

// MARK: - Category & Tags Section
struct CategoryAndTagsSection: View {
    let business: FirebaseBusiness
    
    @State private var isEditing = false
    @State private var newTag = ""
    @State private var editableSubtypes: [String] = []
    @State private var showingCategoryEditor = false
    @State private var isSaving = false
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var hasLoadedInitialData = false
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
                            showingCategoryEditor = false
                            // Don't trigger refresh - just keep local state
                        } else {
                            print("❌ Failed to update categories")
                        }
                    }
                }
            )
        }
        .onAppear {
            // Initialize only once
            if !hasLoadedInitialData {
                editableSubtypes = business.subtypes ?? []
                hasLoadedInitialData = true
            }
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
            customTags: []
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Categories and tags saved successfully!"
                    self.isEditing = false
                    // Don't trigger refresh - just keep local state
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

// MARK: - iOS 15 Fallback - Wrapping HStack
struct WrappingHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        // Simple vertical stack fallback for iOS 15
        VStack(alignment: .leading, spacing: spacing) {
            content()
        }
    }
}
