// Path: vibeIn/InfluencerPortal/InfluencerEditProfileView.swift

import SwiftUI
import FirebaseFirestore

struct InfluencerEditProfileView: View {
    let influencer: FirebaseInfluencer
    @Environment(\.dismiss) var dismiss
    @StateObject private var influencerService = FirebaseInfluencerService.shared

    // Editable fields
    @State private var userName: String
    @State private var instagramFollowers: String
    @State private var tiktokFollowers: String
    @State private var youtubeSubscribers: String
    @State private var selectedCategories: Set<String>
    @State private var selectedContentTypes: Set<String>
    @State private var city: String
    @State private var state: String

    // UI State
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    let categories = [
        "Food & Dining", "Fashion", "Travel", "Lifestyle",
        "Beauty", "Fitness", "Tech", "Entertainment",
        "Home & Design", "Wellness"
    ]

    let contentTypes = [
        "Photos", "Reels", "Stories", "Videos",
        "Live Streams", "Blogs", "TikToks", "Shorts"
    ]

    init(influencer: FirebaseInfluencer) {
        self.influencer = influencer
        _userName = State(initialValue: influencer.userName)
        _instagramFollowers = State(initialValue: "\(influencer.instagramFollowers)")
        _tiktokFollowers = State(initialValue: "\(influencer.tiktokFollowers)")
        _youtubeSubscribers = State(initialValue: "\(influencer.youtubeSubscribers)")
        _selectedCategories = State(initialValue: Set(influencer.categories))
        _selectedContentTypes = State(initialValue: Set(influencer.contentTypes))
        _city = State(initialValue: influencer.city)
        _state = State(initialValue: influencer.state)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.05),
                        Color.orange.opacity(0.05),
                        Color.yellow.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Basic Info Section
                        EditSection(title: "Basic Info", icon: "person.fill") {
                            VStack(spacing: 16) {
                                EditTextField(
                                    label: "Username",
                                    icon: "person.fill",
                                    text: $userName
                                )
                            }
                        }

                        // Social Media Section
                        EditSection(title: "Social Media Stats", icon: "chart.bar.fill") {
                            VStack(spacing: 16) {
                                EditTextField(
                                    label: "Instagram Followers",
                                    icon: "camera.fill",
                                    text: $instagramFollowers,
                                    keyboardType: .numberPad
                                )

                                EditTextField(
                                    label: "TikTok Followers",
                                    icon: "music.note",
                                    text: $tiktokFollowers,
                                    keyboardType: .numberPad
                                )

                                EditTextField(
                                    label: "YouTube Subscribers",
                                    icon: "play.rectangle.fill",
                                    text: $youtubeSubscribers,
                                    keyboardType: .numberPad
                                )
                            }
                        }

                        // Categories Section
                        EditSection(title: "Content Categories", icon: "square.grid.2x2.fill") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    SelectableCategoryChip(
                                        category: category,
                                        isSelected: selectedCategories.contains(category)
                                    ) {
                                        if selectedCategories.contains(category) {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }
                                }
                            }
                        }

                        // Content Types Section
                        EditSection(title: "Content Types", icon: "photo.on.rectangle.angled") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(contentTypes, id: \.self) { contentType in
                                    SelectableContentTypeChip(
                                        contentType: contentType,
                                        isSelected: selectedContentTypes.contains(contentType)
                                    ) {
                                        if selectedContentTypes.contains(contentType) {
                                            selectedContentTypes.remove(contentType)
                                        } else {
                                            selectedContentTypes.insert(contentType)
                                        }
                                    }
                                }
                            }
                        }

                        // Location Section
                        EditSection(title: "Location", icon: "location.fill") {
                            VStack(spacing: 12) {
                                // State Dropdown
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("State")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Menu {
                                        ForEach(USStates.allStates, id: \.self) { stateName in
                                            Button(stateName) {
                                                state = stateName
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "map.fill")
                                                .foregroundColor(.gray)
                                                .frame(width: 20)

                                            Text(state.isEmpty ? "Select State" : state)
                                                .foregroundColor(state.isEmpty ? .gray : .black)

                                            Spacer()

                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }

                                // City Dropdown
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("City")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Menu {
                                        ForEach(USCities.popularCities, id: \.self) { cityName in
                                            Button(cityName) {
                                                city = cityName
                                            }
                                        }
                                        Divider()
                                        Button("Other (Type Below)") {
                                            city = ""
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "building.2.fill")
                                                .foregroundColor(.gray)
                                                .frame(width: 20)

                                            Text(city.isEmpty ? "Select City" : city)
                                                .foregroundColor(city.isEmpty ? .gray : .black)

                                            Spacer()

                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }

                                    // Custom city input
                                    EditTextField(
                                        label: "Or type your city",
                                        icon: "building.2.fill",
                                        text: $city
                                    )
                                }
                            }
                        }

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }

                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    .disabled(isSaving || !canSave())
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Profile updated successfully!")
            }
        }
    }

    // MARK: - Validation
    private func canSave() -> Bool {
        return !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !city.trimmingCharacters(in: .whitespaces).isEmpty &&
               !state.trimmingCharacters(in: .whitespaces).isEmpty &&
               selectedCategories.count >= 1 &&
               selectedContentTypes.count >= 1
    }

    // MARK: - Save Profile
    private func saveProfile() {
        guard let documentId = influencer.id else {
            errorMessage = "Unable to update profile"
            showError = true
            return
        }

        isSaving = true

        let instagramCount = Int(instagramFollowers) ?? 0
        let tiktokCount = Int(tiktokFollowers) ?? 0
        let youtubeCount = Int(youtubeSubscribers) ?? 0
        let totalReach = instagramCount + tiktokCount + youtubeCount

        let updates: [String: Any] = [
            "userName": userName,
            "instagramFollowers": instagramCount,
            "tiktokFollowers": tiktokCount,
            "youtubeSubscribers": youtubeCount,
            "totalReach": totalReach,
            "categories": Array(selectedCategories),
            "contentTypes": Array(selectedContentTypes),
            "city": city,
            "state": state,
            "lastActive": Timestamp(),
            "isVerified": totalReach > 10000
        ]

        influencerService.updateInfluencerProfile(documentId: documentId, updates: updates) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    showSuccess = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Edit Section
struct EditSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            // Content
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Edit Text Field
struct EditTextField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)

                TextField(label, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
