// Path: vibeIn/BizzPortal/Components/CategoryEditorModal.swift

import SwiftUI

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
                // Background matching app style
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
                if #available(iOS 16.0, *) {
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
                } else {
                    // iOS 15 fallback
                    VStack(alignment: .leading, spacing: 8) {
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
