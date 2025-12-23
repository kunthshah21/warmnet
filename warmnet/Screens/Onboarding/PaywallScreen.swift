//
//  PaywallScreen.swift
//  warmnet
//
//  Created on 24 December 2025.
//

import SwiftUI

struct PaywallScreen: View {
    @State private var showContent = false
    @State private var selectedPlan: PricingPlan = .annual
    
    var onContinue: () -> Void = {}
    var onSkip: () -> Void = {}
    
    enum PricingPlan {
        case monthly
        case annual
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                    
                    Text("Get the most out of your network")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                    
                    Text("Unlock premium features to supercharge your relationships")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
                }
                .padding(.top, 60)
                .padding(.horizontal, 32)
                
                // Features list
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "sparkles", title: "AI-Powered Insights", description: "Get smart suggestions on when to reach out")
                    FeatureRow(icon: "calendar.badge.clock", title: "Smart Reminders", description: "Never forget important dates or check-ins")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Track and improve your relationship metrics")
                    FeatureRow(icon: "infinity", title: "Unlimited Contacts", description: "Manage unlimited connections without limits")
                    FeatureRow(icon: "paintbrush.fill", title: "Premium Themes", description: "Customize your experience with exclusive themes")
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 32)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                Spacer()
                
                // Pricing cards
                VStack(spacing: 12) {
                    PricingCard(
                        plan: .annual,
                        title: "Annual",
                        price: "$49.99/year",
                        savings: "Save 50%",
                        isSelected: selectedPlan == .annual,
                        action: { selectedPlan = .annual }
                    )
                    
                    PricingCard(
                        plan: .monthly,
                        title: "Monthly",
                        price: "$8.99/month",
                        savings: nil,
                        isSelected: selectedPlan == .monthly,
                        action: { selectedPlan = .monthly }
                    )
                }
                .padding(.horizontal, 32)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text("Start Premium")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button(action: onSkip) {
                        Text("Continue with Free")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    .padding(.vertical, 8)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary.opacity(0.7))
            }
        }
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let plan: PaywallScreen.PricingPlan
    let title: String
    let price: String
    let savings: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    Text(price)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.purple : Color.gray.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? Color.purple.opacity(0.3) : Color.clear, radius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? 
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallScreen()
}
