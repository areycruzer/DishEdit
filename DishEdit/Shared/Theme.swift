import SwiftUI

/// SwiftUI can briefly report invalid GeometryReader values while a view is
/// transitioning out. Frame modifiers reject negative and non-finite values,
/// so every animated geometry-derived dimension passes through this guard.
nonisolated func safeFrameDimension(_ value: CGFloat) -> CGFloat {
    guard value.isFinite else { return 0 }
    return max(0, value)
}

extension Color {
    static let dishCanvas = Color(red: 0.025, green: 0.023, blue: 0.026)
    static let dishSurface = Color(red: 0.075, green: 0.068, blue: 0.074)
    static let dishSurfaceRaised = Color(red: 0.115, green: 0.102, blue: 0.111)
    static let dishRed = Color(red: 0.91, green: 0.08, blue: 0.16)
    static let dishRedDeep = Color(red: 0.48, green: 0.015, blue: 0.055)
    static let dishWarm = Color(red: 1.0, green: 0.62, blue: 0.28)
    static let dishSuccess = Color(red: 0.28, green: 0.82, blue: 0.53)
    static let dishMuted = Color.white.opacity(0.58)

    // Retained for compatibility with settings and diagnostics.
    static let zomatoGreen = Color(red: 0.11, green: 0.55, blue: 0.28)
}

struct DishEditBackdrop: View {
    var body: some View {
        ZStack {
            Color.dishCanvas

            RadialGradient(
                colors: [Color.dishRed.opacity(0.17), .clear],
                center: UnitPoint(x: 0.86, y: 0.06),
                startRadius: 0,
                endRadius: 360
            )

            RadialGradient(
                colors: [Color.dishWarm.opacity(0.055), .clear],
                center: UnitPoint(x: 0.08, y: 0.72),
                startRadius: 0,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

struct DishCardModifier: ViewModifier {
    let radius: CGFloat
    let borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.075), Color.white.opacity(0.025)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: radius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 0.8)
                    .allowsHitTesting(false)
            }
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
            .background(
                LinearGradient(
                    colors: [Color.dishRed, Color(red: 0.72, green: 0.025, blue: 0.09)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 0.8)
                    .allowsHitTesting(false)
            }
            .shadow(color: Color.dishRed.opacity(configuration.isPressed ? 0.12 : 0.32), radius: 18, y: 8)
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.82), value: configuration.isPressed)
    }
}

struct DishGlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(configuration.isPressed ? 0.12 : 0.065), in: Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.8).allowsHitTesting(false))
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
            .foregroundStyle(.white.opacity(0.88))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.16), in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.36), lineWidth: 0.8))
    }
}
