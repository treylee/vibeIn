// Path: vibeIn/Services/Firebase/FirebaseOfferService.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase Offer Service
class FirebaseOfferService: ObservableObject {
    static let shared = FirebaseOfferService()
    
    private let db = Firestore.firestore()
    private let offersCollection = "offers"
    private let participationsCollection = "offer_participations"
    private let redemptionsCollection = "redemptions"
    
    @Published var offers: [FirebaseOffer] = []
    @Published var isLoading = false
    
    private var listener: ListenerRegistration?
    
    private init() {
        setupRealtimeListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Real-time Listener
    private func setupRealtimeListener() {
        listener = db.collection(offersCollection)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Firebase Offer Listener Error: \(error.localizedDescription)")
                    return
                }
                
                let offers = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirebaseOffer.self)
                } ?? []
                
                // Filter out expired offers
                let activeOffers = offers.filter { !$0.isExpired }
                
                DispatchQueue.main.async {
                    self?.offers = activeOffers
                    print("🔄 Firebase: Updated to \(activeOffers.count) active offers")
                }
            }
    }
    
    // MARK: - Create Offer
    func createOffer(
        _ offer: FirebaseOffer,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        isLoading = true
        print("🚀 Creating offer in Firebase: \(offer.title)")
        print("   - BusinessId: \(offer.businessId)")
        print("   - BusinessName: \(offer.businessName)")
        
        let offerData: [String: Any] = [
            "businessId": offer.businessId,
            "businessName": offer.businessName,
            "businessAddress": offer.businessAddress,
            "title": offer.title,
            "description": offer.description,
            "platforms": offer.platforms,
            "createdAt": offer.createdAt,
            "validUntil": offer.validUntil,
            "isActive": offer.isActive,
            "participantCount": offer.participantCount,
            "maxParticipants": offer.maxParticipants
        ]
        
        db.collection(offersCollection).addDocument(data: offerData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating offer: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Offer created successfully in Firebase!")
                    completion(.success("Offer created successfully"))
                }
            }
        }
    }
    
    // MARK: - Join Offer (FIXED - Now creates both participation AND redemption record)
    func joinOffer(
        offerId: String,
        businessId: String,
        influencerId: String,
        influencerName: String,
        platform: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("🎯 Attempting to join offer: \(offerId)")
        
        // First, check if the influencer has already joined this offer
        db.collection(participationsCollection)
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Check if already joined
                if let _ = snapshot?.documents.first {
                    print("⚠️ Influencer already joined this offer")
                    completion(.failure(NSError(
                        domain: "OfferService",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "You have already joined this offer"]
                    )))
                    return
                }
                
                // Get offer details for redemption record
                self?.db.collection(self?.offersCollection ?? "offers")
                    .document(offerId)
                    .getDocument { offerSnapshot, offerError in
                        guard let offerData = offerSnapshot?.data(),
                              let businessName = offerData["businessName"] as? String else {
                            completion(.failure(NSError(
                                domain: "OfferService",
                                code: 1002,
                                userInfo: [NSLocalizedDescriptionKey: "Could not find offer details"]
                            )))
                            return
                        }
                        
                        // If not joined, create BOTH participation AND redemption records
                        self?.createParticipationWithRedemption(
                            offerId: offerId,
                            businessId: businessId,
                            businessName: businessName,
                            influencerId: influencerId,
                            influencerName: influencerName,
                            platform: platform,
                            completion: completion
                        )
                    }
            }
    }
    
    // MARK: - Create Participation WITH Redemption Record (VERIFIED)
    private func createParticipationWithRedemption(
        offerId: String,
        businessId: String,
        businessName: String,
        influencerId: String,
        influencerName: String,
        platform: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Generate a SINGLE redemption ID that will be used for this participation
        let redemptionId = UUID().uuidString
        
        print("📝 Creating participation and redemption:")
        print("   - redemptionId: \(redemptionId)")
        print("   - offerId: \(offerId)")
        print("   - businessId: \(businessId)")
        
        let participation = OfferParticipation(
            offerId: offerId,
            businessId: businessId,
            influencerId: influencerId,
            influencerName: influencerName,
            platform: platform
        )
        
        let participationData: [String: Any] = [
            "offerId": offerId,  // CRITICAL: Must match the offer
            "businessId": businessId,
            "influencerId": influencerId,
            "influencerName": influencerName,
            "platform": platform,
            "joinedAt": participation.joinedAt,
            "completedAt": participation.completedAt as Any,
            "isCompleted": false,
            "proofSubmitted": false,
            "redemptionId": redemptionId  // Link to redemption record
        ]
        
        let redemptionData: [String: Any] = [
            "redemptionId": redemptionId,
            "offerId": offerId,  // CRITICAL: Must match the offer
            "influencerId": influencerId,
            "influencerName": influencerName,
            "businessId": businessId,
            "businessName": businessName,
            "isRedeemed": false,  // Starts as pending
            "createdAt": Timestamp(),
            "redeemedAt": NSNull()
        ]
        
        // Use a batch write to ensure all operations succeed or fail together
        let batch = db.batch()
        
        // Add participation record
        let participationRef = db.collection(participationsCollection).document()
        batch.setData(participationData, forDocument: participationRef)
        
        // Add redemption record with the SAME ID
        let redemptionRef = db.collection(redemptionsCollection).document(redemptionId)
        batch.setData(redemptionData, forDocument: redemptionRef)
        
        // Update offer participant count - THIS IS CRITICAL
        let offerRef = db.collection(offersCollection).document(offerId)
        batch.updateData([
            "participantCount": FieldValue.increment(Int64(1))
        ], forDocument: offerRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("❌ Error joining offer: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Successfully joined offer:")
                print("   - Created participation record with offerId: \(offerId)")
                print("   - Created redemption record with offerId: \(offerId)")
                print("   - Redemption ID: \(redemptionId)")
                print("   - Incremented participantCount on offer document")
                completion(.success("Successfully joined the offer!"))
            }
        }
    }
    
    // MARK: - Get Redemption ID for Participation (NEW)
    func getRedemptionId(
        offerId: String,
        influencerId: String,
        completion: @escaping (String?) -> Void
    ) {
        print("🔍 Getting redemption ID for offer: \(offerId), influencer: \(influencerId)")
        
        // First check participation record for redemption ID
        db.collection(participationsCollection)
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error getting participation: \(error)")
                    completion(nil)
                    return
                }
                
                guard let participationData = snapshot?.documents.first?.data(),
                      let redemptionId = participationData["redemptionId"] as? String else {
                    print("❌ No participation found or no redemption ID")
                    completion(nil)
                    return
                }
                
                print("✅ Found redemption ID: \(redemptionId)")
                
                // Verify the redemption record exists and is not redeemed
                self?.db.collection(self?.redemptionsCollection ?? "redemptions")
                    .document(redemptionId)
                    .getDocument { redemptionSnapshot, _ in
                        if let data = redemptionSnapshot?.data(),
                           let isRedeemed = data["isRedeemed"] as? Bool,
                           !isRedeemed {
                            print("✅ Redemption is valid and unused")
                            completion(redemptionId)
                        } else {
                            print("⚠️ Redemption already used or invalid")
                            completion(nil)
                        }
                    }
            }
    }
    
    // MARK: - Verify and Redeem Offer (UPDATED)
    func verifyAndRedeemOffer(
        redemptionId: String,
        completion: @escaping (Result<(influencerName: String, offerDescription: String), Error>) -> Void
    ) {
        print("🔍 Verifying redemption: \(redemptionId)")
        
        // Get the redemption record
        db.collection(redemptionsCollection).document(redemptionId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching redemption: \(error.localizedDescription)")
                completion(.failure(NSError(
                    domain: "RedemptionError",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid QR code - redemption not found"]
                )))
                return
            }
            
            guard let data = snapshot?.data(),
                  let influencerName = data["influencerName"] as? String,
                  let offerId = data["offerId"] as? String,
                  let businessId = data["businessId"] as? String,
                  let isRedeemed = data["isRedeemed"] as? Bool else {
                print("❌ Invalid redemption data")
                completion(.failure(NSError(
                    domain: "RedemptionError",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid QR code format"]
                )))
                return
            }
            
            // Check if already redeemed
            if isRedeemed {
                print("⚠️ Offer already redeemed")
                completion(.failure(NSError(
                    domain: "RedemptionError",
                    code: 409,
                    userInfo: [NSLocalizedDescriptionKey: "This offer has already been redeemed"]
                )))
                return
            }
            
            // Get offer details and verify business
            self?.db.collection(self?.offersCollection ?? "offers").document(offerId).getDocument { offerSnapshot, _ in
                guard let offerData = offerSnapshot?.data(),
                      let offerBusinessId = offerData["businessId"] as? String else {
                    completion(.failure(NSError(
                        domain: "RedemptionError",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Offer not found"]
                    )))
                    return
                }
                
                // IMPORTANT: Verify this redemption is for the correct business
                if offerBusinessId != businessId {
                    print("❌ Business mismatch - redemption is for different business")
                    completion(.failure(NSError(
                        domain: "RedemptionError",
                        code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "This offer is for a different business"]
                    )))
                    return
                }
                
                let offerDescription = (offerData["description"] as? String) ?? "Special Offer"
                
                // Use batch to update both redemption and participation
                let batch = self?.db.batch()
                
                // Update redemption record
                let redemptionRef = self?.db.collection(self?.redemptionsCollection ?? "redemptions").document(redemptionId)
                batch?.updateData([
                    "isRedeemed": true,
                    "redeemedAt": Timestamp()
                ], forDocument: redemptionRef!)
                
                // Update participation record
                self?.db.collection(self?.participationsCollection ?? "offer_participations")
                    .whereField("redemptionId", isEqualTo: redemptionId)
                    .getDocuments { participationSnapshot, _ in
                        if let participationDoc = participationSnapshot?.documents.first {
                            batch?.updateData([
                                "isCompleted": true,
                                "completedAt": Timestamp()
                            ], forDocument: participationDoc.reference)
                        }
                        
                        // Commit the batch
                        batch?.commit { error in
                            if let error = error {
                                print("❌ Error updating redemption: \(error.localizedDescription)")
                                completion(.failure(error))
                            } else {
                                print("✅ Offer successfully redeemed for \(influencerName)")
                                completion(.success((
                                    influencerName: influencerName,
                                    offerDescription: offerDescription
                                )))
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - Check Redemption Status
    func checkRedemptionStatus(
        offerId: String,
        influencerId: String,
        completion: @escaping (Bool) -> Void
    ) {
        // Check participation record for completion status
        db.collection(participationsCollection)
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .whereField("isCompleted", isEqualTo: true)
            .getDocuments { snapshot, error in
                completion(!(snapshot?.documents.isEmpty ?? true))
            }
    }
    
    // MARK: - Get Offers for Business
    func getOffersForBusiness(businessId: String, completion: @escaping ([FirebaseOffer]) -> Void) {
        print("🔍 Querying offers for businessId: \(businessId)")
        
        db.collection(offersCollection)
            .whereField("businessId", isEqualTo: businessId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching business offers: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let offers = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirebaseOffer.self)
                } ?? []
                
                print("✅ Found \(offers.count) offers for business")
                completion(offers)
            }
    }
    
    // MARK: - Get Active Offers for Influencer
    func getInfluencerActiveOffers(influencerId: String, completion: @escaping ([FirebaseOffer]) -> Void) {
        print("🔍 Getting active offers for influencer: \(influencerId)")
        
        // Get all participations for this influencer that are not completed
        db.collection(participationsCollection)
            .whereField("influencerId", isEqualTo: influencerId)
            .whereField("isCompleted", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching participations: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let offerIds = snapshot?.documents.compactMap { $0.data()["offerId"] as? String } ?? []
                
                if offerIds.isEmpty {
                    completion([])
                    return
                }
                
                // Fetch the actual offers
                self?.db.collection(self?.offersCollection ?? "offers")
                    .whereField(FieldPath.documentID(), in: offerIds)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("❌ Error fetching offers: \(error.localizedDescription)")
                            completion([])
                            return
                        }
                        
                        let offers = snapshot?.documents.compactMap { document in
                            try? document.data(as: FirebaseOffer.self)
                        } ?? []
                        
                        // Filter out expired offers
                        let activeOffers = offers.filter { !$0.isExpired }
                        
                        print("✅ Found \(activeOffers.count) active offers for influencer")
                        completion(activeOffers)
                    }
            }
    }
    
    // MARK: - Check if Influencer Joined Offer
    func hasInfluencerJoinedOffer(influencerId: String, offerId: String, completion: @escaping (Bool) -> Void) {
        db.collection(participationsCollection)
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .getDocuments { snapshot, error in
                completion(!(snapshot?.documents.isEmpty ?? true))
            }
    }
    
    // MARK: - Get Redemption Statistics for Business Dashboard
    func getRedemptionStats(
        for businessId: String,
        completion: @escaping (_ totalRedemptions: Int, _ pendingRedemptions: Int) -> Void
    ) {
        db.collection(redemptionsCollection)
            .whereField("businessId", isEqualTo: businessId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion(0, 0)
                    return
                }
                
                let total = documents.count
                let redeemed = documents.filter {
                    ($0.data()["isRedeemed"] as? Bool) == true
                }.count
                let pending = total - redeemed
                
                print("📊 Business \(businessId) - Total: \(total), Redeemed: \(redeemed), Pending: \(pending)")
                completion(redeemed, pending)
            }
    }
    
    // MARK: - Deactivate Expired Offers
    func deactivateExpiredOffers() {
        let now = Timestamp()
        
        db.collection(offersCollection)
            .whereField("isActive", isEqualTo: true)
            .whereField("validUntil", isLessThan: now)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let batch = self?.db.batch()
                
                for document in documents {
                    batch?.updateData(["isActive": false], forDocument: document.reference)
                }
                
                batch?.commit { error in
                    if let error = error {
                        print("❌ Error deactivating expired offers: \(error.localizedDescription)")
                    } else {
                        print("✅ Expired offers deactivated")
                    }
                }
            }
    }
}
