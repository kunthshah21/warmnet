# Design System Documentation

> A comprehensive design system for building modern, beautiful iOS applications with SwiftUI

---

## Overview

This design system is built to create sophisticated, modern iOS applications with a focus on:

- **Glassmorphism** and depth through layering
- **Smooth, purposeful animations** using SwiftUI defaults
- **Adaptive theming** with automatic light/dark mode support
- **Accessible, inclusive design** patterns
- **Consistent visual language** across the entire application

The system is optimized for SwiftUI and Swift 6, leveraging native components and animations for optimal performance.

---

## Design Philosophy

### Core Principles

#### 1. **Modern Minimalism**
- Embrace white space—don't clutter the interface
- Every element should serve a clear purpose
- Remove unnecessary decorations and chrome
- Let content breathe

#### 2. **Depth Through Layering**
- Use glassmorphism effects to create visual hierarchy
- Apply subtle shadows to establish depth
- Layer translucent surfaces for sophistication
- Create visual interest through overlapping elements

#### 3. **Fluid & Responsive**
- All interactions should feel natural and smooth
- Use SwiftUI's built-in spring animations
- Respect user motion preferences (reduce motion)
- Transitions should guide attention, not distract

#### 4. **Adaptive & Inclusive**
- Support both light and dark mode seamlessly
- Respect Dynamic Type settings
- Maintain WCAG AA contrast standards
- Design for VoiceOver and accessibility tools

#### 5. **Consistency Over Creativity**
- Reuse established patterns before inventing new ones
- Component library is your single source of truth
- Token-based design (never hardcode values)
- Predictable interactions build user confidence

---

## Color System

### Asset Naming Convention

All colors are stored as **Color Set assets** in the Asset Catalog and support both light and dark mode variants.

#### Background Colors
```
deepNavy          // Darkest background layer
backgroundDark    // Primary background (original #253237)
charcoal          // Secondary background, elevated surfaces
```

#### Accent Colors
```
beige             // Warm highlight color (#F6F1D1)
primaryBlue       // Primary interactive color (#64A6BD)
accentGreen       // Success states (#7BC8A4)
accentRed         // Error/warning states (#FF928B)
```

#### Semantic Usage

**Backgrounds**
- Use `deepNavy` for the deepest layer (app background)
- Use `backgroundDark` for primary surfaces (cards, modals)
- Use `charcoal` for elevated components (buttons, inputs)

**Interactive Elements**
- Use `primaryBlue` for all primary actions (buttons, links, active states)
- Use gradients combining `primaryBlue` with transparency for depth
- Hover/pressed states should use opacity variations (0.8 for pressed)

**Status & Feedback**
- Use `accentGreen` for success confirmations, positive trends
- Use `accentRed` for errors, destructive actions, negative trends
- Use `beige` for highlights, important callouts, selected states

**Text Hierarchy**
```
Primary text:    White (or dark color in light mode)
Secondary text:  White at 70% opacity
Tertiary text:   White at 50% opacity
Disabled text:   White at 30% opacity
```

### Gradients

Gradients add visual richness and should be used thoughtfully:

**Blue Glow Gradient** (Primary buttons, hero sections)
- Creates sense of depth and premium feel
- Combines multiple blue shades from light to dark
- Direction: Top-leading to bottom-trailing

**Dark Glass Gradient** (Cards, overlays)
- Subtle gradient from charcoal to deepNavy
- Creates glassmorphism effect when combined with blur
- Always pair with `.ultraThinMaterial` backdrop

**Accent Glow Gradient** (Highlights, special states)
- Combines primaryBlue → accentGreen
- Use sparingly for premium features or calls-to-action

### Light Mode Adaptation

Colors automatically adapt based on system appearance:
- Background colors become lighter variants
- Text colors invert (dark on light)
- Accent colors remain consistent but adjust saturation
- Ensure all color assets have both appearances configured

---

## Typography

### Custom Font Family

The design system uses **Work Sans** and **Overpass** for a modern, professional aesthetic.

#### Font Files Required
```
WorkSans-Medium.ttf
WorkSans-Regular.ttf
Overpass-Regular.ttf (or other weights as needed)
```

#### Font Registration
Ensure fonts are:
1. Added to the project target
2. Listed in Info.plist under "Fonts provided by application"
3. Properly registered before first use

### Type Scale

Use semantic naming for font sizes—never reference specific point sizes directly:

#### Display Styles (Hero sections, onboarding)
```
displayLarge      // 57pt, Bold, Work Sans Medium
displayMedium     // 45pt, Bold, Work Sans Medium  
displaySmall      // 36pt, Semibold, Work Sans Medium
```

#### Headline Styles (Section headers, card titles)
```
headlineLarge     // 32pt, Semibold, Work Sans Medium
headlineMedium    // 28pt, Semibold, Work Sans Medium
headlineSmall     // 24pt, Semibold, Work Sans Medium
```

#### Title Styles (Component headers, labels)
```
titleLarge        // 22pt, Medium, Work Sans Medium
titleMedium       // 16pt, Medium, Work Sans Medium
titleSmall        // 14pt, Medium, Work Sans Medium
```

#### Body Styles (Main content, descriptions)
```
bodyLarge         // 16pt, Regular, Work Sans Regular
bodyMedium        // 14pt, Regular, Work Sans Regular
bodySmall         // 12pt, Regular, Work Sans Regular
```

#### Label Styles (Form labels, captions, metadata)
```
labelLarge        // 14pt, Medium, Work Sans Medium
labelMedium       // 12pt, Medium, Work Sans Medium
labelSmall        // 11pt, Medium, Work Sans Medium
```

### Typography Guidelines

**Hierarchy**
- Never skip levels (don't jump from displayLarge to bodySmall)
- Maintain consistent hierarchy throughout a screen
- Use font weight and size together to establish importance

**Readability**
- Line height should be 1.4-1.6x the font size for body text
- Maximum line length: ~60-70 characters for optimal readability
- Allow text to scale with Dynamic Type settings

**Pairing**
- Use Work Sans Medium for headings and emphasis
- Use Work Sans Regular for body text and longer content
- Overpass can be used for special UI elements or data displays
- Don't mix more than 2 font families on a single screen

**Color Pairing**
- Primary content uses primary text color (white in dark mode)
- Supplementary information uses secondary text color (70% opacity)
- Metadata and timestamps use tertiary text color (50% opacity)

---

## Spacing & Layout

### Spacing Scale

All spacing uses a **consistent 4-point grid system**:

```
xxxs: 2pt    // Micro adjustments only
xxs:  4pt    // Tight spacing in compact UIs
xs:   8pt    // Minimum touch target padding
sm:   12pt   // Compact spacing between related items
md:   16pt   // Default spacing (cards, components)
lg:   24pt   // Section spacing
xl:   32pt   // Major section breaks
xxl:  48pt   // Screen-level spacing
xxxl: 64pt   // Dramatic separation
```

### Semantic Spacing

**Component Internal Padding**
- Cards: `md` (16pt)
- Buttons: `sm` horizontal, `xs` vertical for compact, `md` for regular
- Input fields: `md` all around
- List items: `md` horizontal, `sm` vertical

**Component External Margins**
- Between cards: `md` (16pt)
- Between sections: `lg` (24pt) 
- Screen edges: `lg` (24pt) minimum
- Bottom navigation padding: `md` above safe area

**Layout Patterns**
- Use `VStack` and `HStack` with consistent spacing values
- Apply `.padding()` using semantic constants
- Never hardcode spacing values—always reference tokens

### Grid System

For multi-column layouts:
- Default: 2 columns on iPhone, 3-4 on iPad
- Gutter width: `md` (16pt)
- Outer margins: `lg` (24pt)

---

## Component Patterns

### Glass Cards

**When to Use**
- Primary content containers
- Elevated surfaces over busy backgrounds
- Modal overlays and bottom sheets

**Key Characteristics**
- Background: Gradient from `charcoal` to `deepNavy` with opacity
- Backdrop: `.ultraThinMaterial` blur effect
- Border: 1pt white at 10% opacity
- Corner radius: `xl` (24pt) for large cards, `lg` (16pt) for medium
- Shadow: Medium elevation with 15% opacity

**Variants**
- **Standard Glass**: Default styling, subtle depth
- **Selected Glass**: Add `primaryBlue` border (1.5pt), slight scale (1.02)
- **Interactive Glass**: Responds to press with scale (0.98) and opacity change

### Buttons

**Primary Button**
- Background: Blue glow gradient
- Text: White, `labelLarge` font
- Padding: `md` vertical, `lg` horizontal  
- Corner radius: `lg` (16pt)
- Shadow: Blue glow shadow for depth
- Press state: Scale to 0.95, opacity to 0.8

**Secondary Button (Outlined)**
- Background: Clear
- Border: `primaryBlue` at 1.5pt
- Text: `primaryBlue`, `labelLarge` font
- Same padding and radius as primary
- Press state: Background fills with `primaryBlue` at 10% opacity

**Ghost Button**
- Background: Clear, no border
- Text: `primaryBlue`, `labelMedium` font
- Minimal padding: `sm` all around
- Press state: Background `primaryBlue` at 5% opacity

**Icon Buttons**
- Size: 44x44pt minimum (touch target)
- Background: Glass effect or solid `charcoal`
- Icon color: Primary text color
- Circular shape preferred for standalone icons
- Press state: Scale to 0.9

### Cards & Lists

**Standard Card**
- Background: `charcoal`
- Padding: `md` (16pt)
- Corner radius: `lg` (16pt)
- Shadow: Medium elevation
- Spacing between cards: `md`

**Selection Card**
- Visual indicator (radio/checkbox) on leading edge
- Selected state: Blue gradient background, blue border
- Unselected state: Dark glass background, subtle border
- Entire card is tappable
- Smooth spring animation on selection change

**List Items**
- Divider: 1pt line at 10% opacity between items
- Active state: Subtle background highlight
- Swipe actions: Reveal actions with color-coded backgrounds (green for success, red for delete)

### Input Fields

**Text Input**
- Background: `charcoal`
- Border: 1pt white at 10% opacity (default), `primaryBlue` when focused
- Padding: `md` all around
- Corner radius: `lg` (16pt)
- Icon placement: Leading edge, `sm` spacing from text
- Label: Above input, `labelMedium` font, secondary text color

**Search Field**
- Magnifying glass icon on leading edge
- Clear button (X) on trailing edge when text exists
- Background: Slightly lighter than standard input
- Placeholder: Tertiary text color

**Selection Controls**
- Radio buttons: Circular, 20pt diameter, `primaryBlue` when selected
- Checkboxes: Rounded square (4pt radius), 20pt size
- Toggles: iOS native style, tint color `primaryBlue`
- Minimum touch target: 44x44pt around each control

### Navigation

**Top Navigation Bar**
- Height: 44pt content + safe area inset
- Background: `backgroundDark` or transparent over content
- Title: `titleLarge`, centered or leading-aligned
- Action buttons: Icon buttons, 44x44pt
- Divider: Optional 1pt line at bottom

**Bottom Tab Bar**
- Background: `deepNavy` with `.ultraThinMaterial`
- Shape: Rounded rectangle (32pt radius) with padding from edges
- Height: 56pt + safe area inset
- Icons: 24pt, selected icons filled
- Labels: `labelSmall`, optional below icons
- Selected indicator: `primaryBlue` icon and text color
- Shadow: Large elevation for floating effect

**Navigation Transitions**
- Push/pop: Slide from trailing edge (default iOS behavior)
- Modal present: Slide up from bottom
- Sheet: Partial sheet with drag dismiss
- All transitions: Use SwiftUI defaults with `.animation(.default)`

---

## Animation Guidelines

### SwiftUI Default Animations

**Always use native SwiftUI animations** for consistency and performance:

#### Spring Animations (Preferred for interactions)
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)
```
- Use for: Button presses, selections, toggles
- Natural, bouncy feel that's satisfying
- Response: 0.3 seconds is ideal for UI interactions

#### Easing Animations (For transitions)
```swift
.animation(.easeInOut(duration: 0.25), value: state)
.animation(.easeOut(duration: 0.2), value: state)
```
- Use for: Fades, opacity changes, non-interactive movements
- Smooth, predictable motion
- Duration: 0.2-0.3 seconds for most cases

#### Default Animation (Quick & easy)
```swift
.animation(.default, value: state)
```
- SwiftUI's smart default animation
- Use when you don't need specific timing
- Handles most cases appropriately

### Animation Use Cases

**Button Press**
```
Scale from 1.0 → 0.95 → 1.0
Duration: Spring animation (0.3s response)
When: onTapGesture or Button press
```

**Card Selection**
```
Border color change + scale to 1.02
Duration: Spring animation (0.3s)
Glow shadow fades in
```

**Navigation Transitions**
```
Use native SwiftUI NavigationStack transitions
Modal: .sheet modifier with default animation
Fullscreen: .fullScreenCover with slide up
```

**Tab Switching**
```
Content cross-fade with .transition(.opacity)
Tab indicator slides with spring animation
Icon color/fill animates with .easeOut
```

**Loading States**
```
Use native ProgressView (indeterminate)
Skeleton loaders: Shimmer effect with .easeInOut
Duration: 1.5s repeating animation
```

**Micro-interactions**
```
Toggle switches: Native SwiftUI animation
Checkboxes: Scale + checkmark draw (spring)
List item swipe: Follow finger with .interactiveSpring()
```

### Animation Performance

**Best Practices**
- Animate layout changes with `.animation()` modifier on specific values
- Use `.id()` to force view recreation when needed
- Prefer `@State` changes over manual animations
- Group related animations with `withAnimation { }` blocks

**What NOT to Animate**
- Avoid animating large images/photos
- Don't animate complex path drawing unless necessary
- Skip animations for long lists (use `.animation(nil)` on ForEach)
- Respect `.accessibilityReduceMotion` preference

### Accessibility: Reduce Motion

**Always check for reduce motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditionally apply animations
.animation(reduceMotion ? nil : .spring(), value: state)
```

When reduce motion is enabled:
- Disable decorative animations entirely
- Keep essential state change animations but simplify (no spring, just instant)
- Cross-fades are acceptable (opacity changes)
- Position changes should be instant or very quick

---

## Accessibility

### Minimum Requirements

**Color Contrast**
- Text on background: Minimum 4.5:1 ratio (WCAG AA)
- Large text (18pt+): Minimum 3:1 ratio
- Interactive elements: 3:1 against adjacent colors
- Test both light and dark mode

**Touch Targets**
- Minimum size: 44x44pt for all interactive elements
- Spacing between targets: 8pt minimum
- Expand hit area invisibly if visual size is smaller

**Dynamic Type**
- Support all system text size categories
- Test at largest accessibility sizes
- Allow text to wrap, never truncate critical info
- Scale spacing proportionally with text size

**VoiceOver Support**
- All interactive elements need labels
- Provide hints for complex interactions
- Group related elements logically
- Announce state changes with `.accessibilityValue()`

### Implementation

**Labels**
```swift
// Always provide accessibility labels
Image(systemName: "star.fill")
    .accessibilityLabel("Favorite")

// Combine elements into single VoiceOver item
HStack {
    Image(systemName: "person")
    Text("John Doe")
}
.accessibilityElement(children: .combine)
```

**Traits**
```swift
// Identify element types
Button("Submit") { }
    .accessibilityAddTraits(.isButton)

// Indicate state
Toggle("Notifications", isOn: $enabled)
    .accessibilityValue(enabled ? "On" : "Off")
```

**Hidden Elements**
```swift
// Hide decorative elements from VoiceOver
Image("decorative-background")
    .accessibilityHidden(true)
```

**Dynamic Type**
```swift
// Text automatically scales, but test layout
Text("Long content here")
    .font(.bodyMedium) // Uses Dynamic Type
    .lineLimit(nil) // Allow wrapping
```

### Testing Checklist

- [ ] Run with VoiceOver enabled
- [ ] Test with largest text size
- [ ] Verify color contrast ratios
- [ ] Test with reduce motion enabled
- [ ] Check with accessibility inspector
- [ ] Navigate entirely with VoiceOver
- [ ] Verify all buttons announce correctly

---

## Best Practices

### Component Usage

#### DO ✅
- Use design tokens (spacing, colors) from asset catalog
- Build new components from existing patterns
- Test components in both light and dark mode
- Provide default states for all optional parameters
- Use semantic naming (`primaryButton` not `blueButton`)
- Group related properties in component parameters

#### DON'T ❌
- Hardcode color values in components
- Use magic numbers for spacing (always reference tokens)
- Create one-off components for simple layouts
- Override system fonts without good reason
- Ignore accessibility in custom components
- Build complex components without breaking into smaller views

### Layout Guidelines

#### DO ✅
- Use native SwiftUI layout containers (VStack, HStack, ZStack)
- Apply padding to inner content, not outer containers
- Use `Spacer()` for flexible spacing
- Test layouts on multiple device sizes
- Consider landscape orientation
- Use `.frame()` sparingly, prefer intrinsic sizing

#### DON'T ❌
- Use absolute positioning unless absolutely necessary
- Create deeply nested view hierarchies (max 10 levels)
- Hardcode frame sizes for standard UI elements
- Forget about iPad and larger displays
- Ignore safe area insets
- Use GeometryReader when simple layouts will work

### State Management

#### DO ✅
- Keep state as local as possible
- Use `@State` for view-local state
- Use `@Binding` to share state with child views
- Extract complex logic into view models
- Animate state changes consistently
- Consider state persistence needs early

#### DON'T ❌
- Put all state at the root level
- Mutate state during view rendering
- Forget to mark state variables properly
- Create unnecessarily complex state structures
- Ignore state reset needs on view disappear

### Code Organization

```
DesignSystem/
├── Colors/
│   ├── Assets.xcassets (Color sets)
│   └── ColorTokens.swift (Semantic naming)
├── Typography/
│   ├── Fonts/ (Font files)
│   └── Typography.swift (Type scale)
├── Spacing/
│   └── Spacing.swift (Spacing tokens)
├── Components/
│   ├── Buttons/
│   ├── Cards/
│   ├── Inputs/
│   └── Navigation/
├── Modifiers/
│   └── ViewModifiers.swift (Reusable modifiers)
└── Utilities/
    └── Extensions.swift (Helpers)
```

### Performance Optimization

#### DO ✅
- Use `LazyVStack`/`LazyHStack` for long lists
- Implement pagination for large data sets
- Cache computed values when appropriate
- Use `@ViewBuilder` for conditional views
- Profile with Instruments regularly
- Optimize image sizes for display resolution

#### DON'T ❌
- Load all data at once for large lists
- Perform heavy calculations in view body
- Create new objects on every render
- Ignore memory warnings
- Use high-resolution images unnecessarily
- Animate view hierarchies that are too deep

---

## Code Examples

### Using Color Tokens

```swift
// ✅ CORRECT
Text("Hello")
    .foregroundColor(Color("primaryBlue"))

VStack {
    // content
}
.background(Color("backgroundDark"))

// ❌ INCORRECT - Never hardcode
Text("Hello")
    .foregroundColor(Color(red: 0.39, green: 0.65, blue: 0.74))
```

### Using Spacing Tokens

```swift
// ✅ CORRECT - Define constants
struct Spacing {
    static let xs: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
}

VStack(spacing: Spacing.md) {
    Text("Title")
    Text("Subtitle")
}
.padding(Spacing.lg)

// ❌ INCORRECT
VStack(spacing: 16) {
    Text("Title")
    Text("Subtitle")
}
.padding(.all, 24)
```

### Custom Font Implementation

```swift
// Create a Typography helper
struct Typography {
    static let displayLarge = Font.custom("WorkSans-Medium", size: 57)
    static let bodyMedium = Font.custom("WorkSans-Regular", size: 14)
    static let labelSmall = Font.custom("WorkSans-Medium", size: 11)
}

// Usage
Text("Welcome")
    .font(Typography.displayLarge)
    
Text("Description text")
    .font(Typography.bodyMedium)
```

### Glass Card Component

```swift
// Reusable glass card
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// Usage
GlassCard {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        Text("Card Title")
            .font(Typography.titleLarge)
        Text("Card description")
            .font(Typography.bodyMedium)
    }
}
```

### Animated Button

```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(Typography.labelLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    LinearGradient(
                        colors: [
                            Color("primaryBlue"),
                            Color("primaryBlue").opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
```

### Accessible Component

```swift
struct IconButton: View {
    let icon: String
    let label: String // For accessibility
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color("textPrimary"))
                .frame(width: 44, height: 44)
                .background(Color("charcoal"))
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

// Usage
IconButton(icon: "heart.fill", label: "Add to favorites") {
    // action
}
```

### Reduce Motion Support

```swift
struct AnimatedCard: View {
    @State private var isExpanded = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack {
            // content
        }
        .frame(height: isExpanded ? 300 : 100)
        .animation(
            reduceMotion ? nil : .spring(response: 0.3),
            value: isExpanded
        )
    }
}
```

---

## Design System Checklist

Use this checklist when implementing new screens or features:

### Visual Design
- [ ] All colors use asset catalog tokens (no hardcoded hex values)
- [ ] Spacing uses defined constants (no magic numbers)
- [ ] Typography uses custom fonts (Work Sans, Overpass)
- [ ] Components use appropriate corner radius values
- [ ] Shadows are consistent with elevation system
- [ ] Design works in both light and dark mode

### Components
- [ ] Reusing existing components where possible
- [ ] New components follow established patterns
- [ ] Interactive elements have minimum 44x44pt touch targets
- [ ] Buttons have appropriate press states
- [ ] Cards use glass effect or elevated style consistently

### Animation
- [ ] Animations use SwiftUI defaults (.spring, .easeInOut)
- [ ] Reduce motion preference is respected
- [ ] Animation timing is consistent (0.2-0.3s for most)
- [ ] No janky or performance-heavy animations
- [ ] State changes animate smoothly

### Accessibility
- [ ] All interactive elements have accessibility labels
- [ ] Color contrast meets WCAG AA standards (4.5:1)
- [ ] VoiceOver navigation works correctly
- [ ] Dynamic Type is supported
- [ ] Works with reduce motion enabled
- [ ] Works with high contrast mode

### Code Quality
- [ ] No hardcoded values (colors, spacing, sizes)
- [ ] View hierarchies are not too deep (max 10 levels)
- [ ] State management is appropriate for component
- [ ] Code is readable and well-commented
- [ ] Preview providers exist for development
- [ ] Component is documented with usage examples

### Testing
- [ ] Tested on iPhone (multiple sizes)
- [ ] Tested on iPad (if applicable)
- [ ] Tested in landscape orientation
- [ ] Tested with VoiceOver enabled
- [ ] Tested with largest Dynamic Type size
- [ ] Tested in both light and dark mode

---

## Quick Reference

### Most Common Components

**Button**: Primary actions → Use `PrimaryButton` with blue gradient  
**Card**: Content container → Use `GlassCard` or `ElevatedCard`  
**Input**: Text entry → Use `CustomTextField` with charcoal background  
**Navigation**: Bottom tabs → Use custom `BottomTabBar` with glassmorphism  
**List Item**: Repeated content → Use standard card in VStack with spacing

### Most Common Colors

**Background**: `deepNavy` (app), `backgroundDark` (surfaces), `charcoal` (elevated)  
**Interactive**: `primaryBlue` (buttons, links, active states)  
**Success**: `accentGreen`  
**Error**: `accentRed`  
**Highlight**: `beige`

### Most Common Spacing

**Internal padding**: `md` (16pt)  
**Between elements**: `sm` (12pt)  
**Between sections**: `lg` (24pt)  
**Screen edges**: `lg` (24pt)

### Most Common Animations

**Button press**: `.spring(response: 0.3, dampingFraction: 0.7)`  
**State change**: `.easeInOut(duration: 0.25)`  
**Default**: `.animation(.default, value: state)`

---

## Support & Contribution

### Questions?
When implementing from this design system, always:
1. Check if a pattern already exists
2. Reuse before creating new
3. Follow the principles outlined here
4. Test for accessibility
5. Maintain consistency above all else

### Updates
This design system evolves with the product. When adding new patterns:
- Document the component clearly
- Provide code examples
- Show both light and dark mode
- Include accessibility considerations
- Update this README

---

**Remember**: Consistency is more valuable than perfection. When in doubt, follow existing patterns. This design system is your source of truth for building beautiful, accessible, and performant iOS applications.

---

*Last updated: January 2026*  
*Version: 1.0*  
*Platform: iOS 26+ • SwiftUI • Swift 6*