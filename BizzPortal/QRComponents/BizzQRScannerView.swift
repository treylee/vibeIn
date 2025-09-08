// Path: vibeIn/BizzPortal/QRComponents/BizzQRScannerView.swift

import SwiftUI
import AVFoundation
import FirebaseFirestore

struct BizzQRScannerView: View {
    let businessId: String  // ADD THIS - Pass in the current business ID
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = true
    @State private var showSuccessView = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var redeemedInfluencerName = ""
    @State private var redeemedOfferDescription = ""
    @StateObject private var offerService = FirebaseOfferService.shared
    
    var body: some View {
        ZStack {
            // Scanner View
            QRScannerViewController(
                onCodeScanned: handleScannedCode,
                isScanning: $isScanning
            )
            .ignoresSafeArea()
            
            // Overlay
            if !showSuccessView {
                scannerOverlay
            }
            
            // Success View
            if showSuccessView {
                RedemptionSuccessView(
                    influencerName: redeemedInfluencerName,
                    offerDescription: redeemedOfferDescription
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .alert("Scan Error", isPresented: $showErrorAlert) {
            Button("Try Again") {
                isScanning = true
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var scannerOverlay: some View {
        VStack {
            // Top Bar
            HStack {
                // Business Name Badge
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.caption)
                    Text("Scanning for your offers")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.8))
                )
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.9), .white.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .blur(radius: 2)
                        )
                }
            }
            .padding()
            
            Spacer()
            
            // Scanning Frame
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 250, height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.2))
                    )
                
                // Corner markers
                ForEach(0..<4) { index in
                    CornerMarker()
                        .rotationEffect(.degrees(Double(index) * 90))
                        .offset(
                            x: index % 2 == 0 ? (index == 0 ? -125 : 125) : (index == 1 ? 125 : -125),
                            y: index < 2 ? -125 : 125
                        )
                }
                
                // Animated scan line
                if isScanning {
                    ScanLineView()
                }
            }
            
            // Instructions
            VStack(spacing: 8) {
                Text(isScanning ? "Scanning for QR Code..." : "Processing...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Point at influencer's QR code")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Only codes for YOUR offers will work")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
            )
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private func handleScannedCode(_ code: String) {
        // Stop scanning immediately
        isScanning = false
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("📱 Scanned QR Code")
        
        // Parse QR code
        guard let data = code.data(using: .utf8),
              let qrData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let redemptionId = qrData["redemptionId"] as? String,
              let offerId = qrData["offerId"] as? String else {
            alertMessage = "Invalid QR code format. Please ensure this is a valid vibeIN offer code."
            showErrorAlert = true
            return
        }
        
        print("📱 Scanned Redemption ID: \(redemptionId)")
        print("📱 For Offer ID: \(offerId)")
        print("📱 Current Business ID: \(businessId)")
        
        // First, verify this offer belongs to the current business
        verifyOfferOwnership(offerId: offerId, redemptionId: redemptionId)
    }
    
    private func verifyOfferOwnership(offerId: String, redemptionId: String) {
        // Get the offer to verify it belongs to this business
        let db = Firestore.firestore()
        db.collection("offers").document(offerId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error verifying offer: \(error)")
                self.alertMessage = "Could not verify offer. Please try again."
                self.showErrorAlert = true
                return
            }
            
            guard let offerData = snapshot?.data(),
                  let offerBusinessId = offerData["businessId"] as? String else {
                print("❌ Could not find offer data")
                self.alertMessage = "Invalid offer. Please try again."
                self.showErrorAlert = true
                return
            }
            
            print("🔍 Offer belongs to business: \(offerBusinessId)")
            print("🔍 Current business: \(self.businessId)")
            
            // Verify this offer belongs to the current business
            if offerBusinessId != self.businessId {
                print("❌ Offer belongs to different business!")
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                
                self.alertMessage = "This QR code is for a different business's offer."
                self.showErrorAlert = true
                return
            }
            
            print("✅ Offer verified - belongs to this business")
            
            // Now proceed with redemption
            self.redeemOffer(redemptionId: redemptionId)
        }
    }
    
    private func redeemOffer(redemptionId: String) {
        offerService.verifyAndRedeemOffer(redemptionId: redemptionId) { result in
            switch result {
            case .success(let data):
                // Success haptic
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                self.redeemedInfluencerName = data.influencerName
                self.redeemedOfferDescription = data.offerDescription
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.showSuccessView = true
                }
                
                // Auto dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss()
                }
                
            case .failure(let error):
                // Error haptic
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                
                self.alertMessage = error.localizedDescription
                self.showErrorAlert = true
            }
        }
    }
}

// MARK: - Corner Marker View
struct CornerMarker: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 3, height: 30)
            
            Spacer()
        }
        .frame(width: 30, height: 30)
        .overlay(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 3)
                
                Spacer()
            }
        )
    }
}

// MARK: - Animated Scan Line
struct ScanLineView: View {
    @State private var offset: CGFloat = -125
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.1), .pink.opacity(0.8), .purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 200, height: 2)
            .blur(radius: 1)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                    offset = 125
                }
            }
    }
}

// MARK: - QR Scanner UIKit Integration
struct QRScannerViewController: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerControllerDelegate {
        let parent: QRScannerViewController
        
        init(_ parent: QRScannerViewController) {
            self.parent = parent
        }
        
        func didScanCode(_ code: String) {
            parent.onCodeScanned(code)
        }
    }
}

// MARK: - UIKit QR Scanner Controller
protocol QRScannerControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.frame = view.layer.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer!)
            
        } catch {
            print("❌ Error setting up camera: \(error)")
        }
    }
    
    func startScanning() {
        hasScanned = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        hasScanned = true
        delegate?.didScanCode(stringValue)
    }
}

// MARK: - Redemption Success View
struct RedemptionSuccessView: View {
    let influencerName: String
    let offerDescription: String
    @State private var checkmarkScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Success Checkmark
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .mint.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(checkmarkScale)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkmarkScale)
                }
                
                // Success Text
                VStack(spacing: 16) {
                    Text("Offer Redeemed!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        Text("Influencer: \(influencerName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(offerDescription)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .opacity(textOpacity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                textOpacity = 1.0
            }
        }
    }
}
