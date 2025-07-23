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
                
                DispatchQueue.main.async {
                    self?.offers = offers
                    print("🔄 Firebase: Updated to \(offers.count) active offers")
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
    
    // MARK: - Join Offer
    func joinOffer(
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
        
        // Add participation record
        db.collection(participationsCollection).addDocument(data: participationData) { [weak self] error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update offer participant count
            self?.incrementParticipantCount(offerId: offerId) { result in
                completion(result)
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
    
    // MARK: - Get Active Offers
    func getActiveOffers(completion: @escaping ([FirebaseOffer]) -> Void) {
        db.collection(offersCollection)
            .whereField("isActive", isEqualTo: true)
            .whereField("validUntil", isGreaterThan: Timestamp())
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching active offers: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let offers = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirebaseOffer.self)
                } ?? []
                
                completion(offers)
            }
    }
    
    // MARK: - Private Methods
    private func incrementParticipantCount(offerId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection(offersCollection).document(offerId).updateData([
            "participantCount": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Joined offer successfully"))
            }
        }
    }
    
    // MARK: - Deactivate Expired Offers
    func deactivateExpiredOffers() {
        let now = Timestamp()
        
        db.collection(offersCollection)
            .whereField("isActive", isEqualTo: true)
            .whereField("validUntil", isLessThan: now)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let batch = self.db.batch()
                
                for document in documents {
                    batch.updateData(["isActive": false], forDocument: document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("❌ Error deactivating expired offers: \(error.localizedDescription)")
                    } else {
                        print("✅ Expired offers deactivated")
                    }
                }
            }
    }
}
