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
    
    private init() {
        // Auto-login with stored user or create new user
        loadOrCreateCurrentUser()
    }
    
    // MARK: - User Management
    private func loadOrCreateCurrentUser() {
        // Check if user exists in UserDefaults
        if let storedUserId = UserDefaults.standard.string(forKey: "currentUserId") {
            loadUser(userId: storedUserId) { [weak self] user in
                if let user = user {
                    self?.currentUser = user
                } else {
                    // User not found, create new one
                    self?.createRandomUser()
                }
            }
        } else {
            // No stored user, create new one
            createRandomUser()
        }
    }
    
    func createRandomUser() {
        isLoading = true
        
        let randomNames = ["Alex", "Jordan", "Casey", "Riley", "Morgan", "Avery", "Quinn", "Blake", "Sage", "River"]
        let randomName = randomNames.randomElement() ?? "User"
        let userId = UUID().uuidString
        let email = "\(randomName.lowercased())\(Int.random(in: 100...999))@vibesIn.com"
        
        // Create FirebaseUser with proper initialization
        var newUser = FirebaseUser(
            userId: userId,
            userName: randomName,
            email: email
        )
        
        let userData: [String: Any] = [
            "userId": userId,
            "userName": randomName,
            "email": email,
            "userType": "business_owner",
            "createdAt": Timestamp(),
            "isActive": true,
            "hasCreatedBusiness": false,
            "businessId": NSNull()
        ]
        
        db.collection(usersCollection).addDocument(data: userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating user: \(error.localizedDescription)")
                } else {
                    print("✅ User created successfully: \(randomName)")
                    
                    // Store user ID for future sessions
                    UserDefaults.standard.set(userId, forKey: "currentUserId")
                    
                    // Set current user
                    self?.currentUser = newUser
                }
            }
        }
    }
    
    // MARK: - Load User
    private func loadUser(userId: String, completion: @escaping (FirebaseUser?) -> Void) {
        db.collection(usersCollection)
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error loading user: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                let firebaseUser = try? snapshot?.documents.first?.data(as: FirebaseUser.self)
                completion(firebaseUser)
            }
    }
    
    // MARK: - Update User After Business Creation
    func updateUserAfterBusinessCreation(businessId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = currentUser,
              let userDocId = currentUser.id else {
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
                    print("✅ User updated after business creation")
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Get User's Business
    func getUserBusiness(completion: @escaping (FirebaseBusiness?) -> Void) {
        guard let currentUser = currentUser,
              let businessId = currentUser.businessId else {
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
