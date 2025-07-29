// Path: vibeIn/BizzPortal/BusinessDashboardView.swift

import SwiftUI
import MapKit

struct BusinessDashboardView: View {
    let business: FirebaseBusiness
    @State private var navigateToCreateOffer = false
    @State private var businessOffers: [FirebaseOffer] = []
    @State private var loadingOffers = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var vibesDropdownOpen = false
    @State private var selectedTimeframe = "This Week"
    
    var body: some View {
        ZStack {
            // Professional gradient background (restored)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content without navigation bar
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
                    .padding(.top, 60) // Account for status bar
                    
                    // Quick Stats Overview
                    QuickStatsRow(business: business)
                    
                    // Active Offers Section
                    ActiveOffersSection(
                        businessOffers: businessOffers,
                        loadingOffers: loadingOffers,
                        navigateToCreateOffer: $navigateToCreateOffer
                    )
                    
                    // Analytics Grid
                    AnalyticsGridView(business: business, selectedTimeframe: $selectedTimeframe)
                    
                    // Category & Tags Section
                    CategoryAndTagsSection(business: business)
                        .padding(.horizontal)
                    
                    // Reviews & Vibes Section
                    HStack(spacing: 16) {
                        ReviewsCard(business: business)
                        VibesCard(isOpen: $vibesDropdownOpen)
                    }
                    .padding(.horizontal)
                    
                    // Location Card
                    LocationCard(business: business, mapRegion: mapRegion)
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for bottom navigation
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToCreateOffer) {
            CreateOfferView(business: business)
        }
        .onAppear {
            loadBusinessOffers()
            setupMapRegion()
            print("📊 Dashboard loading for business: \(business.name) with ID: \(business.id ?? "no-id")")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OfferCreated"))) { _ in
            // Reload offers when a new one is created
            print("🔄 Reloading offers after creation")
            loadBusinessOffers()
        }
    }
    
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

// MARK: - Category & Tags Section
struct CategoryAndTagsSection: View {
    let business: FirebaseBusiness
    @State private var isEditing = false
    @State private var newTag = ""
    @State private var customTags: [String] = ["organic", "late-night", "wifi", "pet-friendly", "outdoor-seating"]
    @State private var showingCategoryEditor = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category & Tags")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text("Help customers find you")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                Button(action: { isEditing.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                        Text(isEditing ? "Done" : "Edit")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isEditing ? .green : Color(red: 0.4, green: 0.2, blue: 0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isEditing ? Color.green.opacity(0.1) : Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.1))
                    )
                }
            }
            
            // Main Category
            VStack(alignment: .leading, spacing: 12) {
                Label("Main Category", systemImage: "folder.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                
                HStack {
                    CategoryBadge(
                        category: business.category,
                        icon: iconForCategory(business.category),
                        color: colorForCategory(business.category)
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
                
                FlowLayout(spacing: 8) {
                    // Predefined subtypes
                    ForEach(getSubtypesForCategory(business.category), id: \.self) { subtype in
                        TagChip(
                            text: subtype,
                            color: colorForCategory(business.category),
                            isRemovable: false
                        )
                    }
                    
                    // Custom tags
                    ForEach(customTags, id: \.self) { tag in
                        TagChip(
                            text: tag,
                            color: .purple,
                            isRemovable: isEditing,
                            onRemove: {
                                withAnimation {
                                    customTags.removeAll { $0 == tag }
                                }
                            }
                        )
                    }
                    
                    // Add new tag field
                    if isEditing {
                        AddTagField(
                            newTag: $newTag,
                            onAdd: {
                                if !newTag.isEmpty && !customTags.contains(newTag) {
                                    withAnimation {
                                        customTags.append(newTag)
                                        newTag = ""
                                    }
                                }
                            }
                        )
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(customTags.count + getSubtypesForCategory(business.category).count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                    Text("Total Tags")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(customTags.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text("Custom Tags")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                if isEditing {
                    Button(action: saveTags) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
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
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingCategoryEditor) {
            // Category editor modal would go here
            Text("Category Editor - Coming Soon")
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
        default: return .gray
        }
    }
    
    private func getSubtypesForCategory(_ category: String) -> [String] {
        // This would ideally come from the saved business data
        switch category.lowercased() {
        case "restaurant", "food & dining":
            return ["Italian", "Casual Dining"]
        case "cafe":
            return ["Coffee Shop", "Bakery"]
        case "retail", "retail & shopping":
            return ["Clothing", "Accessories"]
        default:
            return ["General"]
        }
    }
    
    private func saveTags() {
        // Here you would save the tags to Firebase
        print("Saving tags: \(customTags)")
        isEditing = false
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
                    .foregroundColor(.purple)
            }
            .disabled(newTag.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.purple.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(15)
        .onAppear {
            isFocused = true
        }
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

// MARK: - Active Offers Section
struct ActiveOffersSection: View {
    let businessOffers: [FirebaseOffer]
    let loadingOffers: Bool
    @Binding var navigateToCreateOffer: Bool
    
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
                
                Button(action: { navigateToCreateOffer = true }) {
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
                EmptyOffersCard(navigateToCreateOffer: $navigateToCreateOffer)
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

// MARK: - Empty Offers Card
struct EmptyOffersCard: View {
    @Binding var navigateToCreateOffer: Bool
    
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
            
            Button(action: { navigateToCreateOffer = true }) {
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
