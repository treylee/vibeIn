import Foundation

// MARK: - Bizz Portal Models
struct TopFoodie: Identifiable {
    let id = UUID()
    let name: String
    let rating: Double
    let reviewCount: Int
    let profileImage: String
    let specialty: String
}

struct ChatBubble: Identifiable {
    let id = UUID()
    let message: String
    let isFromLeft: Bool
}

struct GooglePlace {
    let placeId: String
    let name: String
    let formattedAddress: String
    let isVerified: Bool
}

struct GooglePlacesResponse: Codable {
    let results: [GooglePlaceResult]
}

struct GooglePlaceResult: Codable {
    let place_id: String
    let name: String
    let formatted_address: String
    let business_status: String?
}

// MARK: - Sample Data
let sampleFoodies = [
    TopFoodie(name: "Sarah Chen", rating: 4.9, reviewCount: 2847, profileImage: "person.circle.fill", specialty: "Italian Cuisine"),
    TopFoodie(name: "Marcus Johnson", rating: 4.8, reviewCount: 1923, profileImage: "person.circle.fill", specialty: "Street Food"),
    TopFoodie(name: "Elena Rodriguez", rating: 4.9, reviewCount: 3156, profileImage: "person.circle.fill", specialty: "Desserts"),
    TopFoodie(name: "David Kim", rating: 4.7, reviewCount: 1567, profileImage: "person.circle.fill", specialty: "Craft Coffee")
]

let inspirationBubbles = [
    ChatBubble(message: "Just got 50 new customers from one post!", isFromLeft: true),
    ChatBubble(message: "My restaurant is booked solid thanks to influencer reviews!", isFromLeft: false),
    ChatBubble(message: "Increased sales by 200% this month! 🚀", isFromLeft: true),
    ChatBubble(message: "Free marketing that actually works!", isFromLeft: false),
    ChatBubble(message: "Connected with food lovers in my area", isFromLeft: true),
    ChatBubble(message: "Best decision for my business growth!", isFromLeft: false)
]
