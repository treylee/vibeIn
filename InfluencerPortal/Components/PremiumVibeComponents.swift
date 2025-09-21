// Path: vibeIn/InfluencerPortal/Components/PremiumVibeComponents.swift

import SwiftUI

// MARK: - Premium Vibe Messages Prompt
struct PremiumVibeMessagesPrompt: View {
    @State private var showUpgradeDetails = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon and Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.2),
                                Color.orange.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                VStack(spacing: -5) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("PREMIUM")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 8)
                }
            }
            
            // Title
            Text("Unlock Vibe Messages")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Description
            Text("Connect directly with businesses and unlock exclusive collaboration opportunities")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                PremiumFeatureRow(
                    icon: "envelope.badge.fill",
                    title: "Direct Messages",
                    description: "Receive personalized messages from businesses",
                    color: .purple
                )
                
                PremiumFeatureRow(
                    icon: "star.bubble.fill",
                    title: "Priority Matching",
                    description: "Get matched with premium brands first",
                    color: .pink
                )
                
                PremiumFeatureRow(
                    icon: "dollarsign.circle.fill",
                    title: "Higher Rates",
                    description: "Access exclusive high-paying collaborations",
                    color: .green
                )
                
                PremiumFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics Dashboard",
                    description: "Track your performance and earnings",
                    color: .blue
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            )
            .padding(.horizontal)
            
            // CTA Button - Coming Soon
            Button(action: {
                showUpgradeDetails = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 18))
                    Text("Coming Soon")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray,
                            Color.gray.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
            }
            .padding(.horizontal)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showUpgradeDetails)
            
            // Pricing Info
            VStack(spacing: 8) {
                Text("Starting at")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(alignment: .top, spacing: 0) {
                    Text("$")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.orange)
                        .offset(y: 4)
                    Text("9.99")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("/month")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .offset(y: 12)
                }
                
                Text("Cancel anytime")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.8))
            }
            .padding(.top, 8)
        }
        .sheet(isPresented: $showUpgradeDetails) {
            PremiumUpgradeSheet()
        }
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Premium Upgrade Sheet
struct PremiumUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = "monthly"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Go Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock your full influencer potential")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Plan Selection
                    VStack(spacing: 16) {
                        PremiumPlanCard(
                            title: "Monthly",
                            price: "$9.99",
                            period: "/month",
                            isSelected: selectedPlan == "monthly",
                            onTap: { selectedPlan = "monthly" }
                        )
                        
                        PremiumPlanCard(
                            title: "Yearly",
                            price: "$99.99",
                            period: "/year",
                            badge: "Save 17%",
                            isSelected: selectedPlan == "yearly",
                            onTap: { selectedPlan = "yearly" }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Everything in Premium")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            PremiumChecklistItem(text: "Unlimited Vibe Messages")
                            PremiumChecklistItem(text: "Priority Brand Matching")
                            PremiumChecklistItem(text: "Advanced Analytics & Insights")
                            PremiumChecklistItem(text: "Exclusive High-Value Offers")
                            PremiumChecklistItem(text: "Verified Badge")
                            PremiumChecklistItem(text: "Early Access to New Features")
                            PremiumChecklistItem(text: "Dedicated Support")
                            PremiumChecklistItem(text: "Custom Media Kit Generator")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Coming Soon Button
                    Button(action: {
                        // Coming soon
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 18))
                            Text("Coming Soon")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .disabled(true)
                    .padding(.horizontal)
                    
                    // Terms
                    Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
}

// MARK: - Premium Plan Card
struct PremiumPlanCard: View {
    let title: String
    let price: String
    let period: String
    var badge: String? = nil
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .black)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isSelected ? .yellow : .green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.white.opacity(0.2) : Color.green.opacity(0.1))
                                )
                        }
                    }
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .purple)
                        Text(period)
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .gray.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Premium Checklist Item
struct PremiumChecklistItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

// MARK: - Premium Badge for Tab (Enhanced Design)
struct PremiumTabBadge: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text("Vibe Messages")
                .font(.system(size: 14))
            
            // Premium Badge Container
            ZStack {
                // Glow effect background
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 18)
                    .blur(radius: 2)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                // Main badge
                HStack(spacing: 2) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("PRO")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.15),
                                    Color.orange.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.5),
                                    Color.orange.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Compact Premium Badge (Alternative Style)
struct CompactPremiumBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.2),
                            Color.orange.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.4),
                            Color.orange.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}
