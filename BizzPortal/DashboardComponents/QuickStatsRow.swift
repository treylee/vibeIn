import SwiftUI

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
