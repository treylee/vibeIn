// Path: vibeIn/Models/Firebase/FirebaseUserModels.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase User Model
struct FirebaseUser: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let email: String
    let userType: String // "business_owner" or "influencer"
    let createdAt: Timestamp
    let isActive: Bool
    
    // Business owner specific fields
    let hasCreatedBusiness: Bool
    let businessId: String?
    
    init(
        userId: String,
        userName: String,
        email: String,
        userType: String = "business_owner"
    ) {
        self.userId = userId
        self.userName = userName
        self.email = email
        self.userType = userType
        self.createdAt = Timestamp()
        self.isActive = true
        self.hasCreatedBusiness = false
        self.businessId = nil
    }
    
    // Computed properties
    var canCreateBusiness: Bool {
        return userType == "business_owner" && !hasCreatedBusiness
    }
    
    var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt.dateValue())
    }
    
    // MARK: - Equatable
    static func == (lhs: FirebaseUser, rhs: FirebaseUser) -> Bool {
        return lhs.userId == rhs.userId &&
               lhs.hasCreatedBusiness == rhs.hasCreatedBusiness &&
               lhs.businessId == rhs.businessId
    }
}
