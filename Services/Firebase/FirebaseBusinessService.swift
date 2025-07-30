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
    
    // MARK: - Create Business with Category Data (NEW)
    func createBusinessWithCategoryData(
        name: String,
        address: String,
        placeID: String,
        category: String,
        offer: String,
        selectedImage: UIImage? = nil,
        selectedVideoURL: URL? = nil,
        googleReviews: [GPlaceDetails.Review] = [],
        categoryData: CategoryData? = nil,
        completion: @escaping (Result<(String, String), Error>) -> Void
    ) {
        isLoading = true
        print("🚀 Creating business with categories: \(name)")
        
        // Build business data including category information
        var businessData: [String: Any] = [
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
        
        // Add category data if provided
        if let categoryData = categoryData {
            businessData["mainCategory"] = categoryData.mainCategory
            businessData["subtypes"] = categoryData.subtypes
            businessData["customTags"] = categoryData.customTags
            
            print("📂 Adding category data:")
            print("   - Main Category: \(categoryData.mainCategory)")
            print("   - Subtypes: \(categoryData.subtypes)")
            print("   - Custom Tags: \(categoryData.customTags)")
        }
        
        // Use addDocument which returns the document reference
        var docRef: DocumentReference? = nil
        docRef = db.collection(businessCollection).addDocument(data: businessData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating business: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let documentId = docRef?.documentID {
                    print("✅ Business saved to Firebase with ID: \(documentId)")
                    print("✅ Category data saved successfully")
                    completion(.success(("Business created successfully!", documentId)))
                } else {
                    print("❌ Error: Could not get document ID")
                    completion(.failure(NSError(domain: "FirebaseBusinessService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get document ID"])))
                }
            }
        }
    }
    
    // MARK: - Create Business (Updated to return business ID)
    func createBusinessWithId(
        name: String,
        address: String,
        placeID: String,
        category: String,
        offer: String,
        selectedImage: UIImage? = nil,
        selectedVideoURL: URL? = nil,
        googleReviews: [GPlaceDetails.Review] = [],
        completion: @escaping (Result<(String, String), Error>) -> Void // Returns (message, businessId)
    ) {
        // Call the new method without category data for backward compatibility
        createBusinessWithCategoryData(
            name: name,
            address: address,
            placeID: placeID,
            category: category,
            offer: offer,
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            googleReviews: googleReviews,
            categoryData: nil,
            completion: completion
        )
    }
    
    // Keep the old method for backward compatibility
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
        createBusinessWithId(
            name: name,
            address: address,
            placeID: placeID,
            category: category,
            offer: offer,
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            googleReviews: googleReviews
        ) { result in
            switch result {
            case .success(let (message, _)):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Business by ID
    func getBusinessById(businessId: String, completion: @escaping (FirebaseBusiness?) -> Void) {
        guard !businessId.isEmpty else {
            print("❌ Error: Empty business ID provided")
            completion(nil)
            return
        }
        
        db.collection(businessCollection).document(businessId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching business: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let business = try? snapshot?.data(as: FirebaseBusiness.self)
            
            // Debug print the retrieved data
            if let business = business {
                print("✅ Retrieved business: \(business.name)")
                print("   - Main Category: \(business.mainCategory ?? "None")")
                print("   - Subtypes: \(business.subtypes ?? [])")
                print("   - Custom Tags: \(business.customTags ?? [])")
            }
            
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
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.mainCategory?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.subtypes?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false) ||
                ($0.customTags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }
    }
    
    // MARK: - Update Business Categories
    func updateBusinessCategories(
        businessId: String,
        mainCategory: String,
        subtypes: [String],
        customTags: [String],
        completion: @escaping (Bool) -> Void
    ) {
        guard !businessId.isEmpty else {
            print("❌ Error: Empty business ID provided")
            completion(false)
            return
        }
        
        let updateData: [String: Any] = [
            "mainCategory": mainCategory,
            "subtypes": subtypes,
            "customTags": customTags
        ]
        
        db.collection(businessCollection).document(businessId).updateData(updateData) { error in
            if let error = error {
                print("❌ Error updating business categories: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Business categories updated successfully")
                completion(true)
            }
        }
    }
}
