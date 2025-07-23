// Path: vibeIn/InfluencerPortal/InfluencerReviewsAnalyticsViews.swift

import SwiftUI
import Charts

// MARK: - Past Reviews View
struct PastReviewsView: View {
    let reviews: [InfluencerReview]
    let isLoading: Bool
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else if reviews.isEmpty {
                EmptyReviewsState()
                    .padding(.top, 60)
            } else {
                VStack(spacing: 16) {
                    ForEach(reviews) { review in
                        InfluencerReviewCard(review: review)
                    }
                }
                .padding()
            }
        }
    }
}

struct InfluencerReviewCard: View {
    let review: InfluencerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.businessName)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        // Platform
                        Label(review.platform, systemImage: platformIcon(for: review.platform))
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        // Date
                        Text("• \(review.formattedDate)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(index < review.rating ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
            
            // Review Text
            Text(review.reviewText)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(3)
            
            // Metrics
            HStack(spacing: 20) {
                MetricItem(icon: "heart.fill", value: "\(review.likes)", color: .pink)
                MetricItem(icon: "bubble.left.fill", value: "\(review.comments)", color: .blue)
                MetricItem(icon: "eye.fill", value: "\(review.views)", color: .green)
                
                Spacer()
                
                if review.isVerified {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            // View Review Button
            if review.reviewURL != nil {
                Button(action: {
                    // Open review URL
                }) {
                    Text("View Full Review")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Google": return "globe"
        case "Instagram": return "camera.fill"
        case "TikTok": return "music.note"
        default: return "app"
        }
    }
}

struct MetricItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct EmptyReviewsState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No reviews yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Complete offers to build your review history!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Analytics View
struct InfluencerAnalyticsView: View {
    let influencer: FirebaseInfluencer
    @State private var selectedPeriod = "This Month"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Period Selector
                HStack {
                    Text("Analytics Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Menu {
                        Button("This Week") { selectedPeriod = "This Week" }
                        Button("This Month") { selectedPeriod = "This Month" }
                        Button("All Time") { selectedPeriod = "All Time" }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedPeriod)
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal)
                
                // Engagement Overview
                EngagementOverviewCard(influencer: influencer)
                
                // Platform Breakdown
                PlatformBreakdownCard(influencer: influencer)
                
                // Performance Metrics
                PerformanceMetricsGrid(influencer: influencer)
                
                // Category Performance
                CategoryPerformanceCard(influencer: influencer)
                
                // Growth Chart
                GrowthChartCard()
            }
            .padding(.vertical)
        }
    }
}

struct EngagementOverviewCard: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Engagement Overview")
                .font(.headline)
            
            VStack(spacing: 12) {
                EngagementRow(
                    title: "Average Engagement Rate",
                    value: influencer.engagementRateDisplay,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
                
                EngagementRow(
                    title: "Average Likes per Post",
                    value: formatNumber(influencer.averageLikes),
                    icon: "heart.fill",
                    color: .pink
                )
                
                EngagementRow(
                    title: "Average Comments",
                    value: formatNumber(influencer.averageComments),
                    icon: "bubble.left.fill",
                    color: .blue
                )
                
                EngagementRow(
                    title: "Average Views",
                    value: formatNumber(influencer.averageViews),
                    icon: "eye.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
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

struct EngagementRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}

struct PlatformBreakdownCard: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Platform Breakdown")
                .font(.headline)
            
            VStack(spacing: 12) {
                PlatformRow(
                    platform: "Instagram",
                    followers: influencer.instagramFollowers,
                    color: .purple,
                    total: influencer.totalReach
                )
                
                PlatformRow(
                    platform: "TikTok",
                    followers: influencer.tiktokFollowers,
                    color: .black,
                    total: influencer.totalReach
                )
                
                PlatformRow(
                    platform: "YouTube",
                    followers: influencer.youtubeSubscribers,
                    color: .red,
                    total: influencer.totalReach
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

struct PlatformRow: View {
    let platform: String
    let followers: Int
    let color: Color
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(followers) / Double(total)
    }
    
    private var formattedFollowers: String {
        if followers >= 1_000_000 {
            return "\(followers / 1_000_000).\((followers % 1_000_000) / 100_000)M"
        } else if followers >= 1_000 {
            return "\(followers / 1_000)K"
        }
        return "\(followers)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(platform)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(formattedFollowers)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct PerformanceMetricsGrid: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MetricCard(
                    title: "Completed Offers",
                    value: "\(influencer.completedOffers)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Total Reviews",
                    value: "\(influencer.totalReviews)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                MetricCard(
                    title: "Success Rate",
                    value: "\(calculateSuccessRate())%",
                    icon: "chart.pie.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Avg Rating",
                    value: "4.8",
                    icon: "star.circle.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func calculateSuccessRate() -> Int {
        guard influencer.joinedOffers > 0 else { return 0 }
        return Int((Double(influencer.completedOffers) / Double(influencer.joinedOffers)) * 100)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

struct CategoryPerformanceCard: View {
    let influencer: FirebaseInfluencer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Categories")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(influencer.categories, id: \.self) { category in
                    HStack {
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Mock performance data
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("+\(Int.random(in: 5...25))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if category != influencer.categories.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

struct GrowthChartCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Follower Growth")
                .font(.headline)
            
            // Mock chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { day in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 30, height: CGFloat.random(in: 40...120))
                            .cornerRadius(4)
                        
                        Text(dayLabel(for: day))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 150)
            
            HStack {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.green)
                Text("+15.3% this week")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    private func dayLabel(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index]
    }
}
