import Foundation
import CoreLocation

// MARK: - Google Places Models
struct GPlaceDetails: Codable {
    struct Review: Codable {
        struct Text: Codable { let text: String }
        struct Author: Codable { let displayName: String? }
        let text: Text
        let authorAttribution: Author?
        let rating: Int?
        let publishTime: String?
    }
    let formattedAddress: String?
    let reviews: [Review]?
    let location: Location?

    struct Location: Codable {
        let latitude: Double?
        let longitude: Double?
    }
}

// MARK: - Google Places Service
class GooglePlacesService {
    static let shared = GooglePlacesService()
    private let apiKey = "AIzaSyAAshRagNAxT1UbDIiCsR8m4ri4Z-eji5Q"
    
    private init() {}
    
    func fetchPlaceDetails(
        for placeID: String,
        completion: @escaping ([GPlaceDetails.Review], [String], String?, CLLocationCoordinate2D?) -> Void
    ) {
        let urlStr = "https://places.googleapis.com/v1/places/\(placeID)?fields=formattedAddress,reviews,rating,userRatingCount,location&key=\(apiKey)"

        guard let url = URL(string: urlStr) else {
            completion([], [], nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([], [], nil, nil)
                return
            }
            
            if let decoded = try? JSONDecoder().decode(GPlaceDetails.self, from: data) {
                let reviews = decoded.reviews ?? []
                let menu = self.generateSampleMenu()
                let coords = self.extractCoordinates(from: decoded.location)
                
                DispatchQueue.main.async {
                    completion(reviews, menu, decoded.formattedAddress, coords)
                }
            } else {
                DispatchQueue.main.async {
                    completion([], [], nil, nil)
                }
            }
        }.resume()
    }
    
    private func generateSampleMenu() -> [String] {
        return ["Sourdough Pizza", "Focaccia Bread", "Muffins", "Coffee"]
    }
    
    private func extractCoordinates(from location: GPlaceDetails.Location?) -> CLLocationCoordinate2D? {
        guard let location = location,
              let lat = location.latitude,
              let lon = location.longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// Legacy function for backward compatibility
func fetchLiveGoogleData(
    for placeID: String,
    completion: @escaping ([GPlaceDetails.Review], [String], String?, CLLocationCoordinate2D?) -> Void
) {
    GooglePlacesService.shared.fetchPlaceDetails(for: placeID, completion: completion)
}
