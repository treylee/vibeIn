// Path: vibeIn/Models/Firebase/FirebaseOfferModels.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase Offer Model
struct FirebaseOffer: Codable, Identifiable {
    @DocumentID var id: String?
    let businessId: String
    let businessName: String
    let businessAddress: String
    let title: String
    let description: String
    let platforms: [String]
    let createdAt: Timestamp
    let validUntil: Timestamp
    let isActive: Bool
    let participantCount: Int
    let maxParticipants: Int
    
    init(
        businessId: String,
        businessName: String,
        businessAddress: String,
        title: String,
        description: String,
        platforms: [String],
        validUntil: Timestamp,
        isActive: Bool = true,
        participantCount: Int = 0,
        maxParticipants: Int = 100
    ) {
        self.businessId = businessId
        self.businessName = businessName
        self.businessAddress = businessAddress
        self.title = title
        self.description = description
        self.platforms = platforms
        self.createdAt = Timestamp()
        self.validUntil = validUntil
        self.isActive = isActive
        self.participantCount = participantCount
        self.maxParticipants = maxParticipants
    }
    
    // Computed properties for UI
    var isExpired: Bool {
        return validUntil.dateValue() < Date()
    }
    
    var formattedValidUntil: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: validUntil.dateValue())
    }
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt.dateValue())
    }
    
    var participationProgress: Double {
        guard maxParticipants > 0 else { return 0 }
        return Double(participantCount) / Double(maxParticipants)
    }
    
    var availableSpots: Int {
        return max(0, maxParticipants - participantCount)
    }
}

// MARK: - Offer Participation Model
struct OfferParticipation: Codable, Identifiable {
    @DocumentID var id: String?
    let offerId: String
    let businessId: String
    let influencerId: String
    let influencerName: String
    let platform: String
    let joinedAt: Timestamp
    let completedAt: Timestamp?
    let isCompleted: Bool
    let proofSubmitted: Bool
    
    init(
        offerId: String,
        businessId: String,
        influencerId: String,
        influencerName: String,
        platform: String
    ) {
        self.offerId = offerId
        self.businessId = businessId
        self.influencerId = influencerId
        self.influencerName = influencerName
        self.platform = platform
        self.joinedAt = Timestamp()
        self.completedAt = nil
        self.isCompleted = false
        self.proofSubmitted = false
    }
}
