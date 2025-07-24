// Path: vibeIn/SharedPortalViews/LoginView.swift

import SwiftUI

struct LoginView: View {
    enum UserType {
        case bizz, influencer
    }

    @State private var selectedUserType: UserType = .influencer
    @State private var navigateInfluencer = false
    @State private var navigateBizz = false
    @Namespace var animation

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient based on selection
                LinearGradient(
                    gradient: Gradient(colors:
                        selectedUserType == .influencer ? [
                            Color.pink.opacity(0.05),
                            Color.orange.opacity(0.05),
                            Color.yellow.opacity(0.03)
                        ] : [
                            Color.blue.opacity(0.08),
                            Color.purple.opacity(0.08),
                            Color.indigo.opacity(0.05)
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: selectedUserType)
                
                LoginContent(
                    selectedUserType: $selectedUserType,
                    navigateInfluencer: $navigateInfluencer,
                    navigateBizz: $navigateBizz,
                    animation: animation
                )
            }
        }
    }
}

// MARK: - Login Content
struct LoginContent: View {
    @Binding var selectedUserType: LoginView.UserType
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    let animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer().frame(height: 80)
            
            // Dynamic vibeIN Logo
            DynamicVibeINLogo(selectedUserType: selectedUserType)
            
            // Tagline
            VStack(spacing: 8) {
                Text("Where Vibes")
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                
                Text("Create Value")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: selectedUserType == .influencer ?
                                [.purple, .pink, .orange] :
                                [.blue, .purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.easeInOut(duration: 0.5), value: selectedUserType)
            }
            
            // Modern User Type Selector
            ModernUserTypeSelector(
                selectedUserType: $selectedUserType,
                animation: animation
            )
            
            // Join Button
            ModernJoinButton(
                selectedUserType: selectedUserType,
                navigateInfluencer: $navigateInfluencer,
                navigateBizz: $navigateBizz
            )
            
            // Navigation Links
            NavigationLinks(
                navigateInfluencer: $navigateInfluencer,
                navigateBizz: $navigateBizz
            )
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Dynamic vibeIN Logo (replaces ModernVibeINLogo)
struct DynamicVibeINLogo: View {
    let selectedUserType: LoginView.UserType
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Glowing background
            Circle()
                .fill(
                    LinearGradient(
                        colors: selectedUserType == .influencer ?
                            [.purple.opacity(0.3), .pink.opacity(0.3)] :
                            [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 30)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .animation(.easeInOut(duration: 0.5), value: selectedUserType)
            
            VStack(spacing: -8) {
                Text("vibe")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: selectedUserType == .influencer ?
                                [.purple, .pink] :
                                [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.easeInOut(duration: 0.5), value: selectedUserType)
                
                Text("IN")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: selectedUserType == .influencer ?
                                [.pink, .orange] :
                                [.purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.easeInOut(duration: 0.5), value: selectedUserType)
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Modern User Type Selector
struct ModernUserTypeSelector: View {
    @Binding var selectedUserType: LoginView.UserType
    let animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 20) {
            Text("I am a...")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 0) {
                // Influencer Option (now on left)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedUserType = .influencer
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    selectedUserType == .influencer ?
                                    LinearGradient(
                                        colors: [.pink, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(selectedUserType == .influencer ? .white : .gray)
                        }
                        
                        Text("Influencer")
                            .font(.headline)
                            .foregroundColor(selectedUserType == .influencer ? .black : .gray)
                        
                        Text("Share your vibe")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(selectedUserType == .influencer ? 1.0 : 0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selectedUserType == .influencer ?
                                        LinearGradient(
                                            colors: [.pink.opacity(0.5), .orange.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .scaleEffect(selectedUserType == .influencer ? 1.05 : 1.0)
                }
                
                Spacer().frame(width: 16)
                
                // Business Owner Option (now on right)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedUserType = .bizz
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    selectedUserType == .bizz ?
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "storefront.fill")
                                .font(.title2)
                                .foregroundColor(selectedUserType == .bizz ? .white : .gray)
                        }
                        
                        Text("Business")
                            .font(.headline)
                            .foregroundColor(selectedUserType == .bizz ? .black : .gray)
                        
                        Text("Grow your brand")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(selectedUserType == .bizz ? 1.0 : 0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selectedUserType == .bizz ?
                                        LinearGradient(
                                            colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .scaleEffect(selectedUserType == .bizz ? 1.05 : 1.0)
                }
            }
        }
    }
}

// MARK: - Modern Join Button
struct ModernJoinButton: View {
    let selectedUserType: LoginView.UserType
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if selectedUserType == .influencer {
                navigateInfluencer = true
            } else {
                navigateBizz = true
            }
        }) {
            HStack(spacing: 12) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: selectedUserType == .influencer ?
                        [.pink, .orange] : [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(
                color: selectedUserType == .influencer ?
                    Color.pink.opacity(0.3) : Color.blue.opacity(0.3),
                radius: 15,
                y: 8
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Navigation Links (unchanged)
struct NavigationLinks: View {
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    
    var body: some View {
        Group {
            NavigationLink(destination: InfluencerView(), isActive: $navigateInfluencer) {
                EmptyView()
            }
            
            NavigationLink(destination: BizzNavigationContainer(), isActive: $navigateBizz) {
                EmptyView()
            }
        }
    }
}
