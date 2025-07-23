// Path: vibeIn/Services/Firebase/FirebaseInfluencerService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Swift

class FirebaseInfluencerService: ObservableObject {
    static let shared = FirebaseInfluencerService()
    
    private let db = Firestore.firestore()
    private let influencersCollection = "influencers"
    private let reviewsCollection = "influencer_reviews"
    
    @Published var currentInfluencer: FirebaseInfluencer?
    @Published var isLoading = false
    private var currentInfluencerDocumentId: String?
    
    private init() {
        // Auto-create random influencer on init
        createRandomInfluencer()
    }
    
    // MARK: - Create Random Influencer
    func createRandomInfluencer() {
        isLoading = true
        
        // Random name generation
        let firstNames = ["Alex", "Sam", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Avery", "Blake", "Drew", "Jamie", "Quinn", "Sage", "Sky", "River"]
        let lastNames = ["Smith", "Johnson", "Chen", "Garcia", "Kim", "Patel", "Williams", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas"]
        
        let firstName = firstNames.randomElement() ?? "Influencer"
        let lastName = lastNames.randomElement() ?? "User"
        let randomNum = Int.random(in: 100...999)
        
        let userName = "\(firstName)\(lastName)\(randomNum)"
        let influencerId = UUID().uuidString
        let email = "\(userName.lowercased())@vibesIn.com"
        
        // Generate random social stats
        let instagramFollowers = generateFollowers()
        let tiktokFollowers = generateFollowers()
        let youtubeSubscribers = generateFollowers()
        let totalReach = instagramFollowers + tiktokFollowers + youtubeSubscribers
        
        // Generate engagement metrics based on follower count
        let engagementRate = Double.random(in: 2.5...8.5)
        let avgLikes = Int(Double(totalReach) * (engagementRate / 100) * 0.8)
        let avgComments = Int(Double(avgLikes) * 0.1)
        let avgViews = totalReach * Int.random(in: 2...5)
        
        // Random categories and content types
        let allCategories = ["Food & Dining", "Fashion", "Travel", "Lifestyle", "Beauty", "Fitness", "Tech", "Entertainment", "Home & Design", "Wellness"]
        let allContentTypes = ["Photos", "Reels", "Stories", "Videos", "Live Streams", "Blogs", "TikToks", "Shorts"]
        
        let categories = Array(allCategories.shuffled().prefix(Int.random(in: 2...4)))
        let contentTypes = Array(allContentTypes.shuffled().prefix(Int.random(in: 2...3)))
        
        // Random location (major US cities)
        let cities = [
            ("San Francisco", "CA", 37.7749, -122.4194),
            ("Los Angeles", "CA", 34.0522, -118.2437),
            ("New York", "NY", 40.7128, -74.0060),
            ("Chicago", "IL", 41.8781, -87.6298),
            ("Miami", "FL", 25.7617, -80.1918),
            ("Austin", "TX", 30.2672, -97.7431),
            ("Seattle", "WA", 47.6062, -122.3321),
            ("Denver", "CO", 39.7392, -104.9903),
            ("Phoenix", "AZ", 33.4484, -112.0740),
            ("Portland", "OR", 45.5152, -122.6784)
        ]
        
        let location = cities.randomElement() ?? cities[0]
        
        // Create influencer data
        let influencerData: [String: Any] = [
            "influencerId": influencerId,
            "userName": userName,
            "email": email,
            "profileImageURL": "https://i.pravatar.cc/300?u=\(userName)",
            "instagramFollowers": instagramFollowers,
            "tiktokFollowers": tiktokFollowers,
            "youtubeSubscribers": youtubeSubscribers,
            "totalReach": totalReach,
            "averageEngagementRate": engagementRate,
            "averageLikes": avgLikes,
            "averageComments": avgComments,
            "averageViews": avgViews,
            "totalReviews": Int.random(in: 5...50),
            "completedOffers": Int.random(in: 3...30),
            "joinedOffers": Int.random(in: 5...40),
            "reviewPlatforms": ["Google", "Instagram", "TikTok"],
            "categories": categories,
            "contentTypes": contentTypes,
            "city": location.0,
            "state": location.1,
            "latitude": location.2,
            "longitude": location.3,
            "joinedDate": Timestamp(),
            "isVerified": totalReach > 10000,
            "isActive": true,
            "lastActive": Timestamp()
        ]
        
        db.collection(influencersCollection).addDocument(data: influencerData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error creating influencer: \(error.localizedDescription)")
                } else {
                    print("✅ New influencer created: \(userName)")
                    print("📱 Followers: Instagram \(instagramFollowers), TikTok \(tiktokFollowers), YouTube \(youtubeSubscribers)")
                    print("📊 Engagement Rate: \(engagementRate)%")
                    
                    // Load the created influencer
                    self?.loadInfluencerByEmail(email: email)
                }
            }
        }
    }
    
    // MARK: - Load Influencer
    private func loadInfluencerByEmail(email: String) {
        db.collection(influencersCollection)
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error loading influencer: \(error.localizedDescription)")
                    return
                }
                
                if let document = snapshot?.documents.first {
                    do {
                        let influencer = try document.data(as: FirebaseInfluencer.self)
                        self?.currentInfluencer = influencer
                        self?.currentInfluencerDocumentId = document.documentID
                        print("✅ Influencer loaded: \(influencer.userName)")
                    } catch {
                        print("❌ Error parsing influencer: \(error)")
                    }
                }
            }
    }
    
    // MARK: - Get Influencer Reviews
    func getInfluencerReviews(influencerId: String, completion: @escaping ([InfluencerReview]) -> Void) {
        db.collection(reviewsCollection)
            .whereField("influencerId", isEqualTo: influencerId)
            .order(by: "reviewDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching reviews: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let reviews = snapshot?.documents.compactMap { document in
                    try? document.data(as: InfluencerReview.self)
                } ?? []
                
                completion(reviews)
            }
    }
    
    // MARK: - Helper Functions
    private func generateFollowers() -> Int {
        let tier = Int.random(in: 1...100)
        
        switch tier {
        case 1...60: // 60% micro-influencers
            return Int.random(in: 1_000...10_000)
        case 61...85: // 25% mid-tier
            return Int.random(in: 10_000...100_000)
        case 86...95: // 10% macro-influencers
            return Int.random(in: 100_000...500_000)
        default: // 5% mega-influencers
            return Int.random(in: 500_000...2_000_000)
        }
    }
    
    // MARK: - Update Influencer Stats
    func updateInfluencerStats(completedOffer: Bool = false, newReview: Bool = false) {
        guard let docId = currentInfluencerDocumentId else { return }
        
        var updates: [String: Any] = ["lastActive": Timestamp()]
        
        if completedOffer {
            updates["completedOffers"] = FieldValue.increment(Int64(1))
            updates["joinedOffers"] = FieldValue.increment(Int64(1))
        }
        
        if newReview {
            updates["totalReviews"] = FieldValue.increment(Int64(1))
        }
        
        db.collection(influencersCollection).document(docId).updateData(updates) { error in
            if let error = error {
                print("❌ Error updating influencer stats: \(error)")
            } else {
                print("✅ Influencer stats updated")
            }
        }
    }
}
