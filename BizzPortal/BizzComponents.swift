import SwiftUI

// MARK: - Reusable Bizz Components
struct ChatBubbleView: View {
    let bubble: ChatBubble
    
    var body: some View {
        Text(bubble.message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct FoodieCard: View {
    let foodie: TopFoodie
    
    var body: some View {
        VStack(spacing: 12) {
            FoodieAvatar(foodie: foodie)
            FoodieInfo(foodie: foodie)
        }
        .padding()
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct FoodieAvatar: View {
    let foodie: TopFoodie
    
    var body: some View {
        Image(systemName: foodie.profileImage)
            .font(.system(size: 40))
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.pink, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
    }
}

struct FoodieInfo: View {
    let foodie: TopFoodie
    
    var body: some View {
        VStack(spacing: 4) {
            Text(foodie.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(foodie.specialty)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            FoodieRating(foodie: foodie)
        }
    }
}

struct FoodieRating: View {
    let foodie: TopFoodie
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            Text(String(format: "%.1f", foodie.rating))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            Text("(\(foodie.reviewCount))")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
