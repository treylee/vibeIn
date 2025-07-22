import Foundation

// MARK: - Restaurant Models
struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let offer: String
    let placeID: String
}

// MARK: - Sample Data
let sampleRestaurants = [
    Restaurant(
        name: "Arizmendi Bakery",
        category: "Bakery",
        offer: "Free Pastry for Google Review",
        placeID: "ChIJ7YbfORN-hYARoy9V0MUxYy4"
    ),
    Restaurant(
        name: "Blue Bottle Coffee",
        category: "Coffee Shop",
        offer: "Free Coffee for Instagram Post",
        placeID: "ChIJexample123"
    ),
    Restaurant(
        name: "Tartine Manufactory",
        category: "Restaurant",
        offer: "10% Off for Review",
        placeID: "ChIJexample456"
    )
]
