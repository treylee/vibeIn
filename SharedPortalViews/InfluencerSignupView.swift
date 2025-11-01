// Path: vibeIn/SharedPortalViews/InfluencerSignupView.swift

import SwiftUI

struct InfluencerSignupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @State private var currentStep = 1
    let totalSteps = 4

    // Step 1: Basic Info
    @State private var userName = ""
    @State private var email = ""

    // Step 2: Social Media Stats
    @State private var instagramHandle = ""
    @State private var instagramFollowers = ""
    @State private var tiktokHandle = ""
    @State private var tiktokFollowers = ""
    @State private var youtubeHandle = ""
    @State private var youtubeSubscribers = ""

    // Step 3: Content Categories
    @State private var selectedCategories: Set<String> = []
    let categories = [
        "Food & Dining", "Fashion", "Travel", "Lifestyle",
        "Beauty", "Fitness", "Tech", "Entertainment",
        "Home & Design", "Wellness"
    ]

    // Step 4: Content Types
    @State private var selectedContentTypes: Set<String> = []
    let contentTypes = [
        "Photos", "Reels", "Stories", "Videos",
        "Live Streams", "Blogs", "TikToks", "Shorts"
    ]

    // Location
    @State private var city = ""
    @State private var state = ""

    // UI State
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToPortal = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background
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

                VStack(spacing: 0) {
                    // Progress Header
                    ProgressHeader(currentStep: currentStep, totalSteps: totalSteps)

                    // Content
                    ScrollView {
                        VStack(spacing: 32) {
                            // Step Content
                            switch currentStep {
                            case 1:
                                Step1BasicInfo(userName: $userName, email: $email)
                            case 2:
                                Step2SocialMedia(
                                    instagramHandle: $instagramHandle,
                                    instagramFollowers: $instagramFollowers,
                                    tiktokHandle: $tiktokHandle,
                                    tiktokFollowers: $tiktokFollowers,
                                    youtubeHandle: $youtubeHandle,
                                    youtubeSubscribers: $youtubeSubscribers
                                )
                            case 3:
                                Step3Categories(
                                    selectedCategories: $selectedCategories,
                                    categories: categories
                                )
                            case 4:
                                Step4ContentTypes(
                                    selectedContentTypes: $selectedContentTypes,
                                    contentTypes: contentTypes,
                                    city: $city,
                                    state: $state
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }

                    // Navigation Buttons
                    NavigationButtons(
                        currentStep: $currentStep,
                        totalSteps: totalSteps,
                        isCreating: $isCreating,
                        canProceed: canProceedFromCurrentStep(),
                        onComplete: createInfluencerProfile
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.purple)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $navigateToPortal) {
                InfluencerNavigationContainer()
                    .navigationBarHidden(true)
            }
        }
    }

    // MARK: - Validation
    private func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case 1:
            return !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !email.trimmingCharacters(in: .whitespaces).isEmpty &&
                   email.contains("@")
        case 2:
            // At least one social media platform with followers
            return (!instagramFollowers.isEmpty && Int(instagramFollowers) != nil) ||
                   (!tiktokFollowers.isEmpty && Int(tiktokFollowers) != nil) ||
                   (!youtubeSubscribers.isEmpty && Int(youtubeSubscribers) != nil)
        case 3:
            return selectedCategories.count >= 1
        case 4:
            return selectedContentTypes.count >= 1 &&
                   !city.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !state.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            return false
        }
    }

    // MARK: - Create Profile
    private func createInfluencerProfile() {
        isCreating = true

        let instagramCount = Int(instagramFollowers) ?? 0
        let tiktokCount = Int(tiktokFollowers) ?? 0
        let youtubeCount = Int(youtubeSubscribers) ?? 0

        // Determine platforms based on what they filled in
        var platforms: [String] = []
        if instagramCount > 0 { platforms.append("Instagram") }
        if tiktokCount > 0 { platforms.append("TikTok") }
        if youtubeCount > 0 { platforms.append("YouTube") }
        if platforms.isEmpty { platforms = ["Instagram"] } // Default

        influencerService.createInfluencer(
            userName: userName,
            email: email,
            instagramFollowers: instagramCount,
            tiktokFollowers: tiktokCount,
            youtubeSubscribers: youtubeCount,
            categories: Array(selectedCategories),
            contentTypes: Array(selectedContentTypes),
            reviewPlatforms: platforms,
            city: city,
            state: state
        ) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success:
                    // Navigate to influencer portal
                    navigateToPortal = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Progress Header
struct ProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: 16) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (CGFloat(currentStep) / CGFloat(totalSteps)), height: 4)
                        .animation(.spring(), value: currentStep)
                }
            }
            .frame(height: 4)

            // Step Indicator
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text("\(Int((Double(currentStep) / Double(totalSteps)) * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .background(Color.white.opacity(0.9))
    }
}

// MARK: - Step 1: Basic Info
struct Step1BasicInfo: View {
    @Binding var userName: String
    @Binding var email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Let's start with the basics")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Create your influencer profile")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Form Fields
            VStack(spacing: 20) {
                CustomTextField(
                    icon: "person.fill",
                    placeholder: "Username",
                    text: $userName
                )

                CustomTextField(
                    icon: "envelope.fill",
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress
                )
            }

            // Tips
            InfoBox(
                icon: "lightbulb.fill",
                text: "Choose a username that represents your brand. This is how businesses will identify you."
            )
        }
    }
}

// MARK: - Step 2: Social Media
struct Step2SocialMedia: View {
    @Binding var instagramHandle: String
    @Binding var instagramFollowers: String
    @Binding var tiktokHandle: String
    @Binding var tiktokFollowers: String
    @Binding var youtubeHandle: String
    @Binding var youtubeSubscribers: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Your social reach")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Add your social media stats")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Instagram
            SocialMediaSection(
                platform: "Instagram",
                icon: "camera.fill",
                color: .pink,
                handle: $instagramHandle,
                followers: $instagramFollowers,
                followerLabel: "Followers"
            )

            // TikTok
            SocialMediaSection(
                platform: "TikTok",
                icon: "music.note",
                color: .black,
                handle: $tiktokHandle,
                followers: $tiktokFollowers,
                followerLabel: "Followers"
            )

            // YouTube
            SocialMediaSection(
                platform: "YouTube",
                icon: "play.rectangle.fill",
                color: .red,
                handle: $youtubeHandle,
                followers: $youtubeSubscribers,
                followerLabel: "Subscribers"
            )

            // Tips
            InfoBox(
                icon: "info.circle.fill",
                text: "Fill in at least one platform. You can add more later from your profile."
            )
        }
    }
}

// MARK: - Social Media Section
struct SocialMediaSection: View {
    let platform: String
    let icon: String
    let color: Color
    @Binding var handle: String
    @Binding var followers: String
    let followerLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(platform)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            VStack(spacing: 12) {
                CustomTextField(
                    icon: "at",
                    placeholder: "Handle (optional)",
                    text: $handle
                )

                CustomTextField(
                    icon: "chart.bar.fill",
                    placeholder: followerLabel,
                    text: $followers,
                    keyboardType: .numberPad
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Step 3: Categories
struct Step3Categories: View {
    @Binding var selectedCategories: Set<String>
    let categories: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Your content niches")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select the categories you create content about")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Category Grid
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

            // Selected Count
            if !selectedCategories.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(selectedCategories.count) selected")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Selectable Category Chip
struct SelectableCategoryChip: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .black)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.orange, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Step 4: Content Types
struct Step4ContentTypes: View {
    @Binding var selectedContentTypes: Set<String>
    let contentTypes: [String]
    @Binding var city: String
    @Binding var state: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Content you create")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select your content formats")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Content Type Grid
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

            // Location
            VStack(alignment: .leading, spacing: 16) {
                Text("Your location")
                    .font(.headline)
                    .foregroundColor(.black)

                VStack(spacing: 12) {
                    // State Dropdown
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
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // City Dropdown
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
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // Custom city input (if "Other" selected)
                    CustomTextField(
                        icon: "building.2.fill",
                        placeholder: "Type your city",
                        text: $city
                    )
                }
            }
        }
    }
}

// MARK: - Selectable Content Type Chip
struct SelectableContentTypeChip: View {
    let contentType: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(contentType)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .black)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    @Binding var isCreating: Bool
    let canProceed: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if currentStep < totalSteps {
                // Next Button
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        canProceed ?
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(!canProceed)
            } else {
                // Complete Button
                Button(action: onComplete) {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Setup")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        canProceed && !isCreating ?
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(!canProceed || isCreating)
            }

            // Back Button (except on first step)
            if currentStep > 1 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    Text("Back")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.95))
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Info Box
struct InfoBox: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 16))

            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}
