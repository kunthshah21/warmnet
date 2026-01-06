# Onboarding Flow Architecture

## Overview
The onboarding process guides new users through the value proposition of WarmNet, identifies their pain points, and sets up their initial experience. The flow is orchestrated to move linearly from introduction to final setup.

## Flow Orchestration
The entire onboarding sequence is managed by **`OnboardingView.swift`**, which acts as the root container. It manages the navigation state and transitions between different stages of onboarding.

## Screen Sequence

The typical user journey follows this path:

1.  **Splash Screen** (`SplashScreen.swift`)
    *   Initial loading and branding experience.

2.  **Problem Statement** (`Onboarding1ProblemScreen.swift`)
    *   Highlights the "problem" of losing touch with friends.
    *   *Goal*: Resonate with the user's need.

3.  **Painful Truth** (`Onboarding2PainfulTruthScreen.swift`)
    *   Agitates the problem (e.g., "Relationships fade without effort").
    *   *Goal*: Create urgency.

4.  **Value Proposition** (`Onboarding3ValuePropositionScreen.swift`)
    *   Introduces the solution (WarmNet's philosophy).
    *   *Goal*: Show how the app solves the problem.

5.  **Social Proof** (`SocialProofScreen.swift`)
    *   Displays reviews or testimonials to build trust.
    *   *Goal*: Validate the solution with social backing.

6.  **Personalisation / Customisation** (`CustomisingExperienceScreen.swift` / `Personalisation/`)
    *   Gathers user preferences to tailor the experience.
    *   May involve setting broad goals or preferences.

7.  **Paywall** (`PaywallScreen.swift`)
    *   (If active) Presents subscription options or premium features.
    *   *Goal*: Convert users or upsell features.

8.  **Contact Import** (`OnboardingContactImportWrapper.swift`)
    *   A critical step where users import their initial list of contacts.
    *   Includes `Contact Input Screens/`.
    *   *Goal*: Populate the app with data.

9.  **Plan Ready** (`PlanReadyScreen.swift`)
    *   Confirms that the initial setup is complete and a "plan" (schedule) has been generated.

10. **Final Congratulations** (`FinalCongratulationsScreen.swift`)
    *   Welcome message and transition to the main app (`HomeScreen`).
    *   Sets `hasCompletedOnboarding` flag to true.

## Files & Directories

*   **`OnboardingView.swift`**: Main entry point and flow controller.
*   **`SplashScreen.swift`**: App launch visual.
*   **`Onboarding1ProblemScreen.swift`** - **`Onboarding3ValuePropositionScreen.swift`**: Educational slides.
*   **`SocialProofScreen.swift`**: Trust element.
*   **`CustomisingExperienceScreen.swift`**: User input for customization.
*   **`PaywallScreen.swift`**: Monetization / Premium gate.
*   **`OnboardingContactImportWrapper.swift`**: Wrapper for contact permission and selection.
*   **`Contact Input Screens/`**: Subfolders containing specific contact import UI logic.
*   **`PlanReadyScreen.swift`**: Confirmation.
*   **`FinalCongratulationsScreen.swift`**: Completion.
*   **`Personalisation/`**: Logic and views related to personalizing the user account.

## State Management
*   The app likely persists a `hasCompletedOnboarding` boolean (often in `UserSettings` or `AppStorage`) to determine whether to show this flow or the Home screen on subsequent launches.
*   "Test Onboarding" in Settings can reset this flag to restart the flow.
