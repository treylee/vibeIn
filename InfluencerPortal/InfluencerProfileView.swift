// Path: vibeIn/InfluencerPortal/InfluencerProfileView.swift

import SwiftUI

struct InfluencerProfileView: View {
    let influencer: FirebaseInfluencer
    @State private var selectedSection = 0
    @State private var showEditProfile = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Edit Button
                HStack {
                    Spacer()
                    Button(action: { showEditProfile = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                            Text("Edit Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.purple.opacity(0.3), radius: 5, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Profile Header
                ProfileHeaderView(influencer: influencer)

                // Stats Overview
                StatsOverviewView(influencer: influencer)
                
                // Content Sections
                VStack(spacing: 20) {
                    // Categories & Interests
                    CategoriesSection(categories: influencer.categories)
                    
                    // Content Types
                    ContentTypesSection(contentTypes: influencer.contentTypes)
                    
                    // Location
                    LocationSection(city: influencer.city, state: influencer.state)
                    
                    // Account Details
                    AccountDetailsSection(influencer: influencer)
                }
                .padding(.horizontal)
                
                // Bottom decoration (similar to InfluencerPortalView)
                VStack(spacing: 12) {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("You're all caught up!")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.top, 20)
                
                // Extra padding at bottom for navigation bar
                Color.clear
                    .frame(height: 120)
            }
            .padding(.top, 60)
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showEditProfile) {
            InfluencerEditProfileView(influencer: influencer)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: influencer.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: Color.purple.opacity(0.3), radius: 10, y: 5)
            
            // Name and Verification
            HStack(spacing: 8) {
                Text(influencer.userName)
                    .font(.title)
                    .fontWeight(.bold)
                
                if influencer.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            
            // Email
            Text(influencer.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Main Platform Badge - FIXED
            HStack(spacing: 12) {
                InfluencerMainPlatformBadge(
                    platform: influencer.mainPlatform,
                    followers: influencer.displayFollowers
                )
                
                EngagementBadge(rate: influencer.engagementRateDisplay)
            }
        }
        .padding(.horizontal)
    }
}

// RENAMED to avoid conflict
struct InfluencerMainPlatformBadge: View {
    let platform: String
    let followers: String
    
    var platformColor: Color {
        switch platform {
        case "Instagram": return .purple
        case "TikTok": return .black
        case "YouTube": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: platformIcon)
                .font(.system(size: 14))
            Text("\(platform) • \(followers)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(platformColor)
        .cornerRadius(20)
    }
    
    private var platformIcon: String {
        switch platform {
        case "Instagram": return "camera.fill"
        case "TikTok": return "music.note"
        case "YouTube": return "play.rectangle.fill"
        default: return "app"
        }
    }
}

struct EngagementBadge: View {
    let rate: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
            Text(rate)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [.pink, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Stats Overview
struct StatsOverviewView: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                StatBox(
                    value: "\(influencer.totalReviews)",
                    label: "Reviews",
                    icon: "star.fill",
                    color: .yellow
                )
                
                Divider()
                    .frame(height: 40)
                
                StatBox(
                    value: "\(influencer.completedOffers)",
                    label: "Completed",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .frame(height: 40)
                
                StatBox(
                    value: formatNumber(influencer.totalReach),
                    label: "Total Reach",
                    icon: "person.3.fill",
                    color: .purple
                )
            }
            .padding(.vertical)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            
            // Platform Distribution
            HStack(spacing: 12) {
                PlatformStatBar(
                    platform: "Instagram",
                    value: influencer.instagramFollowers,
                    total: influencer.totalReach,
                    color: .purple
                )
                
                PlatformStatBar(
                    platform: "TikTok",
                    value: influencer.tiktokFollowers,
                    total: influencer.totalReach,
                    color: .black
                )
                
                PlatformStatBar(
                    platform: "YouTube",
                    value: influencer.youtubeSubscribers,
                    total: influencer.totalReach,
                    color: .red
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return "\(number / 1_000_000).\((number % 1_000_000) / 100_000)M"
        } else if number >= 1_000 {
            return "\(number / 1_000)K"
        }
        return "\(number)"
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlatformStatBar: View {
    let platform: String
    let value: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(platform)
                .font(.caption2)
                .foregroundColor(.gray)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Categories Section
struct CategoriesSection: View {
    let categories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Categories", systemImage: "tag.fill")
                .font(.headline)
                .foregroundColor(.black)
            
            FlowLayout(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(category: category)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

struct CategoryChip: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption)
            .foregroundColor(.purple)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(20)
    }
}

// MARK: - Content Types Section
struct ContentTypesSection: View {
    let contentTypes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Content Types", systemImage: "photo.on.rectangle.angled")
                .font(.headline)
                .foregroundColor(.black)
            
            FlowLayout(spacing: 8) {
                ForEach(contentTypes, id: \.self) { type in
                    ContentTypeChip(type: type)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

struct ContentTypeChip: View {
    let type: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: contentIcon)
                .font(.caption)
            Text(type)
                .font(.caption)
        }
        .foregroundColor(.pink)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.pink.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var contentIcon: String {
        switch type {
        case "Photos": return "photo"
        case "Reels": return "play.rectangle"
        case "Stories": return "circle.dashed"
        case "Videos": return "video"
        case "Live Streams": return "antenna.radiowaves.left.and.right"
        case "Blogs": return "doc.text"
        case "TikToks": return "music.note"
        case "Shorts": return "play.square"
        default: return "square.grid.2x2"
        }
    }
}

// MARK: - Location Section
struct LocationSection: View {
    let city: String
    let state: String
    
    var body: some View {
        HStack {
            Label("\(city), \(state)", systemImage: "location.fill")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Account Details Section
struct AccountDetailsSection: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Details")
                .font(.headline)
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                ProfileDetailRow(
                    label: "Member Since",
                    value: formatDate(influencer.joinedDate.dateValue()),
                    icon: "calendar"
                )
                
                ProfileDetailRow(
                    label: "Last Active",
                    value: formatRelativeDate(influencer.lastActive.dateValue()),
                    icon: "clock"
                )
                
                ProfileDetailRow(
                    label: "Account Status",
                    value: influencer.isActive ? "Active" : "Inactive",
                    icon: "circle.fill",
                    valueColor: influencer.isActive ? .green : .red
                )
                
                ProfileDetailRow(
                    label: "Verification",
                    value: influencer.isVerified ? "Verified" : "Not Verified",
                    icon: "checkmark.seal",
                    valueColor: influencer.isVerified ? .blue : .gray
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = .black
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
                
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
