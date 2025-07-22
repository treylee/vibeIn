// Path: vibeIn/Services/Firebase/FirebaseBusinessService.swift

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

// MARK: - Simple Firebase Business Service
class FirebaseBusinessService: ObservableObject {
    static let shared = FirebaseBusinessService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let businessCollection = "businesses"
    
    @Published var businesses: [FirebaseBusiness] = []
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
        listener = db.collection(businessCollection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Firebase Listener Error: \(error.localizedDescription)")
                    return
                }
                
                let businesses = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirebaseBusiness.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self?.businesses = businesses
                    print("🔄 Firebase: Updated to \(businesses.count) businesses")
                }
            }
    }
    
    // MARK: - Create Business (Simplified)
    func createBusiness(
        name: String,
        address: String,
        placeID: String,
        category: String,
        offer: String,
        selectedImage: UIImage? = nil,
        selectedVideoURL: URL? = nil,
        googleReviews: [GPlaceDetails.Review] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        isLoading = true
        print("🚀 Creating business: \(name)")
        
        // For now, just save basic business data without media upload
        let businessData: [String: Any] = [
            "name": name,
            "address": address,
            "placeID": placeID,
            "category": category,
            "offer": offer,
            "createdAt": Timestamp(),
            "isVerified": true,
            "imageURL": "",
            "videoURL": "",
            "mediaType": "",
            "phone": "",
            "hours": "10AM - 10PM",
            "website": "",
            "rating": 4.5,
            "reviewCount": googleReviews.count,
            "latitude": 37.7749,
            "longitude": -122.4194
        ]
        
        db.collection(businessCollection).addDocument(data: businessData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating business: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Business saved to Firebase successfully!")
                    completion(.success("Business created successfully"))
                }
            }
        }
    }
    
    // MARK: - Get Business by ID
    func getBusinessById(businessId: String, completion: @escaping (FirebaseBusiness?) -> Void) {
        db.collection(businessCollection).document(businessId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching business: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let business = try? snapshot?.data(as: FirebaseBusiness.self)
            completion(business)
        }
    }
    
    // MARK: - Get Filtered Businesses
    func getFilteredBusinesses(searchText: String) -> [FirebaseBusiness] {
        if searchText.isEmpty {
            return businesses
        } else {
            return businesses.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
