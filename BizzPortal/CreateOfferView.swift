// Path: vibeIn/BizzPortal/CreateOfferView.swift

import SwiftUI

struct CreateOfferView: View {
    let business: FirebaseBusiness
    @State private var offerData = OfferData()
    @State private var navigateToPreview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Updated background to match portal view style
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            CreateOfferContent(
                business: business,
                offerData: $offerData,
                navigateToPreview: $navigateToPreview
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // Show default back button
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Offer")
                    .font(.headline)
                    .foregroundColor(.primary) // Use primary color instead of white
            }
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            OfferPreviewView(business: business, offerData: offerData)
        }
    }
}

// MARK: - Offer Data Model
struct OfferData {
    var description: String = ""
    var platforms: Set<OfferPlatform> = []
    var date: Date?
    var time: Date?
    var maxParticipants: Int = 100 // Default to 100
    
    var combinedDateTime: Date {
        let calendar = Calendar.current
        
        guard let date = date, let time = time else {
            return Date() // Return current date if not set
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? Date()
    }
    
    var isValid: Bool {
        !description.isEmpty &&
        !platforms.isEmpty &&
        date != nil &&
        time != nil &&
        maxParticipants > 0
    }
}

// MARK: - Offer Platform
enum OfferPlatform: String, CaseIterable, Identifiable {
    case google = "Google"
    case appleMaps = "Apple Maps"
    case socialMedia = "Social Media"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .google: return "globe"
        case .appleMaps: return "applelogo"
        case .socialMedia: return "camera.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .google: return .blue
        case .appleMaps: return .black
        case .socialMedia: return .purple
        }
    }
}

// MARK: - Create Offer Content
struct CreateOfferContent: View {
    let business: FirebaseBusiness
    @Binding var offerData: OfferData
    @Binding var navigateToPreview: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                CreateOfferHeader()
                    .padding(.top, 20)
                
                OfferFormSection(offerData: $offerData)
                
                PreviewButton(
                    isEnabled: offerData.isValid,
                    action: { navigateToPreview = true }
                )
            }
        }
    }
}

struct CreateOfferHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Create Your Offer")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Attract influencers with a special offer")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct OfferFormSection: View {
    @Binding var offerData: OfferData
    
    var body: some View {
        VStack(spacing: 20) {
            OfferDescriptionField(description: $offerData.description)
            PlatformSelectionSection(selectedPlatforms: $offerData.platforms)
            QuantitySelectionSection(maxParticipants: $offerData.maxParticipants)
            DateSelectionSection(date: $offerData.date)
            TimeSelectionSection(time: $offerData.time)
        }
        .padding(.horizontal)
    }
}

struct OfferDescriptionField: View {
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("What's your offer?", systemImage: "gift")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $description)
                .frame(height: 100)
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Text("e.g., Free appetizer with any entree purchase")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PlatformSelectionSection: View {
    @Binding var selectedPlatforms: Set<OfferPlatform>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Where should they leave reviews?", systemImage: "app.badge")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(OfferPlatform.allCases) { platform in
                    PlatformToggle(
                        platform: platform,
                        isSelected: selectedPlatforms.contains(platform),
                        action: {
                            if selectedPlatforms.contains(platform) {
                                selectedPlatforms.remove(platform)
                            } else {
                                selectedPlatforms.insert(platform)
                            }
                        }
                    )
                }
            }
        }
    }
}

struct PlatformToggle: View {
    let platform: OfferPlatform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: platform.icon)
                    .foregroundColor(isSelected ? platform.color : .gray)
                    .frame(width: 30)
                
                Text(platform.rawValue)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? platform.color : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? platform.color.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Quantity Selection Section
struct QuantitySelectionSection: View {
    @Binding var maxParticipants: Int
    let quantities = [10, 25, 50, 100, 200, 500]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Maximum participants", systemImage: "person.3.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("How many influencers can claim this offer?")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(quantities, id: \.self) { quantity in
                    Button(action: {
                        maxParticipants = quantity
                    }) {
                        Text("\(quantity)")
                            .font(.headline)
                            .foregroundColor(maxParticipants == quantity ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(maxParticipants == quantity ?
                                          Color.purple :
                                          Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(maxParticipants == quantity ?
                                           Color.purple :
                                           Color.gray.opacity(0.2), lineWidth: 2)
                            )
                    }
                }
            }
            
            // Custom quantity input
            HStack {
                Text("Custom:")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                TextField("Enter amount", value: $maxParticipants, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
                    .keyboardType(.numberPad)
            }
            .padding(.top, 8)
        }
    }
}

struct DateSelectionSection: View {
    @Binding var date: Date?
    @State private var showDatePicker = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Valid until date *", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: { showDatePicker.toggle() }) {
                HStack {
                    Text(date != nil ? dateFormatter.string(from: date!) : "Select date")
                        .foregroundColor(date != nil ? .primary : .gray)
                    Spacer()
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(date != nil ? .purple : .gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(date != nil ? Color.purple.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if date == nil {
                Text("Required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if showDatePicker {
                DatePicker(
                    "Select Date",
                    selection: Binding(
                        get: { date ?? Date() },
                        set: { date = $0 }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
}

struct TimeSelectionSection: View {
    @Binding var time: Date?
    @State private var showTimePicker = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Valid until time *", systemImage: "clock")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: { showTimePicker.toggle() }) {
                HStack {
                    Text(time != nil ? timeFormatter.string(from: time!) : "Select time")
                        .foregroundColor(time != nil ? .primary : .gray)
                    Spacer()
                    Image(systemName: "clock.badge.plus")
                        .foregroundColor(time != nil ? .purple : .gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(time != nil ? Color.purple.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if time == nil {
                Text("Required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if showTimePicker {
                DatePicker(
                    "Select Time",
                    selection: Binding(
                        get: { time ?? Date() },
                        set: { time = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
}

struct PreviewButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Preview Offer")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isEnabled ?
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [.gray, .gray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}
