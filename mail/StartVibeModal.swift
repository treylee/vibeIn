// ===================================
// FILE 1: VibeMessageModel.swift
// Path: vibeIn/Models/Firebase/VibeMessageModel.swift
// ===================================

import Foundation
import FirebaseFirestore

// MARK: - Vibe Message Model
struct VibeMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let influencerId: String
    let influencerName: String
    let influencerEmail: String
    let businessId: String
    let businessName: String
    let offerId: String
    let message: String
    let sentAt: Timestamp
    let isRead: Bool
    let status: String // "pending", "responded", "accepted", "declined"
    
    init(
        influencerId: String,
        influencerName: String,
        influencerEmail: String,
        businessId: String,
        businessName: String,
        offerId: String,
        message: String
    ) {
        self.influencerId = influencerId
        self.influencerName = influencerName
        self.influencerEmail = influencerEmail
        self.businessId = businessId
        self.businessName = businessName
        self.offerId = offerId
        self.message = message
        self.sentAt = Timestamp()
        self.isRead = false
        self.status = "pending"
    }
}

// ===================================
// FILE 2: VibeMessageService.swift
// Path: vibeIn/Services/Firebase/VibeMessageService.swift
// ===================================

import Foundation
import FirebaseFirestore
import UIKit

class VibeMessageService: ObservableObject {
    static let shared = VibeMessageService()
    
    private let db = Firestore.firestore()
    private let messagesCollection = "vibe_messages"
    
    @Published var isLoading = false
    
    private init() {}
    
    // MARK: - Send Vibe Message (Original method)
    func sendVibeMessage(
        _ message: VibeMessage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        isLoading = true
        
        let messageData: [String: Any] = [
            "influencerId": message.influencerId,
            "influencerName": message.influencerName,
            "influencerEmail": message.influencerEmail,
            "businessId": message.businessId,
            "businessName": message.businessName,
            "offerId": message.offerId,
            "message": message.message,
            "sentAt": message.sentAt,
            "isRead": message.isRead,
            "status": message.status
        ]
        
        db.collection(messagesCollection).addDocument(data: messageData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error saving vibe message: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Vibe message saved to Firebase")
                    
                    // Send email notification
                    self?.sendEmailNotification(message: message)
                    
                    completion(.success("Vibe message sent successfully"))
                }
            }
        }
    }
    
    // MARK: - Send Vibe Message (Convenience method)
    func sendVibeMessage(
        from business: FirebaseBusiness,
        to influencer: FirebaseInfluencer,
        message: String,
        offerDescription: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Create a VibeMessage from the parameters
        let vibeMessage = VibeMessage(
            influencerId: influencer.influencerId,
            influencerName: influencer.userName,
            influencerEmail: influencer.email,
            businessId: business.id ?? "",
            businessName: business.name,
            offerId: "offer_\(Date().timeIntervalSince1970)", // Generate a unique offer ID
            message: message
        )
        
        // Call the original method
        sendVibeMessage(vibeMessage, completion: completion)
    }
    
    // MARK: - Send Email Notification
    private func sendEmailNotification(message: VibeMessage) {
        // Create email body
        let emailBody = """
        New Vibe Request from \(message.influencerName)!
        
        Business: \(message.businessName)
        Influencer: \(message.influencerName)
        Email: \(message.influencerEmail)
        
        Message:
        \(message.message)
        
        ---
        This message was sent through the vibeIN app.
        """
        
        // URL encode the email components
        let subject = "New Vibe Request: \(message.influencerName) x \(message.businessName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create mailto URL
        let mailtoString = "mailto:trieveon.lee@gmail.com?subject=\(subject)&body=\(body)"
        
        if let mailtoUrl = URL(string: mailtoString) {
            if UIApplication.shared.canOpenURL(mailtoUrl) {
                UIApplication.shared.open(mailtoUrl)
            } else {
                print("❌ Cannot open mail app")
            }
        }
    }
    
    // MARK: - Get Messages for Business
    func getMessagesForBusiness(businessId: String, completion: @escaping ([VibeMessage]) -> Void) {
        db.collection(messagesCollection)
            .whereField("businessId", isEqualTo: businessId)
            .order(by: "sentAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching messages: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let messages = snapshot?.documents.compactMap { document in
                    try? document.data(as: VibeMessage.self)
                } ?? []
                
                completion(messages)
            }
    }
}

// ===================================
// FILE 3: StartVibeModal.swift
// Path: vibeIn/InfluencerPortal/Components/StartVibeModal.swift
// ===================================

import SwiftUI
import FirebaseFirestore

struct StartVibeModal: View {
    let influencer: FirebaseInfluencer
    let selectedOffer: FirebaseOffer?
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @StateObject private var messageService = VibeMessageService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.orange.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 20)
                                
                                Image(systemName: "envelope.circle.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            Text("Start a Vibe")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Send a message to the business owner")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        
                        // Business Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "building.2.crop.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedOffer?.businessName ?? "General Inquiry")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    if let offer = selectedOffer {
                                        Text("Offer: \(offer.description)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    } else {
                                        Text("Send a general collaboration inquiry")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Message Input
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Your Message", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextEditor(text: $message)
                                    .frame(minHeight: 150, maxHeight: 300)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: Color.purple.opacity(0.1), radius: 5, y: 2)
                                
                                Text("\(message.count)/500 characters")
                                    .font(.caption)
                                    .foregroundColor(message.count > 500 ? .red : .gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Send Button
                        Button(action: sendMessage) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSubmitting ? "Sending..." : "Send Vibe")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors:
                                        message.isEmpty || message.count > 500 ?
                                        [Color.gray] : [.pink, .purple]
                                    ),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.pink.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(message.isEmpty || message.count > 500 || isSubmitting)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .alert("Vibe Sent! 🎉", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func sendMessage() {
        print("📧 Sending vibe message...")
        
        // Get the current business from the business service
        guard let currentBusiness = getCurrentBusinessFromService() else {
            print("❌ No business found for current user")
            self.alertMessage = "Error: No business profile found. Please create a business first."
            self.showErrorAlert = true
            return
        }
        
        let businessId = currentBusiness.id ?? ""
        let businessName = currentBusiness.name
        let offerId = selectedOffer?.id ?? "direct_message_\(Date().timeIntervalSince1970)"
        
        isSubmitting = true
        
        let vibeMessage = VibeMessage(
            influencerId: influencer.influencerId,
            influencerName: influencer.userName,
            influencerEmail: influencer.email,
            businessId: businessId,
            businessName: businessName,
            offerId: offerId,
            message: message
        )
        
        messageService.sendVibeMessage(vibeMessage) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                switch result {
                case .success(_):
                    print("✅ Vibe message sent successfully")
                    self.alertMessage = "Your message has been sent! The business owner will receive it via email at trieveon.lee@gmail.com"
                    self.showSuccessAlert = true
                    
                case .failure(let error):
                    print("❌ Error sending vibe: \(error.localizedDescription)")
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func getCurrentBusinessFromService() -> FirebaseBusiness? {
        // Try to get the current user's business
        if let currentUser = FirebaseUserService.shared.currentUser,
           let businessId = currentUser.businessId,
           !businessId.isEmpty {
            // This is a synchronous check - in a real app, you might want to load this asynchronously
            return FirebaseBusinessService.shared.businesses.first { $0.id == businessId }
        }
        return nil
    }
}
