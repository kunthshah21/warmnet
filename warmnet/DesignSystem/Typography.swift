import SwiftUI

enum AppFontName {
    static let overpassVariable = "Overpass-VariableFont_wght"
    static let workSansMedium = "WorkSans-Medium"
    static let workSansRegular = "WorkSans-Regular"
}

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

struct Typography {
    let largeTitle: TypographyStyle
    let title: TypographyStyle
    let body: TypographyStyle
    let caption: TypographyStyle
    let primaryButton: TypographyStyle
    let secondaryButton: TypographyStyle

    static let warmnet = Typography(
        largeTitle: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 32),
            color: .primary,
            lineSpacing: 4
        ),
        title: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 24),
            color: .primary,
            lineSpacing: 2
        ),
        body: TypographyStyle(
            font: .custom(AppFontName.overpassVariable, size: 16),
            color: .primary,
            lineSpacing: 2
        ),
        caption: TypographyStyle(
            font: .custom(AppFontName.overpassVariable, size: 14),
            color: .secondary,
            lineSpacing: 1
        ),
        primaryButton: TypographyStyle(
            font: .custom(AppFontName.workSansMedium, size: 16),
            color: .white
        ),
        secondaryButton: TypographyStyle(
            font: .custom(AppFontName.overpassVariable, size: 16),
            color: Color(red: 0.34, green: 0.34, blue: 0.34)
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
