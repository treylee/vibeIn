// Path: vibeIn/Services/Firebase/FirebaseUserService.swift

import Foundation
import FirebaseFirestore

// MARK: - Firebase User Service
class FirebaseUserService: ObservableObject {
    static let shared = FirebaseUserService()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    @Published var currentUser: FirebaseUser?
    @Published var isLoading = false
    private var currentUserDocumentId: String?
    
    private init() {
        // Auto-login with stored user or create new user
        loadOrCreateCurrentUser()
    }
    
    // MARK: - User Management
    private func loadOrCreateCurrentUser() {
        // Always create a new user on app launch
        createRandomUser()
    }
    
    func createRandomUser() {
        isLoading = true
        
        let randomNames = ["Alex", "Jordan", "Casey", "Riley", "Morgan", "Avery", "Quinn", "Blake", "Sage", "River", "Taylor", "Cameron", "Drew", "Jamie", "Sam", "Charlie", "Skyler", "Dakota", "Reese", "Phoenix"]
        let randomName = randomNames.randomElement() ?? "User"
        let userId = UUID().uuidString
        let randomNumber = Int.random(in: 100...999)
        let email = "\(randomName.lowercased())\(randomNumber)@vibesIn.com"
        
        let userData: [String: Any] = [
            "userId": userId,
            "userName": "\(randomName) \(randomNumber)",
            "email": email,
            "userType": "business_owner",
            "createdAt": Timestamp(),
            "isActive": true,
            "hasCreatedBusiness": false,
            "businessId": NSNull()
        ]
        
        // Create document and get the reference
        db.collection(usersCollection).addDocument(data: userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating user: \(error.localizedDescription)")
                } else {
                    print("✅ New user created: \(randomName) \(randomNumber)")
                    print("📧 Email: \(email)")
                    
                    // After creating, immediately query to get the document with its ID
                    self?.db.collection(self?.usersCollection ?? "users")
                        .whereField("userId", isEqualTo: userId)
                        .limit(to: 1)
                        .getDocuments { snapshot, error in
                            if let document = snapshot?.documents.first {
                                self?.currentUserDocumentId = document.documentID
                                if let user = try? document.data(as: FirebaseUser.self) {
                                    self?.currentUser = user
                                    print("✅ User loaded with document ID: \(document.documentID)")
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Load User
    private func loadUser(userId: String, completion: @escaping (FirebaseUser?) -> Void) {
        db.collection(usersCollection)
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error loading user: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let firebaseUser = try? document.data(as: FirebaseUser.self)
                    // Store the document ID when loading a user
                    self?.currentUserDocumentId = document.documentID
                    completion(firebaseUser)
                } else {
                    completion(nil)
                }
            }
    }
    
    // MARK: - Update User After Business Creation
    func updateUserAfterBusinessCreation(businessId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = currentUser,
              let userDocId = currentUserDocumentId,
              !businessId.isEmpty else {
            print("❌ Error: Invalid user or business ID - currentUser: \(currentUser != nil), docId: \(currentUserDocumentId ?? "nil"), businessId: \(businessId)")
            completion(false)
            return
        }
        
        db.collection(usersCollection).document(userDocId).updateData([
            "hasCreatedBusiness": true,
            "businessId": businessId
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error updating user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ User updated with business ID: \(businessId)")
                    
                    // Update the local current user by reloading from Firebase
                    self?.loadUserByDocumentId(userDocId) { reloadedUser in
                        if let reloadedUser = reloadedUser {
                            self?.currentUser = reloadedUser
                            print("✅ User reloaded with updated business info")
                        }
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    // Helper method to load user by document ID
    private func loadUserByDocumentId(_ documentId: String, completion: @escaping (FirebaseUser?) -> Void) {
        db.collection(usersCollection).document(documentId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error loading user by ID: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let firebaseUser = try? snapshot?.data(as: FirebaseUser.self)
            completion(firebaseUser)
        }
    }
    
    // MARK: - Get User's Business
    func getUserBusiness(completion: @escaping (FirebaseBusiness?) -> Void) {
        guard let currentUser = currentUser,
              let businessId = currentUser.businessId,
              !businessId.isEmpty else {
            print("❌ No business ID found for current user")
            completion(nil)
            return
        }
        
        FirebaseBusinessService.shared.getBusinessById(businessId: businessId) { business in
            completion(business)
        }
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        currentUser = nil
        createRandomUser()
    }
}
