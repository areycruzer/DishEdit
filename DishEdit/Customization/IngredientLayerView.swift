import SwiftUI

struct IngredientLayerView: View {
    let ingredient: IngredientDefinition
    let transform: IngredientTransform
    let canvasSize: CGSize
    let isPresent: Bool
    let canToggle: Bool
    var style: IngredientEditorStyle = .cinematic
    let onTap: () -> Void

    var body: some View {
        ZStack {
            calloutLine

            ingredientImage
                .position(imagePoint)
                .allowsHitTesting(false)

            Button {
                guard canToggle else {
                    HapticDirector.reject()
                    return
                }
                HapticDirector.selection()
                onTap()
            } label: {
                Color.clear
                    .frame(width: interactionSize, height: interactionSize)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .position(imagePoint)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ingredient.accessibilityDescription)
            .accessibilityValue(isPresent ? "present" : "removed")
            .accessibilityHint(accessibilityHint)
            .accessibilityIdentifier("layer.\(ingredient.id)")
            .accessibilityAction(named: isPresent ? "Remove" : "Restore") { onTap() }

            label
                .position(labelPoint)
                .allowsHitTesting(false)
        }
    }

    private var ingredientImage: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(style == .sushiCommerce ? 0.08 : 0.28))
                .frame(width: imageSize * 0.86, height: imageSize * 0.86)
                .blur(radius: 9)

            BundledImage.image(named: ingredient.layerAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .rotationEffect(.degrees(transform.rotationDegrees))
                .saturation(isPresent ? 1 : 0.1)
                .opacity(isPresent ? transform.opacity : 0.22)
                .shadow(color: .black.opacity(style == .sushiCommerce ? 0.18 : 0.58), radius: style == .sushiCommerce ? 8 : 12, y: style == .sushiCommerce ? 4 : 8)

            if !isPresent {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(style == .sushiCommerce ? .title : .title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, style == .sushiCommerce ? Color.sushiRed : Color.dishRed)
                    .padding(6)
                    .background(.black.opacity(0.62), in: Circle())
            } else if ingredient.canRemove {
                Image(systemName: "minus.circle.fill")
                    .font(style == .sushiCommerce ? .system(size: 29, weight: .bold) : .caption)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, style == .sushiCommerce ? Color.sushiRed : Color.dishRed)
                    .offset(x: imageSize * 0.33, y: -imageSize * 0.29)
                    .background {
                        if style == .sushiCommerce {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 31, height: 31)
                                .offset(x: imageSize * 0.33, y: -imageSize * 0.29)
                                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                        }
                    }
            } else if ingredient.canAdd {
                Image(systemName: "checkmark.circle.fill")
                    .font(style == .sushiCommerce ? .system(size: 29, weight: .bold) : .caption)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.dishSuccess)
                    .offset(x: imageSize * 0.33, y: -imageSize * 0.29)
            }
        }
        .frame(width: max(imageSize, 56), height: max(imageSize, 56))
        .contentShape(Circle())
    }

    private var label: some View {
        HStack(spacing: 4) {
            if style == .cinematic {
                Circle()
                    .fill(labelTint)
                    .frame(width: 6, height: 6)
            }
            Text(ingredient.name)
                .font(.system(size: style == .sushiCommerce ? 12 : 9.5, weight: style == .sushiCommerce ? .semibold : .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(
            style == .sushiCommerce
                ? (isPresent ? Color.sushiCoal : Color.sushiGrey.opacity(0.55))
                : (isPresent ? Color.white.opacity(0.9) : Color.white.opacity(0.46))
        )
        .padding(.horizontal, style == .sushiCommerce ? 10 : 6)
        .padding(.vertical, style == .sushiCommerce ? 7 : 6)
        .frame(maxWidth: style == .sushiCommerce ? 128 : 108)
        .background(style == .sushiCommerce ? Color.white : Color.black.opacity(0.72), in: Capsule())
        .overlay(Capsule().stroke(labelTint.opacity(isPresent ? 0.34 : 0.14), lineWidth: 0.8))
        .shadow(color: .black.opacity(style == .sushiCommerce ? 0.08 : 0), radius: 4, y: 2)
    }

    private var calloutLine: some View {
        Path { path in
            path.move(to: imagePoint)
            path.addLine(to: labelPoint)
        }
        .stroke(labelTint.opacity(isPresent ? (style == .sushiCommerce ? 0.3 : 0.44) : 0.16), style: StrokeStyle(lineWidth: style == .sushiCommerce ? 1.1 : 0.8, dash: [3, 3]))
        .allowsHitTesting(false)
    }

    private var imagePoint: CGPoint {
        CGPoint(
            x: canvasSize.width * CGFloat(transform.center.x),
            y: canvasSize.height * CGFloat(transform.center.y)
        )
    }

    private var labelPoint: CGPoint {
        let x = canvasSize.width * CGFloat(transform.center.x + transform.labelOffset.x)
        let y = canvasSize.height * CGFloat(transform.center.y + transform.labelOffset.y)
        return CGPoint(
            x: min(max(x, style == .sushiCommerce ? 72 : 64), canvasSize.width - (style == .sushiCommerce ? 72 : 64)),
            y: min(max(y, style == .sushiCommerce ? 24 : 20), canvasSize.height - (style == .sushiCommerce ? 24 : 20))
        )
    }

    private var imageSize: CGFloat {
        let base: CGFloat = switch (style, ingredient.role) {
        case (.sushiCommerce, .base): 142
        case (.sushiCommerce, .protein): 132
        case (.sushiCommerce, .cheese), (.sushiCommerce, .vegetable): 118
        case (.sushiCommerce, .sauce), (.sushiCommerce, .topping): 108
        case (.cinematic, .base): 102
        case (.cinematic, .protein): 92
        case (.cinematic, .cheese), (.cinematic, .vegetable): 78
        case (.cinematic, .sauce), (.cinematic, .topping): 70
        }
        return base * CGFloat(transform.scale)
    }

    /// Keep the large food photography visually generous without letting
    /// neighbouring exploded layers steal one another's taps.
    private var interactionSize: CGFloat {
        style == .sushiCommerce ? 58 : max(min(imageSize, 56), 44)
    }

    private var labelTint: Color {
        if !isPresent { return style == .sushiCommerce ? .sushiGrey : .dishMuted }
        if ingredient.canRemove { return style == .sushiCommerce ? .sushiRed : .dishRed }
        if ingredient.canAdd { return .dishSuccess }
        return .dishWarm
    }

    private var accessibilityHint: String {
        guard canToggle else { return "Fixed recipe layer" }
        return isPresent ? "Double-tap to remove" : "Double-tap to restore"
    }
}
