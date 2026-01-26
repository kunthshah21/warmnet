import SwiftUI

// MARK: - Font Names
enum AppFontName {
    static let overpassVariable = "Overpass-VariableFont_wght"
    static let workSansMedium = "WorkSans-Medium"
    static let workSansRegular = "WorkSans-Regular"
}

// MARK: - Design System Colors
/// Color palette following the design system guidelines
struct AppColors {
    // Background Colors
    static let deepNavy = Color.black                 // Darkest background layer
    static let charcoal = Color(uiColor: .systemGray6)// Secondary background, elevated surfaces
    static let darkTeal = Color("darkTeal")          // Accent background
    
    // Accent Colors
    static let softBeige = Color("softBeige")        // Warm highlight color
    static let mutedBlue = Color("mutedBlue")        // Primary interactive color
    
    // Semantic Colors
    static let accentGreen = Color("Green-app")      // Success states (fallback if asset missing)
    static let accentRed = Color("Red-app")          // Error/warning states
    
    // Text Colors (for dark backgrounds)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    static let textDisabled = Color.white.opacity(0.3)
}

// MARK: - Design System Gradients
struct AppGradients {
    /// Blue Glow Gradient - Primary buttons, hero sections
    static let blueGlow = LinearGradient(
        colors: [
            Color("mutedBlue"),
            Color("darkTeal")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Dark Glass Gradient - Cards, overlays
    static let darkGlass = LinearGradient(
        colors: [
            Color("Charcoal"),
            Color("deepNavy")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Accent Glow Gradient - Highlights, special states
    static let accentGlow = LinearGradient(
        colors: [
            Color("mutedBlue"),
            Color("Green-app")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Background gradient for main screens
    static let background = LinearGradient(
        colors: [
            Color("deepNavy"),
            Color("Charcoal").opacity(0.95)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography Style
struct TypographyStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat

    init(font: Font, color: Color, lineSpacing: CGFloat = 0) {
        self.font = font
        self.color = color
        self.lineSpacing = lineSpacing
    }
}

// MARK: - Typography System
struct Typography {
    // Display Styles (Hero sections, onboarding)
    let displayLarge: TypographyStyle
    let displayMedium: TypographyStyle
    let displaySmall: TypographyStyle
    
    // Headline Styles (Section headers, card titles)
    let headlineLarge: TypographyStyle
    let headlineMedium: TypographyStyle
    let headlineSmall: TypographyStyle
    
    // Title Styles (Component headers, labels)
    let titleLarge: TypographyStyle
    let titleMedium: TypographyStyle
    let titleSmall: TypographyStyle
    
    // Body Styles (Main content, descriptions)
    let bodyLarge: TypographyStyle
    let bodyMedium: TypographyStyle
    let bodySmall: TypographyStyle
    
    // Label Styles (Form labels, captions, metadata)
    let labelLarge: TypographyStyle
    let labelMedium: TypographyStyle
    let labelSmall: TypographyStyle
    
    // Legacy support
    let largeTitle: TypographyStyle
    let title: TypographyStyle
    let body: TypographyStyle
    let caption: TypographyStyle
    let primaryButton: TypographyStyle
    let secondaryButton: TypographyStyle

    static let warmnet = Typography(
        // Display Styles
        displayLarge: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 57).weight(.bold),
            color: .primary,
            lineSpacing: 8
        ),
        displayMedium: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 45).weight(.bold),
            color: .primary,
            lineSpacing: 6
        ),
        displaySmall: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 36).weight(.semibold),
            color: .primary,
            lineSpacing: 5
        ),
        
        // Headline Styles
        headlineLarge: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 32).weight(.semibold),
            color: .primary,
            lineSpacing: 4
        ),
        headlineMedium: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 28).weight(.semibold),
            color: .primary,
            lineSpacing: 4
        ),
        headlineSmall: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 24).weight(.semibold),
            color: .primary,
            lineSpacing: 3
        ),
        
        // Title Styles
        titleLarge: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 22),
            color: .primary,
            lineSpacing: 2
        ),
        titleMedium: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 16),
            color: .primary,
            lineSpacing: 2
        ),
        titleSmall: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 14),
            color: .primary,
            lineSpacing: 1
        ),
        
        // Body Styles
        bodyLarge: TypographyStyle(
            font: .custom(AppFontName.workSansRegular, size: 16),
            color: .primary,
            lineSpacing: 2
        ),
        bodyMedium: TypographyStyle(
            font: .custom(AppFontName.workSansRegular, size: 14),
            color: .primary,
            lineSpacing: 2
        ),
        bodySmall: TypographyStyle(
            font: .custom(AppFontName.workSansRegular, size: 12),
            color: .primary,
            lineSpacing: 1
        ),
        
        // Label Styles
        labelLarge: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 14),
            color: .secondary,
            lineSpacing: 1
        ),
        labelMedium: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 12),
            color: .secondary,
            lineSpacing: 1
        ),
        labelSmall: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 11),
            color: .secondary,
            lineSpacing: 1
        ),
        
        // Legacy support (mapped to new system)
        largeTitle: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 32).weight(.semibold),
            color: .primary,
            lineSpacing: 4
        ),
        title: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 24).weight(.semibold),
            color: .primary,
            lineSpacing: 2
        ),
        body: TypographyStyle(
            font: .custom(AppFontName.workSansRegular, size: 16),
            color: .primary,
            lineSpacing: 2
        ),
        caption: TypographyStyle(
            font: .custom(AppFontName.workSansRegular, size: 14),
            color: .secondary,
            lineSpacing: 1
        ),
        primaryButton: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 16),
            color: .white
        ),
        secondaryButton: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 16),
            color: AppColors.textSecondary
        )
    )
}

private struct TypographyEnvironmentKey: EnvironmentKey {
    static let defaultValue: Typography = .warmnet
}

extension EnvironmentValues {
    var typography: Typography {
        get { self[TypographyEnvironmentKey.self] }
        set { self[TypographyEnvironmentKey.self] = newValue }
    }
}

private struct TypographyModifier: ViewModifier {
    @Environment(\.typography) private var typography
    let style: KeyPath<Typography, TypographyStyle>

    func body(content: Content) -> some View {
        let style = typography[keyPath: style]
        content
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    func typography(_ style: KeyPath<Typography, TypographyStyle>) -> some View {
        modifier(TypographyModifier(style: style))
    }
}
