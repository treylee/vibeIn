// Path: vibeIn/Models/Firebase/FirebaseBusinessModels.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase Business Model
struct FirebaseBusiness: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let name: String
    let address: String
    let placeID: String
    let category: String
    let offer: String
    let createdAt: Timestamp
    let isVerified: Bool
    
    // Media assets
    let imageURL: String?
    let videoURL: String?
    let mediaType: String?
    
    // Business details
    let phone: String?
    let hours: String?
    let website: String?
    let rating: Double?
    let reviewCount: Int?
    
    // Location data
    let latitude: Double?
    let longitude: Double?
    
    // Category and Tags (NEW FIELDS)
    let mainCategory: String?
    let subtypes: [String]?
    let customTags: [String]?
    
    // MARK: - Equatable
    static func == (lhs: FirebaseBusiness, rhs: FirebaseBusiness) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.placeID == rhs.placeID
    }
    
    // Convert to Restaurant model for backwards compatibility
    func toRestaurant() -> Restaurant {
        return Restaurant(
            name: name,
            category: category,
            offer: offer,
            placeID: placeID
        )
    }
    
    // Computed properties for UI
    var hasMedia: Bool {
        return (imageURL != nil && !imageURL!.isEmpty) ||
               (videoURL != nil && !videoURL!.isEmpty)
    }
    
    var displayRating: String {
        guard let rating = rating, rating > 0 else { return "No rating" }
        return String(format: "%.1f", rating)
    }
    
    var displayReviewCount: String {
        guard let count = reviewCount, count > 0 else { return "No reviews" }
        return "\(count) review\(count == 1 ? "" : "s")"
    }
    
    // New computed properties for tags
    var allTags: [String] {
        // Since custom tags are now merged into subtypes, just return subtypes
        return subtypes ?? []
    }
    
    var hasCategories: Bool {
        return mainCategory != nil || !(subtypes?.isEmpty ?? true)
    }
}
