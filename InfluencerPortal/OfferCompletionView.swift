// Path: vibeIn/InfluencerPortal/OfferCompletionView.swift

import SwiftUI
import FirebaseFirestore

struct OfferCompletionView: View {
    let offer: FirebaseOffer
    @State private var googleMapsURL = ""
    @State private var isExtracting = false
    @State private var extractionSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var reviewSubmitted = false
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Offer Completed!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(offer.businessName)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Final Step: Submit Your Review", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("Please submit your Google Maps review to complete this offer and receive your rewards.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Google Maps URL Input Section
                    if !extractionSuccess && !reviewSubmitted {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Submit Your Google Maps Review", systemImage: "link")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            VStack(spacing: 12) {
                                // URL Input Field
                                HStack(spacing: 8) {
                                    Image(systemName: "globe")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    
                                    TextField("Paste your Google Maps review URL here", text: $googleMapsURL)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .disabled(isExtracting || extractionSuccess)
                                    
                                    // Status indicator
                                    if extractionSuccess {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title2)
                                    } else if isExtracting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else if !googleMapsURL.isEmpty {
                                        Button(action: { googleMapsURL = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            extractionSuccess ? Color.green : Color.purple.opacity(0.3),
                                            lineWidth: extractionSuccess ? 2 : 1
                                        )
                                )
                                
                                // Helper text
                                Text("Example: https://maps.google.com/maps/contrib/...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Submit Button
                            Button(action: extractAndSaveReview) {
                                HStack {
                                    if isExtracting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                    }
                                    Text(isExtracting ? "Processing..." : "Submit Review")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: googleMapsURL.isEmpty || isExtracting ? [Color.gray] : [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(
                                    color: googleMapsURL.isEmpty ? Color.clear : Color.purple.opacity(0.3),
                                    radius: 10,
                                    y: 5
                                )
                            }
                            .disabled(googleMapsURL.isEmpty || isExtracting)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    }
                    
                    // Success State
                    if extractionSuccess || reviewSubmitted {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Review Successfully Submitted!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Thank you for completing this offer. Your review has been saved.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(16)
                    }
                    
                    // How to get review link instructions
                    if !extractionSuccess {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("How to get your review link", systemImage: "questionmark.circle")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InstructionRow(number: "1", text: "Open Google Maps app")
                                InstructionRow(number: "2", text: "Search for '\(offer.businessName)'")
                                InstructionRow(number: "3", text: "Write and post your review")
                                InstructionRow(number: "4", text: "Go to your profile → Reviews")
                                InstructionRow(number: "5", text: "Find this review and tap Share")
                                InstructionRow(number: "6", text: "Copy link and paste above")
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Extract and Save Review
    private func extractAndSaveReview() {
        guard let influencer = influencerService.currentInfluencer,
              let offerId = offer.id else {
            errorMessage = "Unable to get user information"
            showError = true
            return
        }
        
        // Validate URL format
        guard googleMapsURL.contains("google.com") || googleMapsURL.contains("goo.gl") || googleMapsURL.contains("maps.app") else {
            errorMessage = "Please enter a valid Google Maps review URL"
            showError = true
            return
        }
        
        isExtracting = true
        
        // API URL - CHANGE THIS TO YOUR ACTUAL API ENDPOINT
        let apiURL = "http://localhost:8000/extract"  // <- UPDATE THIS WITH YOUR ACTUAL API URL!
        
        guard let url = URL(string: apiURL) else {
            errorMessage = "Invalid API configuration"
            showError = true
            isExtracting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        // Request body
        let body: [String: Any] = [
            "url": googleMapsURL,
            "expected_business": "Quay Restaurant",
            "expected_reviewer": "Bogdan Zadorozhny",
            "strict_validation": true,
            "use_llm_fallback": false
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Make API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isExtracting = false
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isExtracting = false
                    self.errorMessage = "No data received from server"
                    self.showError = true
                }
                return
            }
            
            // Parse response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool {
                    
                    if success, let extractedData = json["data"] as? [String: Any] {
                        // Get extracted data with snake_case handling
                        let reviewText = extractedData["review_text"] as? String ?? ""
                        let rating = extractedData["rating"] as? Int ?? 5
                        let businessName = extractedData["business_name"] as? String ?? offer.businessName
                        
                        // Save to Firebase
                        self.saveReviewToFirebase(
                            reviewText: reviewText,
                            rating: rating,
                            offerId: offerId,
                            influencer: influencer
                        )
                    } else {
                        // Extraction failed
                        let errorMsg = json["error"] as? String ?? "Failed to extract review"
                        DispatchQueue.main.async {
                            self.isExtracting = false
                            self.errorMessage = errorMsg
                            self.showError = true
                        }
                    }
                } else {
                    throw NSError(domain: "ParseError", code: 1, userInfo: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExtracting = false
                    self.errorMessage = "Failed to process response"
                    self.showError = true
                }
            }
        }.resume()
    }
    
    // MARK: - Save to Firebase
    private func saveReviewToFirebase(reviewText: String, rating: Int, offerId: String, influencer: FirebaseInfluencer) {
        // Save review using existing service
        influencerService.submitReview(
            offerId: offerId,
            businessId: offer.businessId,
            businessName: offer.businessName,
            platform: "Google",
            rating: rating,
            reviewText: reviewText
        ) { result in
            DispatchQueue.main.async {
                self.isExtracting = false
                
                switch result {
                case .success:
                    // Update UI to show success
                    withAnimation {
                        self.extractionSuccess = true
                        self.reviewSubmitted = true
                    }
                    
                    // Update influencer stats
                    self.influencerService.updateInfluencerStats(completedOffer: true, newReview: true)
                    
                    // Mark offer as completed
                    self.offerService.checkRedemptionStatus(
                        offerId: offerId,
                        influencerId: influencer.influencerId
                    ) { _ in }
                    
                case .failure(let error):
                    self.errorMessage = "Failed to save review: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

// MARK: - Instruction Row Component
struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
