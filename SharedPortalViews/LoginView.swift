// Path: vibeIn/SharedPortalViews/LoginView.swift

import SwiftUI

struct LoginView: View {
    enum UserType {
        case bizz, influencer
    }

    @State private var selectedUserType: UserType = .bizz
    @State private var navigateInfluencer = false
    @State private var navigateBizz = false
    @Namespace var animation

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                AnimatedBorder()
                LoginContent(
                    selectedUserType: $selectedUserType,
                    navigateInfluencer: $navigateInfluencer,
                    navigateBizz: $navigateBizz
                )
            }
        }
    }
}

// MARK: - Login Components
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct AnimatedBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(colors: [.pink, .blue, .purple, .orange]),
                    center: .center
                ),
                lineWidth: 6
            )
            .blur(radius: 2)
            .ignoresSafeArea()
    }
}

struct LoginContent: View {
    @Binding var selectedUserType: LoginView.UserType
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 60)
            
            AppLogo()
            UserTypeToggle(selectedUserType: $selectedUserType)
            JoinButton(
                selectedUserType: selectedUserType,
                navigateInfluencer: $navigateInfluencer,
                navigateBizz: $navigateBizz
            )
            NavigationLinks(
                navigateInfluencer: $navigateInfluencer,
                navigateBizz: $navigateBizz
            )
            
            Spacer()
        }
    }
}

struct AppLogo: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("X")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
                .shadow(radius: 4)
            
            Text("cash out vibes in.")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }
}

struct UserTypeToggle: View {
    @Binding var selectedUserType: LoginView.UserType
    
    var body: some View {
        HStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { selectedUserType == .influencer },
                set: { selectedUserType = $0 ? .influencer : .bizz }
            )) {
                Text(selectedUserType == .influencer ? "Influencer" : "Bizz")
                    .fontWeight(.medium)
            }
            .toggleStyle(SwitchToggleStyle(tint: .black))
            .padding()
        }
    }
}

struct JoinButton: View {
    let selectedUserType: LoginView.UserType
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    
    var body: some View {
        Button(action: {
            if selectedUserType == .influencer {
                navigateInfluencer = true
            } else {
                navigateBizz = true
            }
        }) {
            Text("Join")
                .font(.headline)
                .padding()
                .frame(width: 160)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(radius: 8)
        }
    }
}

struct NavigationLinks: View {
    @Binding var navigateInfluencer: Bool
    @Binding var navigateBizz: Bool
    
    var body: some View {
        Group {
            NavigationLink(destination: InfluencerView(), isActive: $navigateInfluencer) {
                EmptyView()
            }
            
            // Navigate to the new container with bottom navigation
            NavigationLink(destination: BizzNavigationContainer(), isActive: $navigateBizz) {
                EmptyView()
            }
        }
    }
}
