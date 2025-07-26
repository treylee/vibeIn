// Path: vibeIn/BizzPortal/Components/BizzBottomNavigationView.swift

import SwiftUI
import MapKit

// MARK: - Navigation Container View
struct BizzNavigationContainer: View {
    @StateObject private var navigationState = BizzNavigationState()
    @StateObject private var userService = FirebaseUserService.shared
    @StateObject private var businessService = FirebaseBusinessService.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Views
            TabView(selection: $navigationState.selectedTab) {
                // Search Tab
                NavigationStack {
                    BizzSearchView()
                }
                .tag(BizzTab.search)
                
                // Home Tab
                NavigationStack {
                    BizzPortalViewRegistered()
                }
                .tag(BizzTab.home)
                
                // Dashboard Tab
                NavigationStack {
                    if let business = navigationState.userBusiness {
                        BusinessDashboardView(business: business)
                    } else {
                        BizzDashboardPlaceholder()
                    }
                }
                .tag(BizzTab.dashboard)
            }
            .environmentObject(navigationState)
            
            // Custom Bottom Navigation Bar (always visible)
            VibeBottomNavigationBar(selectedTab: $navigationState.selectedTab)
                .environmentObject(navigationState)
        }
        .ignoresSafeArea(.keyboard) // Ensure bottom bar stays visible even with keyboard
        .onAppear {
            loadUserBusiness()
            setupTabBarAppearance()
        }
        .onChange(of: navigationState.selectedTab) { oldValue, newValue in
            print("📱 Tab changed from \(oldValue.rawValue) to \(newValue.rawValue)")
            if newValue == .dashboard {
                print("📊 Dashboard selected - Business: \(navigationState.userBusiness?.name ?? "nil")")
                
                // Add haptic feedback when switching to dashboard
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    private func setupTabBarAppearance() {
        // Hide the default tab bar
        UITabBar.appearance().isHidden = true
    }
    
    private func loadUserBusiness() {
        guard let currentUser = userService.currentUser,
              currentUser.hasCreatedBusiness else {
            navigationState.userBusiness = nil
            print("📊 Dashboard: No business to load")
            return
        }
        
        userService.getUserBusiness { business in
            self.navigationState.userBusiness = business
            print("📊 Dashboard: Business loaded - \(business?.name ?? "nil")")
        }
    }
}

// MARK: - Navigation State
class BizzNavigationState: ObservableObject {
    @Published var userBusiness: FirebaseBusiness?
    @Published var selectedTab: BizzTab = .home
}

// MARK: - Tab Enum
enum BizzTab: String, CaseIterable {
    case search = "Search"
    case home = "Home"
    case dashboard = "Dashboard"
    
    var icon: String {
        switch self {
        case .search: return "sparkle.magnifyingglass"
        case .home: return "house.fill"
        case .dashboard: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var vibeColor: [Color] {
        switch self {
        case .search: return [Color.pink.opacity(0.8), Color.purple.opacity(0.8)]
        case .home: return [Color.orange.opacity(0.8), Color.pink.opacity(0.8)]
        case .dashboard: return [Color.teal.opacity(0.8), Color.blue.opacity(0.8)]
        }
    }
}

// MARK: - Vibe Bottom Navigation Bar (TikTok/Instagram Style)
struct VibeBottomNavigationBar: View {
    @Binding var selectedTab: BizzTab
    @EnvironmentObject var navigationState: BizzNavigationState
    @State private var animateGradient = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Thin colorful top line
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.pink.opacity(0.6),
                    Color.orange.opacity(0.6),
                    Color.purple.opacity(0.6),
                    Color.teal.opacity(0.6)
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
                ForEach(BizzTab.allCases, id: \.self) { tab in
                    VibeTabButton(
                        tab: tab,
                        selectedTab: $selectedTab,
                        isEnabled: tab != .dashboard || navigationState.userBusiness != nil
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

// MARK: - Vibe Tab Button
struct VibeTabButton: View {
    let tab: BizzTab
    @Binding var selectedTab: BizzTab
    let isEnabled: Bool
    @State private var isPressed = false
    @EnvironmentObject var navigationState: BizzNavigationState
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                print("🔘 Tab tapped: \(tab.rawValue), Enabled: \(isEnabled)")
                if tab == .dashboard {
                    print("📊 Dashboard business: \(navigationState.userBusiness?.name ?? "nil")")
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tab
                    
                    // Light haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            } else {
                print("❌ Tab disabled: \(tab.rawValue)")
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
                            !isEnabled ? LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom) :
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
                        !isEnabled ? LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom) :
                        isSelected ? LinearGradient(colors: tab.vibeColor, startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(isSelected ? 1.0 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Dashboard Placeholder
struct BizzDashboardPlaceholder: View {
    var body: some View {
        ZStack {
            // Vibe gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.teal.opacity(0.2),
                    Color.blue.opacity(0.3),
                    Color.green.opacity(0.2)
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
                                    colors: [Color.teal.opacity(0.3), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("No Business Yet")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Create your business to see analytics")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 80)
                
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.teal.opacity(0.6))
                    
                    Text("Start from Home")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding(.bottom, 80)
    }
}
