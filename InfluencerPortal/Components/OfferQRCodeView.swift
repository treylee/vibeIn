// Path: vibeIn/InfluencerPortal/Components/OfferQRCodeView.swift

import SwiftUI
import CoreImage.CIFilterBuiltins

struct OfferQRCodeView: View {
    let offer: FirebaseOffer
    let influencer: FirebaseInfluencer
    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: UIImage?
    @State private var redemptionId: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var offerService = FirebaseOfferService.shared
    
    var body: some View {
        ZStack {
            // Bright white background for scanning
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Business Name
                Text(offer.businessName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // Offer Description
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // QR Code or Loading/Error State
                if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Unable to Generate QR Code")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                } else if let qrImage = qrImage {
                    VStack(spacing: 8) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        
                        // QR Code ID for debugging (can be removed in production)
                        Text("ID: \(String(redemptionId.prefix(8)))...")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                } else if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading QR Code...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 250, height: 250)
                }
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Show this code to the cashier")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("This code can only be used once")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Valid until: \(offer.formattedValidUntil)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !redemptionId.isEmpty {
                        Text("✓ Your spot is reserved")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                
                // Brightness reminder
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("Turn up screen brightness for best scanning")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
            }
        }
        .onAppear {
            loadExistingRedemption()
            UIScreen.main.brightness = 1.0  // Max brightness
        }
        .onDisappear {
            UIScreen.main.brightness = 0.5  // Normal brightness
        }
    }
    
    // MARK: - Load Existing Redemption (FIXED)
    private func loadExistingRedemption() {
        print("🎯 Loading QR for offer: \(offer.id ?? "nil")")
        
        guard let offerId = offer.id else {
            print("❌ No offer ID!")
            errorMessage = "Invalid offer. Please try again."
            isLoading = false
            return
        }
        
        // Get the redemption ID from the participation record
        offerService.getRedemptionId(
            offerId: offerId,
            influencerId: influencer.influencerId
        ) { redemptionId in
            DispatchQueue.main.async {
                if let redemptionId = redemptionId {
                    // Use the existing redemption ID
                    self.redemptionId = redemptionId
                    print("✅ Found existing redemption ID: \(redemptionId)")
                    self.generateQRFromRedemptionId(redemptionId)
                } else {
                    // No redemption found - they haven't joined this offer
                    print("❌ No redemption found - influencer hasn't joined this offer")
                    self.errorMessage = "You haven't joined this offer yet. Please join the offer first."
                }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Generate QR from Redemption ID
    private func generateQRFromRedemptionId(_ redemptionId: String) {
        let qrData = [
            "redemptionId": redemptionId,
            "offerId": offer.id ?? "",
            "influencerId": influencer.influencerId,
            "businessName": offer.businessName
        ]
        
        print("📱 Generating QR with data:")
        print("   - redemptionId: \(redemptionId)")
        print("   - offerId: \(offer.id ?? "")")
        print("   - businessName: \(offer.businessName)")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: qrData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.qrImage = generateQRCodeImage(from: jsonString)
            
            if self.qrImage == nil {
                self.errorMessage = "Failed to generate QR code. Please try again."
            }
        } else {
            self.errorMessage = "Failed to create QR data. Please try again."
        }
    }
    
    // MARK: - Generate QR Code Image
    private func generateQRCodeImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
