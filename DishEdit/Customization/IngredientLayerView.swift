import SwiftUI

struct IngredientLayerView: View {
    let ingredient: IngredientDefinition
    let transform: IngredientTransform
    let canvasSize: CGSize
    let isPresent: Bool
    let canToggle: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            calloutLine

            Button {
                guard canToggle else {
                    HapticDirector.reject()
                    return
                }
                HapticDirector.selection()
                onTap()
            } label: {
                ingredientImage
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
                .fill(Color.black.opacity(0.28))
                .frame(width: imageSize * 0.86, height: imageSize * 0.86)
                .blur(radius: 9)

            BundledImage.image(named: ingredient.layerAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .rotationEffect(.degrees(transform.rotationDegrees))
                .saturation(isPresent ? 1 : 0.1)
                .opacity(isPresent ? transform.opacity : 0.22)
                .shadow(color: .black.opacity(0.58), radius: 12, y: 8)

            if !isPresent {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.dishRed)
                    .padding(6)
                    .background(.black.opacity(0.62), in: Circle())
            } else if ingredient.canRemove {
                Image(systemName: "minus.circle.fill")
                    .font(.caption)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.dishRed)
                    .offset(x: imageSize * 0.33, y: -imageSize * 0.29)
            } else if ingredient.canAdd {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
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
            Circle()
                .fill(labelTint)
                .frame(width: 6, height: 6)
            Text(ingredient.name)
                .font(.system(size: 9.5, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isPresent ? .white.opacity(0.9) : .white.opacity(0.46))
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(maxWidth: 108)
        .background(.black.opacity(0.72), in: Capsule())
        .overlay(Capsule().stroke(labelTint.opacity(isPresent ? 0.48 : 0.18), lineWidth: 0.7))
    }

    private var calloutLine: some View {
        Path { path in
            path.move(to: imagePoint)
            path.addLine(to: labelPoint)
        }
        .stroke(labelTint.opacity(isPresent ? 0.44 : 0.16), style: StrokeStyle(lineWidth: 0.8, dash: [3, 3]))
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
            x: min(max(x, 64), canvasSize.width - 64),
            y: min(max(y, 20), canvasSize.height - 20)
        )
    }

    private var imageSize: CGFloat {
        let base: CGFloat = switch ingredient.role {
        case .base: 102
        case .protein: 92
        case .cheese, .vegetable: 78
        case .sauce, .topping: 70
        }
        return base * CGFloat(transform.scale)
    }

    private var labelTint: Color {
        if !isPresent { return .dishMuted }
        if ingredient.canRemove { return .dishRed }
        if ingredient.canAdd { return .dishSuccess }
        return .dishWarm
    }

    private var accessibilityHint: String {
        guard canToggle else { return "Fixed recipe layer" }
        return isPresent ? "Double-tap to remove" : "Double-tap to restore"
    }
}
