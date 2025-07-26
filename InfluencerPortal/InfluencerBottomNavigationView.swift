// Path: vibeIn/InfluencerPortal/Components/InfluencerBottomNavigationView.swift

import SwiftUI
import MapKit

// MARK: - Navigation Container View
struct InfluencerNavigationContainer: View {
    @StateObject private var navigationState = InfluencerNavigationState()
    @StateObject private var influencerService = FirebaseInfluencerService.shared
    @StateObject private var offerService = FirebaseOfferService.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Views
            TabView(selection: $navigationState.selectedTab) {
                // Discover Tab
                NavigationStack {
                    InfluencerSearchView()
                }
                .tag(InfluencerTab.discover)
                .environmentObject(navigationState)
                
                // Portal Tab (Home)
                NavigationStack {
                    InfluencerPortalView()
                }
                .tag(InfluencerTab.portal)
                .environmentObject(navigationState)
                
                // Profile Tab
                NavigationStack {
                    if let influencer = navigationState.currentInfluencer {
                        InfluencerProfileView(influencer: influencer)
                    } else {
                        InfluencerProfilePlaceholder()
                    }
                }
                .tag(InfluencerTab.profile)
                .environmentObject(navigationState)
            }
            .environmentObject(navigationState)
            
            // Custom Bottom Navigation Bar (always visible)
            InfluencerBottomNavigationBar(selectedTab: $navigationState.selectedTab)
                .environmentObject(navigationState)
        }
        .ignoresSafeArea(.keyboard) // Ensure bottom bar stays visible even with keyboard
        .onAppear {
            loadInfluencerProfile()
            setupTabBarAppearance()
        }
        .onChange(of: navigationState.selectedTab) { oldValue, newValue in
            print("📱 Tab changed from \(oldValue.rawValue) to \(newValue.rawValue)")
            if newValue == .profile {
                print("👤 Profile selected - Influencer: \(navigationState.currentInfluencer?.userName ?? "nil")")
                
                // Add haptic feedback when switching to profile
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    private func setupTabBarAppearance() {
        // Hide the default tab bar
        UITabBar.appearance().isHidden = true
    }
    
    private func loadInfluencerProfile() {
        if let influencer = influencerService.currentInfluencer {
            navigationState.currentInfluencer = influencer
            print("👤 Influencer loaded: \(influencer.userName)")
        }
    }
}

// MARK: - Navigation State
class InfluencerNavigationState: ObservableObject {
    @Published var currentInfluencer: FirebaseInfluencer?
    @Published var selectedTab: InfluencerTab = .portal
    @Published var shouldPopToRoot = false
    
    func navigateToPortal() {
        selectedTab = .portal
        shouldPopToRoot = true
    }
    
    func navigateToDashboard() {
        selectedTab = .discover
        shouldPopToRoot = true
    }
}

// MARK: - Tab Enum
enum InfluencerTab: String, CaseIterable {
    case discover = "Discover"
    case portal = "Portal"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .discover: return "sparkle.magnifyingglass"
        case .portal: return "star.circle.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
    
    var vibeColor: [Color] {
        switch self {
        case .discover: return [Color.orange.opacity(0.8), Color.pink.opacity(0.8)]
        case .portal: return [Color.purple.opacity(0.8), Color.pink.opacity(0.8)]
        case .profile: return [Color.pink.opacity(0.8), Color.purple.opacity(0.8)]
        }
    }
}

// MARK: - Influencer Bottom Navigation Bar
struct InfluencerBottomNavigationBar: View {
    @Binding var selectedTab: InfluencerTab
    @EnvironmentObject var navigationState: InfluencerNavigationState
    @State private var animateGradient = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Thin colorful top line
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.6),
                    Color.pink.opacity(0.6),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.6)
                ]),
                startPoint: animateGradient ? .leading : .trailing,
                endPoint: animateGradient ? .trailing : .leading
            )
            .frame(height: 1)
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            HStack(spacing: 0) {
                ForEach(InfluencerTab.allCases, id: \.self) { tab in
                    InfluencerTabButton(
                        tab: tab,
                        selectedTab: $selectedTab
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 25)
            .background(
                // Lightweight frosted glass effect
                ZStack {
                    // Light blur
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    // Subtle white overlay
                    Rectangle()
                        .fill(Color.white.opacity(0.7))
                }
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -2)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Influencer Tab Button
struct InfluencerTabButton: View {
    let tab: InfluencerTab
    @Binding var selectedTab: InfluencerTab
    @State private var isPressed = false
    @EnvironmentObject var navigationState: InfluencerNavigationState
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            print("🔘 Tab tapped: \(tab.rawValue)")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
                
                // Light haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Subtle background for selected state
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: tab.vibeColor.map { $0.opacity(0.15) }),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 32)
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 24 : 20, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            isSelected ? LinearGradient(colors: tab.vibeColor, startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(isSelected ? 1.0 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }
                .frame(width: 60, height: 32)
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(
                        isSelected ? LinearGradient(colors: tab.vibeColor, startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(isSelected ? 1.0 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Profile Placeholder
struct InfluencerProfilePlaceholder: View {
    var body: some View {
        ZStack {
            // Vibe gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.pink.opacity(0.2),
                    Color.purple.opacity(0.3),
                    Color.orange.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
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
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Profile Loading")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Setting up your influencer profile")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 80)
                
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.pink.opacity(0.6))
                    
                    Text("Start from Portal")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
}
