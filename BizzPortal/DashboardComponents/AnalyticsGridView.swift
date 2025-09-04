// Path: vibeIn/BizzPortal/Components/AnalyticsGridView.swift

import SwiftUI

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
