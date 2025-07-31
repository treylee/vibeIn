// Path: vibeIn/BizzPortal/BizzTagSelectionView.swift

import SwiftUI

struct BizzTagSelectionView: View {
    let businessName: String
    let address: String
    let placeID: String?
    
    @State private var selectedMainCategory: MainCategory?
    @State private var selectedSubtypes: Set<String> = []
    @State private var navigateToPreview = false
    @Environment(\.dismiss) private var dismiss
    
    // Main categories
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
                // Header
                BizzTagSelectionHeader()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Business Info Card
                        BizzBusinessInfoCard(businessName: businessName, address: address)
                            .padding(.horizontal)
                        
                        // Main Categories Section
                        BizzMainCategoriesSection(selectedMainCategory: $selectedMainCategory)
                        
                        // Subtypes Section
                        if let category = selectedMainCategory {
                            BizzSubtypesSection(
                                category: category,
                                selectedSubtypes: $selectedSubtypes
                            )
                        }
                        
                        // Custom Tags Section
                        BizzCustomTagsSection(selectedSubtypes: $selectedSubtypes)
                        
                        // Continue Button
                        BizzContinueButton(
                            isEnabled: selectedMainCategory != nil,
                            action: { navigateToPreview = true }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Choose Categories")
                    .font(.headline)
            }
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            let allSubtypes = Array(selectedSubtypes)
            let _ = print("🚀 Navigating to preview with subtypes: \(allSubtypes)")
            
            BizzPreviewView(
                businessName: businessName,
                address: address,
                placeID: placeID,
                categoryData: CategoryData(
                    mainCategory: selectedMainCategory?.rawValue ?? "",
                    subtypes: allSubtypes,
                    customTags: []  // Empty since we're merging into subtypes
                )
            )
        }
    }
}

// MARK: - Header
struct BizzTagSelectionHeader: View {
    var body: some View {
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
                Text("Categorize Your")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("Business")
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
            
            Text("Help customers find you easier")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Business Info Card
struct BizzBusinessInfoCard: View {
    let businessName: String
    let address: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(businessName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "building.2.crop.circle.fill")
                .font(.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Main Categories Section
struct BizzMainCategoriesSection: View {
    @Binding var selectedMainCategory: BizzTagSelectionView.MainCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Main Category")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(BizzTagSelectionView.MainCategory.allCases, id: \.self) { category in
                    BizzMainCategoryCard(
                        category: category,
                        isSelected: selectedMainCategory == category,
                        action: { selectedMainCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Main Category Card
struct BizzMainCategoryCard: View {
    let category: BizzTagSelectionView.MainCategory
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
struct BizzSubtypesSection: View {
    let category: BizzTagSelectionView.MainCategory
    @Binding var selectedSubtypes: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subtypes")
                    .font(.headline)
                
                Text("(Select all that apply)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            FlowLayout(spacing: 12) {
                // Category subtypes
                ForEach(category.subtypes, id: \.self) { subtype in
                    BizzSubtypeChip(
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
                
                // Custom tags (now part of selectedSubtypes)
                ForEach(Array(selectedSubtypes).filter { !category.subtypes.contains($0) }, id: \.self) { tag in
                    BizzSubtypeChip(
                        text: tag,
                        isSelected: true,
                        color: .orange,
                        isCustom: true,
                        action: {
                            selectedSubtypes.remove(tag)
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
struct BizzSubtypeChip: View {
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
struct BizzCustomTagsSection: View {
    @Binding var selectedSubtypes: Set<String>
    @State private var newTag = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.orange)
                Text("Custom Tags")
                    .font(.headline)
            }
            
            Text("Add your own custom tags")
                .font(.caption)
                .foregroundColor(.secondary)
            
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

// MARK: - Continue Button
struct BizzContinueButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Continue to Preview")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isEnabled ? [.blue, .purple] : [.gray]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: isEnabled ? Color.blue.opacity(0.3) : Color.clear, radius: 10, y: 5)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// FlowLayout is already defined elsewhere in the project
