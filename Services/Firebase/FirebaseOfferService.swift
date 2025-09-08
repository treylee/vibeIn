// Path: vibeIn/Services/Firebase/FirebaseOfferService.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase Offer Service
class FirebaseOfferService: ObservableObject {
    static let shared = FirebaseOfferService()
    
    private let db = Firestore.firestore()
    private let offersCollection = "offers"
    private let participationsCollection = "offer_participations"
    
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
    
    // MARK: - Join Offer (UPDATED)
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
                if let existingParticipation = snapshot?.documents.first {
                    print("⚠️ Influencer already joined this offer")
                    completion(.failure(NSError(domain: "OfferService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "You have already joined this offer"])))
                    return
                }
                
                // If not joined, proceed to join
                self?.createParticipation(
                    offerId: offerId,
                    businessId: businessId,
                    influencerId: influencerId,
                    influencerName: influencerName,
                    platform: platform,
                    completion: completion
                )
            }
    }
    
    // MARK: - Create Participation
    private func createParticipation(
        offerId: String,
        businessId: String,
        influencerId: String,
        influencerName: String,
        platform: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let participation = OfferParticipation(
            offerId: offerId,
            businessId: businessId,
            influencerId: influencerId,
            influencerName: influencerName,
            platform: platform
        )
        
        let participationData: [String: Any] = [
            "offerId": participation.offerId,
            "businessId": participation.businessId,
            "influencerId": participation.influencerId,
            "influencerName": participation.influencerName,
            "platform": participation.platform,
            "joinedAt": participation.joinedAt,
            "completedAt": participation.completedAt as Any,
            "isCompleted": participation.isCompleted,
            "proofSubmitted": participation.proofSubmitted
        ]
        
        // Use a batch write to ensure both operations succeed or fail together
        let batch = db.batch()
        
        // Add participation record
        let participationRef = db.collection(participationsCollection).document()
        batch.setData(participationData, forDocument: participationRef)
        
        // Update offer participant count
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
                print("✅ Successfully joined offer and incremented count")
                completion(.success("Successfully joined the offer!"))
            }
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
                
                print("📄 Found \(snapshot?.documents.count ?? 0) documents")
                
                var parsedOffers: [FirebaseOffer] = []
                
                for document in snapshot?.documents ?? [] {
                    do {
                        let offer = try document.data(as: FirebaseOffer.self)
                        parsedOffers.append(offer)
                        print("   ✅ Parsed offer: \(offer.title)")
                    } catch {
                        print("   ❌ Failed to parse offer with ID \(document.documentID): \(error)")
                        print("   📝 Raw data: \(document.data())")
                    }
                }
                
                print("✅ Successfully parsed \(parsedOffers.count) offers")
                completion(parsedOffers)
            }
    }
    
    // MARK: - Get Active Offers for Influencer
    func getInfluencerActiveOffers(influencerId: String, completion: @escaping ([FirebaseOffer]) -> Void) {
        print("🔍 Getting active offers for influencer: \(influencerId)")
        
        // First get all participations for this influencer
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
                
                // Now fetch the actual offers
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
    func createRedemptionRecord(
        redemptionId: String,
        offerId: String,
        influencerId: String,
        influencerName: String,
        businessId: String,
        businessName: String,
        completion: @escaping (Bool) -> Void
    ) {
        print("📝 Creating redemption with:")
        print("   - redemptionId: \(redemptionId)")
        print("   - offerId: \(offerId)")
        print("   - influencerId: \(influencerId)")
        print("   - businessId: \(businessId)")
        
        let redemptionData: [String: Any] = [
            "redemptionId": redemptionId,
            "offerId": offerId,              // Make sure this matches query
            "influencerId": influencerId,    // Make sure this matches query
            "influencerName": influencerName,
            "businessId": businessId,
            "businessName": businessName,
            "isRedeemed": false,             // IMPORTANT: Must be false initially
            "createdAt": Timestamp(),
            "redeemedAt": NSNull()
        ]
        
        db.collection("redemptions").document(redemptionId).setData(redemptionData) { error in
            if let error = error {
                print("❌ Error creating redemption record: \(error)")
                completion(false)
            } else {
                print("✅ Redemption record created: \(redemptionId)")
                print("   Stored with offerId: \(offerId)")
                print("   Stored with influencerId: \(influencerId)")
                completion(true)
            }
        }
    }
    func checkRedemptionStatus(
        offerId: String,
        influencerId: String,
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("redemptions")
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .whereField("isRedeemed", isEqualTo: true)
            .getDocuments { snapshot, error in
                completion(!(snapshot?.documents.isEmpty ?? true))
            }
    }
    func verifyAndRedeemOffer(
        redemptionId: String,
        completion: @escaping (Result<(influencerName: String, offerDescription: String), Error>) -> Void
    ) {
        print("🔍 Verifying redemption: \(redemptionId)")
        
        // Get the redemption record
        db.collection("redemptions").document(redemptionId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching redemption: \(error.localizedDescription)")
                completion(.failure(NSError(
                    domain: "RedemptionError",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Redemption record not found"]
                )))
                return
            }
            
            guard let data = snapshot?.data(),
                  let influencerName = data["influencerName"] as? String,
                  let offerId = data["offerId"] as? String,
                  let isRedeemed = data["isRedeemed"] as? Bool else {
                print("❌ Invalid redemption data")
                completion(.failure(NSError(
                    domain: "RedemptionError",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid QR code data"]
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
            
            // Get offer details
            self?.db.collection(self?.offersCollection ?? "offers").document(offerId).getDocument { offerSnapshot, offerError in
                let offerDescription = (offerSnapshot?.data()?["description"] as? String) ?? "Special Offer"
                
                // Update redemption record
                let updateData: [String: Any] = [
                    "isRedeemed": true,
                    "redeemedAt": Timestamp()
                ]
                
                self?.db.collection("redemptions").document(redemptionId).updateData(updateData) { updateError in
                    if let updateError = updateError {
                        print("❌ Error updating redemption: \(updateError.localizedDescription)")
                        completion(.failure(updateError))
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
    
    // MARK: - Get Redemption Statistics (ALSO INSIDE THE CLASS)
    func getRedemptionStats(
        for businessId: String,
        completion: @escaping (_ totalRedemptions: Int, _ pendingRedemptions: Int) -> Void
    ) {
        db.collection("redemptions")
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
                
                completion(redeemed, pending)
                
            }
    }
    // MARK: - Get Existing Redemption (Make sure this is INSIDE the FirebaseOfferService class)
    func getExistingRedemption(
        offerId: String,
        influencerId: String,
        completion: @escaping (String?) -> Void
    ) {
        print("🔍 Checking for existing redemption:")
        print("   - Looking for offerId: \(offerId)")
        print("   - Looking for influencerId: \(influencerId)")
        
        // First, let's see ALL redemptions for this offer (for debugging)
        db.collection("redemptions")
            .whereField("offerId", isEqualTo: offerId)
            .getDocuments { snapshot, error in
                print("📊 Total redemptions for this offer: \(snapshot?.documents.count ?? 0)")
                
                if let docs = snapshot?.documents {
                    for doc in docs {
                        let data = doc.data()
                        print("   - Doc: influencerId=\(data["influencerId"] ?? "nil"), isRedeemed=\(data["isRedeemed"] ?? "nil")")
                    }
                }
            }
        
        // Now do the actual query
        db.collection("redemptions")
            .whereField("offerId", isEqualTo: offerId)
            .whereField("influencerId", isEqualTo: influencerId)
            .whereField("isRedeemed", isEqualTo: false)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error checking redemption: \(error)")
                    completion(nil)
                    return
                }
                
                print("📄 Found \(snapshot?.documents.count ?? 0) matching redemptions")
                
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    print("✅ Found existing redemption document")
                    print("   Document data: \(data)")
                    
                    if let redemptionId = data["redemptionId"] as? String {
                        print("✅ Using existing redemption: \(redemptionId)")
                        completion(redemptionId)
                    } else {
                        print("⚠️ Document exists but no redemptionId field")
                        // Try using document ID as redemption ID
                        completion(document.documentID)
                    }
                } else {
                    print("🆕 No existing redemption found, will create new")
                    completion(nil)
                }
            }
    }
}
