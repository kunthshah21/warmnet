//
//  AdvancedScoringScreen.swift
//  warmnet
//
//  Settings screen for advanced scoring and priority customization.
//

import SwiftUI
import SwiftData

struct AdvancedScoringScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var settings: UserSettings?
    
    // Local state for editing (not persisted until Save)
    @State private var innerCircleFrequency: Double = 1.0
    @State private var keyRelationshipsFrequency: Double = 1.0
    @State private var broaderNetworkFrequency: Double = 1.0
    @State private var innerCirclePriority: Double = 1.0
    @State private var keyRelationshipsPriority: Double = 1.0
    @State private var broaderNetworkPriority: Double = 1.0
    @State private var scoringGain: Double = 1.0
    @State private var decayRate: Double = 1.0
    @State private var healthPenalty: Double = 1.0
    @State private var dailyQueueSize: Int = 5
    
    // Alert states
    @State private var showSaveConfirmation = false
    @State private var showDiscardConfirmation = false
    @State private var showResetConfirmation = false
    
    // Track if user has made changes
    private var hasUnsavedChanges: Bool {
        guard let settings = settings else { return false }
        return innerCircleFrequency != settings.innerCircleFrequencyMultiplier ||
               keyRelationshipsFrequency != settings.keyRelationshipsFrequencyMultiplier ||
               broaderNetworkFrequency != settings.broaderNetworkFrequencyMultiplier ||
               innerCirclePriority != settings.innerCirclePriorityMultiplier ||
               keyRelationshipsPriority != settings.keyRelationshipsPriorityMultiplier ||
               broaderNetworkPriority != settings.broaderNetworkPriorityMultiplier ||
               scoringGain != settings.scoringGainMultiplier ||
               decayRate != settings.decayRateMultiplier ||
               healthPenalty != settings.healthPenaltyMultiplier ||
               dailyQueueSize != settings.dailyQueueSize
    }
    
    var body: some View {
        List {
            // MARK: - Per-Tier Settings
            tierSection(for: .innerCircle)
            tierSection(for: .keyRelationships)
            tierSection(for: .broaderNetwork)
            
            // MARK: - Global Scoring Behavior
            scoringBehaviorSection
            
            // MARK: - Queue Settings
            queueSettingsSection
            
            // MARK: - Reset
            resetSection
        }
        .navigationTitle("Scoring & Priorities")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if hasUnsavedChanges {
                        showDiscardConfirmation = true
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    showSaveConfirmation = true
                }
                .fontWeight(.semibold)
                .disabled(!hasUnsavedChanges)
            }
        }
        .onAppear {
            loadSettings()
        }
        .alert("Save Changes?", isPresented: $showSaveConfirmation) {
            Button("Save", role: .destructive) {
                saveChanges()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("These changes will affect how contact frequency and scoring work. Your daily queue priorities and reminder schedules may be adjusted based on these new settings.")
        }
        .alert("Discard Changes?", isPresented: $showDiscardConfirmation) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Are you sure you want to go back without saving?")
        }
        .alert("Reset to Defaults", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                resetToDefaults()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset all sliders to their default values. You will still need to press Save to apply these changes.")
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
    }
    
    // MARK: - Tier Section
    
    private func tierSection(for priority: Priority) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                frequencySlider(for: priority)
                Divider()
                prioritySlider(for: priority)
            }
            .padding(.vertical, 8)
        } header: {
            HStack(spacing: 8) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 10, height: 10)
                Text(priority.rawValue)
            }
        } footer: {
            Text(tierFooterText(for: priority))
        }
    }
    
    private func frequencySlider(for priority: Priority) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Contact Frequency")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(frequencyDisplayText(for: priority))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Slider(
                value: frequencyBinding(for: priority),
                in: 0.5...2.0,
                step: 0.1
            )
            
            HStack {
                Text("Less Often")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("More Often")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func prioritySlider(for priority: Priority) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Queue Priority")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(priorityDisplayText(for: priority))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Slider(
                value: priorityBinding(for: priority),
                in: 0.5...3.0,
                step: 0.1
            )
            
            HStack {
                Text("Low")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("High")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Scoring Behavior Section
    
    private var scoringBehaviorSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // Scoring Sensitivity
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Scoring Sensitivity")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(sensitivityDisplayText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $scoringGain, in: 0.5...2.0, step: 0.1)
                    
                    HStack {
                        Text("Forgiving")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Strict")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Decay Speed
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Decay Speed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(decayDisplayText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $decayRate, in: 0.5...2.0, step: 0.1)
                    
                    HStack {
                        Text("Slow")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Fast")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Health Boost
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Health Boost")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(healthBoostDisplayText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $healthPenalty, in: 0.0...2.0, step: 0.1)
                    
                    HStack {
                        Text("Off")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Aggressive")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Scoring Behavior")
        } footer: {
            Text("Adjust how connection scores are calculated. Forgiving scoring rewards any interaction; strict scoring requires consistency. Decay speed controls how fast scores drop without interaction. Health boost prioritizes neglected contacts in your queue.")
        }
    }
    
    // MARK: - Queue Settings Section
    
    private var queueSettingsSection: some View {
        Section {
            Stepper(value: $dailyQueueSize, in: 3...10) {
                HStack {
                    Text("Daily Contacts")
                    Spacer()
                    Text("\(dailyQueueSize)")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Queue")
        } footer: {
            Text("Maximum number of contacts suggested per day in your daily queue.")
        }
    }
    
    // MARK: - Reset Section
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Reset to Defaults")
                    Spacer()
                }
            }
            .disabled(!hasCustomLocalSettings)
        } footer: {
            if hasCustomLocalSettings {
                Text("You have customized settings. Tap to restore default values.")
            } else {
                Text("All settings are at their default values.")
            }
        }
    }
    
    // MARK: - Bindings
    
    private func frequencyBinding(for priority: Priority) -> Binding<Double> {
        switch priority {
        case .innerCircle:
            return $innerCircleFrequency
        case .keyRelationships:
            return $keyRelationshipsFrequency
        case .broaderNetwork:
            return $broaderNetworkFrequency
        }
    }
    
    private func priorityBinding(for priority: Priority) -> Binding<Double> {
        switch priority {
        case .innerCircle:
            return $innerCirclePriority
        case .keyRelationships:
            return $keyRelationshipsPriority
        case .broaderNetwork:
            return $broaderNetworkPriority
        }
    }
    
    // MARK: - Display Text Helpers
    
    private func frequencyDisplayText(for priority: Priority) -> String {
        let multiplier = frequencyBinding(for: priority).wrappedValue
        let baseDays = TierConfiguration.baseFrequencyDays(for: priority)
        let adjustedDays = max(1, Int(Double(baseDays) / multiplier))
        return "~\(adjustedDays) days"
    }
    
    private func priorityDisplayText(for priority: Priority) -> String {
        let multiplier = priorityBinding(for: priority).wrappedValue
        let baseWeight = TierConfiguration.baseTierWeight(for: priority)
        let adjustedWeight = max(1, Int(round(Double(baseWeight) * multiplier)))
        return "Weight: \(adjustedWeight)"
    }
    
    private var sensitivityDisplayText: String {
        if scoringGain < 0.8 {
            return "Forgiving"
        } else if scoringGain > 1.2 {
            return "Strict"
        } else {
            return "Normal"
        }
    }
    
    private var decayDisplayText: String {
        if decayRate < 0.8 {
            return "Slow"
        } else if decayRate > 1.2 {
            return "Fast"
        } else {
            return "Normal"
        }
    }
    
    private var healthBoostDisplayText: String {
        if healthPenalty < 0.3 {
            return "Off"
        } else if healthPenalty > 1.5 {
            return "Aggressive"
        } else if healthPenalty > 1.2 {
            return "Strong"
        } else if healthPenalty < 0.8 {
            return "Light"
        } else {
            return "Normal"
        }
    }
    
    private func tierFooterText(for priority: Priority) -> String {
        switch priority {
        case .innerCircle:
            return "Your closest contacts. Default: every 14 days."
        case .keyRelationships:
            return "Important professional and personal connections. Default: every 60 days."
        case .broaderNetwork:
            return "Extended network and acquaintances. Default: every 180 days."
        }
    }
    
    private var hasCustomLocalSettings: Bool {
        innerCircleFrequency != 1.0 ||
        keyRelationshipsFrequency != 1.0 ||
        broaderNetworkFrequency != 1.0 ||
        innerCirclePriority != 1.0 ||
        keyRelationshipsPriority != 1.0 ||
        broaderNetworkPriority != 1.0 ||
        scoringGain != 1.0 ||
        decayRate != 1.0 ||
        healthPenalty != 1.0
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        settings = UserSettings.getOrCreate(from: modelContext)
        
        guard let settings = settings else { return }
        
        // Copy current values to local state
        innerCircleFrequency = settings.innerCircleFrequencyMultiplier
        keyRelationshipsFrequency = settings.keyRelationshipsFrequencyMultiplier
        broaderNetworkFrequency = settings.broaderNetworkFrequencyMultiplier
        innerCirclePriority = settings.innerCirclePriorityMultiplier
        keyRelationshipsPriority = settings.keyRelationshipsPriorityMultiplier
        broaderNetworkPriority = settings.broaderNetworkPriorityMultiplier
        scoringGain = settings.scoringGainMultiplier
        decayRate = settings.decayRateMultiplier
        healthPenalty = settings.healthPenaltyMultiplier
        dailyQueueSize = settings.dailyQueueSize
    }
    
    private func saveChanges() {
        guard let settings = settings else { return }
        
        // Apply all local state to the settings model
        settings.innerCircleFrequencyMultiplier = innerCircleFrequency
        settings.keyRelationshipsFrequencyMultiplier = keyRelationshipsFrequency
        settings.broaderNetworkFrequencyMultiplier = broaderNetworkFrequency
        settings.innerCirclePriorityMultiplier = innerCirclePriority
        settings.keyRelationshipsPriorityMultiplier = keyRelationshipsPriority
        settings.broaderNetworkPriorityMultiplier = broaderNetworkPriority
        settings.scoringGainMultiplier = scoringGain
        settings.decayRateMultiplier = decayRate
        settings.healthPenaltyMultiplier = healthPenalty
        settings.dailyQueueSize = dailyQueueSize
        settings.updatedAt = Date()
    }
    
    private func resetToDefaults() {
        innerCircleFrequency = 1.0
        keyRelationshipsFrequency = 1.0
        broaderNetworkFrequency = 1.0
        innerCirclePriority = 1.0
        keyRelationshipsPriority = 1.0
        broaderNetworkPriority = 1.0
        scoringGain = 1.0
        decayRate = 1.0
        healthPenalty = 1.0
    }
}

#Preview {
    NavigationStack {
        AdvancedScoringScreen()
    }
    .modelContainer(for: [UserSettings.self], inMemory: true)
}
