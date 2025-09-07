import SwiftUI
import CoreImage.CIFilterBuiltins

struct OfferQRCodeView: View {
    let offer: FirebaseOffer
    let influencer: FirebaseInfluencer
    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: UIImage?
    @State private var redemptionId: String = ""
    @State private var isGenerating = true
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
                
                // QR Code
                if let qrImage = qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                } else if isGenerating {
                    ProgressView("Generating QR Code...")
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
            generateNewQRCode()
            UIScreen.main.brightness = 1.0  // Max brightness
        }
        .onDisappear {
            UIScreen.main.brightness = 0.5  // Normal brightness
        }
    }
    
    private func generateNewQRCode() {
        redemptionId = UUID().uuidString
        
        offerService.createRedemptionRecord(
            redemptionId: redemptionId,
            offerId: offer.id ?? "",
            influencerId: influencer.influencerId,
            influencerName: influencer.userName,
            businessId: offer.businessId,
            businessName: offer.businessName
        ) { success in
            if success {
                let qrData = [
                    "redemptionId": redemptionId,
                    "offerId": offer.id ?? "",
                    "influencerId": influencer.influencerId,
                    "businessName": offer.businessName
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: qrData),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.qrImage = generateQRCodeImage(from: jsonString)
                }
            }
            isGenerating = false
        }
    }
    
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
