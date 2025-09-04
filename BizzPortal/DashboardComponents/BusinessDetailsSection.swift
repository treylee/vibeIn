// Path: vibeIn/BizzPortal/Components/BusinessDetailsSection.swift

import SwiftUI

struct BusinessDetailsSection: View {
    let business: FirebaseBusiness
    
    @State private var isEditing = false
    @State private var businessHours: String = ""
    @State private var phoneNumber: String = ""
    @State private var missionStatement: String = ""
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var isSaving = false
    @State private var hasLoadedInitialData = false
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Business Details")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Text(isEditing ? "Update your information" : "Essential information")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        if isEditing {
                            saveDetailsData()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isEditing.toggle()
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(isSaving ? "Saving..." : (isEditing ? "Save" : "Edit"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isEditing ? [.green, .teal] : [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                    }
                    .disabled(isSaving)
                }
            }
            
            VStack(spacing: 16) {
                // Business Hours Card
                HStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Business Hours")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        if isEditing {
                            TextField("e.g., Mon-Fri 9AM-9PM", text: $businessHours)
                                .font(.system(size: 16, weight: .medium))
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        } else {
                            Text(businessHours.isEmpty ? "Not set" : businessHours)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(businessHours.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Phone Number Card
                HStack(spacing: 16) {
                    Image(systemName: "phone.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contact Number")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        if isEditing {
                            TextField("(555) 123-4567", text: $phoneNumber)
                                .font(.system(size: 16, weight: .medium))
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.phonePad)
                                .padding(8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        } else {
                            Text(phoneNumber.isEmpty ? "Not set" : phoneNumber)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(phoneNumber.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color.green.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Mission Statement Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.quote")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.3, blue: 0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Our Mission")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            Text("What makes your business special")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        }
                        
                        Spacer()
                    }
                    
                    if isEditing {
                        TextEditor(text: $missionStatement)
                            .font(.system(size: 14))
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Text(missionStatement.isEmpty ? "Tell your story..." : missionStatement)
                            .font(.system(size: 14))
                            .foregroundColor(missionStatement.isEmpty ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.05))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isEditing ? Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear {
            // Only load once on initial appear
            if !hasLoadedInitialData {
                loadBusinessDetails()
                hasLoadedInitialData = true
            }
        }
        .alert("Details Updated!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveAlertMessage)
        }
    }
    
    private func loadBusinessDetails() {
        businessHours = business.hours ?? ""
        phoneNumber = business.phone ?? ""
        missionStatement = business.missionStatement ?? ""
        
        print("📋 Loaded business details:")
        print("   - Hours: \(businessHours)")
        print("   - Phone: \(phoneNumber)")
        print("   - Mission: \(missionStatement.prefix(50))...")
    }
    
    private func saveDetailsData() {
        guard let businessId = business.id else {
            saveAlertMessage = "Error: Business ID not found"
            showingSaveAlert = true
            return
        }
        
        isSaving = true
        
        businessService.updateBusinessDetails(
            businessId: businessId,
            hours: businessHours,
            phone: phoneNumber,
            missionStatement: missionStatement
        ) { success in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if success {
                    self.saveAlertMessage = "Business details saved successfully!"
                    self.isEditing = false
                    // Don't trigger refresh - just keep local state
                    print("✅ Business details saved successfully")
                } else {
                    self.saveAlertMessage = "Failed to save details. Please try again."
                    print("❌ Failed to save business details")
                }
                self.showingSaveAlert = true
            }
        }
    }
}
