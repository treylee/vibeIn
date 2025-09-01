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
    
    // MARK: - Create Business with Enhanced Data (UPDATED TO HANDLE MENU ITEM IMAGES)
    func createBusinessWithEnhancedData(
        name: String,
        address: String,
        placeID: String,
        category: String,
        offer: String,
        selectedImage: UIImage? = nil,
        selectedVideoURL: URL? = nil,
        googleReviews: [GPlaceDetails.Review] = [],
        categoryData: CategoryData? = nil,
        menuItems: [MenuItem],  // Changed from [[String: String]] to [MenuItem]
        businessHours: String,
        phoneNumber: String,
        missionStatement: String,
        completion: @escaping (Result<(String, String), Error>) -> Void
    ) {
        isLoading = true
        print("🚀 Creating enhanced business: \(name)")
        
        // First, upload all menu item images
        var menuItemsData: [[String: String]] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, item) in menuItems.enumerated() {
            dispatchGroup.enter()
            
            var itemData: [String: String] = [
                "name": item.name,
                "price": item.price,
                "description": item.description
            ]
            
            // Upload menu item image if it exists
            if let image = item.image {
                uploadMenuItemImage(
                    businessName: name,
                    itemIndex: index,
                    image: image
                ) { imageUrl in
                    if let url = imageUrl {
                        itemData["imageURL"] = url
                    }
                    menuItemsData.append(itemData)
                    dispatchGroup.leave()
                }
            } else {
                menuItemsData.append(itemData)
                dispatchGroup.leave()
            }
        }
        
        // Wait for all menu item images to upload, then create the business
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Build business data including all enhanced fields
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
                "phone": phoneNumber,
                "hours": businessHours,
                "website": "",
                "rating": self?.calculateAverageRating(from: googleReviews) ?? 0.0,
                "reviewCount": googleReviews.count,
                "latitude": 37.7749,
                "longitude": -122.4194,
                "missionStatement": missionStatement,
                "menuItems": menuItemsData  // Now includes image URLs
            ]
            
            // Add category data if provided
            if let categoryData = categoryData {
                businessData["mainCategory"] = categoryData.mainCategory
                let allSubtypes = categoryData.subtypes + categoryData.customTags
                businessData["subtypes"] = allSubtypes
                businessData["customTags"] = []
                
                print("📂 Adding category data:")
                print("   - Main Category: \(categoryData.mainCategory)")
                print("   - All Subtypes: \(allSubtypes)")
            }
            
            print("🍽 Adding \(menuItemsData.count) menu items with images")
            
            // Create the document
            var docRef: DocumentReference? = nil
            docRef = self?.db.collection(self?.businessCollection ?? "businesses").addDocument(data: businessData) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        print("❌ Error creating business: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else if let documentId = docRef?.documentID {
                    // Upload main business image if provided
                    if let mainImage = selectedImage {
                        self?.uploadBusinessImages(
                            businessId: documentId,
                            images: [("main", mainImage)]
                        ) { imageUrls in
                            // Update document with image URL
                            var updateData: [String: Any] = [:]
                            
                            if let mainUrl = imageUrls["main"] {
                                updateData["imageURL"] = mainUrl
                                updateData["mediaType"] = "image"
                            }
                            
                            if !updateData.isEmpty {
                                docRef?.updateData(updateData) { _ in
                                    DispatchQueue.main.async {
                                        self?.isLoading = false
                                        print("✅ Business created with images: \(documentId)")
                                        completion(.success(("Business created successfully!", documentId)))
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self?.isLoading = false
                                    completion(.success(("Business created successfully!", documentId)))
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            print("✅ Business created without main image: \(documentId)")
                            completion(.success(("Business created successfully!", documentId)))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        print("❌ Error: Could not get document ID")
                        completion(.failure(NSError(
                            domain: "FirebaseBusinessService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Could not get document ID"]
                        )))
                    }
                }
            }
        }
    }
    
    // MARK: - Upload Menu Item Image (NEW METHOD)
    private func uploadMenuItemImage(
        businessName: String,
        itemIndex: Int,
        image: UIImage,
        completion: @escaping (String?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }
        
        let imageName = "\(businessName.replacingOccurrences(of: " ", with: "_"))_menu_item_\(itemIndex)_\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("menu_items/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("❌ Error uploading menu item image: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let url = url {
                        print("✅ Uploaded menu item image: \(url.absoluteString)")
                        completion(url.absoluteString)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Upload Business Images
    private func uploadBusinessImages(
        businessId: String,
        images: [(type: String, image: UIImage)],
        completion: @escaping ([String: String]) -> Void
    ) {
        var uploadedUrls: [String: String] = [:]
        let dispatchGroup = DispatchGroup()
        
        for (type, image) in images {
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                dispatchGroup.leave()
                continue
            }
            
            let imageName = "\(businessId)_\(type)_\(UUID().uuidString).jpg"
            let storageRef = storage.reference().child("business_images/\(businessId)/\(imageName)")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { _, error in
                if let error = error {
                    print("❌ Error uploading \(type) image: \(error.localizedDescription)")
                    dispatchGroup.leave()
                } else {
                    storageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedUrls[type] = url.absoluteString
                            print("✅ Uploaded \(type) image: \(url.absoluteString)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(uploadedUrls)
        }
    }
    
    // MARK: - Update Menu Items with Images (NEW METHOD)
    func updateMenuItemsWithImages(
        businessId: String,
        menuItems: [MenuItem],
        completion: @escaping (Bool) -> Void
    ) {
        guard !businessId.isEmpty else {
            print("❌ Error: Empty business ID provided")
            completion(false)
            return
        }
        
        // Convert MenuItem objects to data format with image URLs
        var menuItemsData: [[String: String]] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, item) in menuItems.enumerated() {
            dispatchGroup.enter()
            
            var itemData: [String: String] = [
                "name": item.name,
                "price": item.price,
                "description": item.description
            ]
            
            // Upload new image if present
            if let image = item.image {
                uploadMenuItemImage(
                    businessName: businessId,
                    itemIndex: index,
                    image: image
                ) { imageUrl in
                    if let url = imageUrl {
                        itemData["imageURL"] = url
                    }
                    menuItemsData.append(itemData)
                    dispatchGroup.leave()
                }
            } else {
                menuItemsData.append(itemData)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            let updateData: [String: Any] = [
                "menuItems": menuItemsData
            ]
            
            self?.db.collection(self?.businessCollection ?? "businesses")
                .document(businessId)
                .updateData(updateData) { error in
                    if let error = error {
                        print("❌ Error updating menu items: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("✅ Menu items with images updated successfully")
                        completion(true)
                    }
                }
        }
    }
    
    // MARK: - Update Business Details
    func updateBusinessDetails(
        businessId: String,
        hours: String,
        phone: String,
        missionStatement: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard !businessId.isEmpty else {
            print("❌ Error: Empty business ID provided")
            completion(false)
            return
        }
        
        let updateData: [String: Any] = [
            "hours": hours,
            "phone": phone,
            "missionStatement": missionStatement
        ]
        
        db.collection(businessCollection).document(businessId).updateData(updateData) { error in
            if let error = error {
                print("❌ Error updating business details: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Business details updated successfully")
                completion(true)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calculateAverageRating(from reviews: [GPlaceDetails.Review]) -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        
        let totalRating = reviews.compactMap { $0.rating }.reduce(0, +)
        let validReviewCount = reviews.compactMap { $0.rating }.count
        
        guard validReviewCount > 0 else { return 0.0 }
        
        return Double(totalRating) / Double(validReviewCount)
    }
    
    // MARK: - Create Business with Category Data (Existing method for backward compatibility)
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
        // Call the enhanced method with default values for new fields
        createBusinessWithEnhancedData(
            name: name,
            address: address,
            placeID: placeID,
            category: category,
            offer: offer,
            selectedImage: selectedImage,
            selectedVideoURL: selectedVideoURL,
            googleReviews: googleReviews,
            categoryData: categoryData,
            menuItems: [],
            businessHours: "10AM - 10PM",
            phoneNumber: "",
            missionStatement: "",
            completion: completion
        )
    }
    
    // MARK: - Create Business with ID (Existing method for backward compatibility)
    func createBusinessWithId(
        name: String,
        address: String,
        placeID: String,
        category: String,
        offer: String,
        selectedImage: UIImage? = nil,
        selectedVideoURL: URL? = nil,
        googleReviews: [GPlaceDetails.Review] = [],
        completion: @escaping (Result<(String, String), Error>) -> Void
    ) {
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
    
    // MARK: - Create Business (Original method for backward compatibility)
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
            
            if let business = business {
                print("✅ Retrieved business: \(business.name)")
                print("   - Main Category: \(business.mainCategory ?? "None")")
                print("   - All Subtypes: \(business.subtypes ?? [])")
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
                ($0.subtypes?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
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
        
        let allSubtypes = subtypes
        
        let updateData: [String: Any] = [
            "mainCategory": mainCategory,
            "subtypes": allSubtypes,
            "customTags": []
        ]
        
        db.collection(businessCollection).document(businessId).updateData(updateData) { error in
            if let error = error {
                print("❌ Error updating business categories: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Business categories updated successfully")
                print("   - Main Category: \(mainCategory)")
                print("   - All Subtypes: \(allSubtypes)")
                completion(true)
            }
        }
    }
}
