import SwiftUI

/// SwiftUI can briefly report invalid GeometryReader values while a view is
/// transitioning out. Frame modifiers reject negative and non-finite values,
/// so every animated geometry-derived dimension passes through this guard.
nonisolated func safeFrameDimension(_ value: CGFloat) -> CGFloat {
    guard value.isFinite else { return 0 }
    return max(0, value)
}

extension Color {
    // Zomato Sushi foundations used by the Burger customization concept.
    static let sushiRed = Color(red: 226 / 255, green: 55 / 255, blue: 68 / 255)
    static let sushiCoal = Color(red: 28 / 255, green: 28 / 255, blue: 28 / 255)
    static let sushiGrey = Color(red: 79 / 255, green: 79 / 255, blue: 79 / 255)
    static let sushiCanvas = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    static let sushiDivider = Color(red: 232 / 255, green: 232 / 255, blue: 232 / 255)
    // Compatibility aliases now resolve to the same light Sushi commerce
    // system so every legacy screen participates in the redesign.
    static let dishCanvas = sushiCanvas
    static let dishSurface = Color.white
    static let dishSurfaceRaised = Color.white
    static let dishRed = sushiRed
    static let dishRedDeep = Color(red: 184 / 255, green: 35 / 255, blue: 52 / 255)
    static let dishWarm = sushiRed
    static let dishSuccess = Color(red: 38 / 255, green: 126 / 255, blue: 91 / 255)
    static let dishMuted = sushiGrey

    // Retained for compatibility with settings and diagnostics.
    static let zomatoGreen = Color(red: 0.11, green: 0.55, blue: 0.28)
}

enum IngredientEditorStyle: Sendable {
    case cinematic
    case sushiCommerce
}

struct DishEditBackdrop: View {
    var body: some View {
        Color.sushiCanvas.ignoresSafeArea()
    }
}

struct DishCardModifier: ViewModifier {
    let radius: CGFloat
    let borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(Color.white, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.sushiDivider, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(0.045), radius: 8, y: 3)
    }
}

extension View {
    func dishCard(radius: CGFloat = 22, borderOpacity: Double = 0.12) -> some View {
        modifier(DishCardModifier(radius: radius, borderOpacity: borderOpacity))
    }
}

struct DishPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.sushiRed, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.sushiRed.opacity(configuration.isPressed ? 0.08 : 0.18), radius: 8, y: 3)
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.82), value: configuration.isPressed)
    }
}

struct DishGlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.sushiCoal)
            .frame(width: 44, height: 44)
            .background(configuration.isPressed ? Color.sushiDivider : Color.white, in: Circle())
            .overlay(Circle().stroke(Color.sushiDivider, lineWidth: 1).allowsHitTesting(false))
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
    }
}

struct DishStatusPill: View {
    let icon: String
    let text: String
    var tint: Color = .dishRed

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.09), in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.22), lineWidth: 0.8))
    }
}
