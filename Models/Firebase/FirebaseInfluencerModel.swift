// Path: vibeIn/Models/Firebase/FirebaseInfluencer.swift

import Foundation
import FirebaseFirestore
import Swift

struct FirebaseInfluencer: Codable, Identifiable {
    @DocumentID var id: String?
    let influencerId: String
    let userName: String
    let email: String
    let profileImageURL: String?
    
    // Social Media Stats
    let instagramFollowers: Int
    let tiktokFollowers: Int
    let youtubeSubscribers: Int
    let totalReach: Int
    
    // Engagement Metrics
    let averageEngagementRate: Double
    let averageLikes: Int
    let averageComments: Int
    let averageViews: Int
    
    // Review Stats
    let totalReviews: Int
    let completedOffers: Int
    let joinedOffers: Int
    let reviewPlatforms: [String]
    
    // Categories & Interests
    let categories: [String]
    let contentTypes: [String]
    
    // Location
    let city: String
    let state: String
    let latitude: Double?
    let longitude: Double?
    
    // Account Info
    let joinedDate: Timestamp
    let isVerified: Bool
    let isActive: Bool
    let lastActive: Timestamp
    
    // Calculated properties
    var displayFollowers: String {
        let total = instagramFollowers + tiktokFollowers + youtubeSubscribers
        if total >= 1_000_000 {
            return "\(total / 1_000_000).\((total % 1_000_000) / 100_000)M"
        } else if total >= 1_000 {
            return "\(total / 1_000)K"
        }
        return "\(total)"
    }
    
    var engagementRateDisplay: String {
        return String(format: "%.1f%%", averageEngagementRate)
    }
    
    var mainPlatform: String {
        if instagramFollowers > tiktokFollowers && instagramFollowers > youtubeSubscribers {
            return "Instagram"
        } else if tiktokFollowers > youtubeSubscribers {
            return "TikTok"
        } else {
            return "YouTube"
        }
    }
}

// MARK: - Influencer Review Model
struct InfluencerReview: Codable, Identifiable {
    @DocumentID var id: String?
    let influencerId: String
    let businessId: String
    let businessName: String
    let offerId: String
    let platform: String
    let rating: Int
    let reviewText: String
    let reviewDate: Timestamp
    let mediaURLs: [String]
    let likes: Int
    let comments: Int
    let views: Int
    let reviewURL: String?
    let isVerified: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: reviewDate.dateValue())
    }
}
