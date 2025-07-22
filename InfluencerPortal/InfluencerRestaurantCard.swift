import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RestaurantInfo(restaurant: restaurant)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Card Components
struct RestaurantInfo: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(restaurant.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text(restaurant.category)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if !restaurant.offer.isEmpty {
                Text(restaurant.offer)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
    }
}
