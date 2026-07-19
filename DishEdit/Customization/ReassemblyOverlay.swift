import SwiftUI

struct ReassemblyOverlay: View {
    let product: ProductDefinition
    let modifierSummary: [ModifierSummaryItem]
    let basePricePaise: Int
    let priceDeltaPaise: Int
    let previewAssetName: String?
    let onDone: () -> Void

    @State private var progress = 0.0
    @State private var phaseIndex = 0
    @State private var isReady = false
    @State private var scanTravel = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let phases = [
        "Reading your edits",
        "Rebuilding selected regions",
        "Preserving recipe truth",
        "Preview ready"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.97).ignoresSafeArea()

            RadialGradient(
                colors: [Color.dishRed.opacity(0.22), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 330
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                processingHeader
                previewStage
                progressPanel
                modificationSummary
                Spacer(minLength: 0)
                confirmationButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 14)
        }
        .preferredColorScheme(.dark)
        .task { await runReconstruction() }
    }

    private var processingHeader: some View {
        VStack(spacing: 7) {
            DishStatusPill(
                icon: isReady ? "checkmark.seal.fill" : "cpu.fill",
                text: isReady ? "PREVIEW COMPLETE" : "ON-DEVICE VISUAL REBUILD",
                tint: isReady ? .dishSuccess : .dishRed
            )

            Text(isReady ? "Your dish, rebuilt" : "Making the edit visible")
                .font(.system(size: 27, weight: .bold, design: .rounded))

            Text("Catalog choices stay exact while the photograph catches up.")
                .font(.caption)
                .foregroundStyle(Color.dishMuted)
                .multilineTextAlignment(.center)
        }
    }

    private var previewStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.dishSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 0.8)
                )

            Circle()
                .fill(Color.dishRed.opacity(isReady ? 0.08 : 0.18))
                .frame(width: 250, height: 250)
                .blur(radius: 45)

            BundledImage.image(named: previewAssetName ?? product.assembledAssetName)
                .resizable()
                .scaledToFit()
                .padding(8)
                .scaleEffect(isReady ? 1 : 0.96)
                .saturation(isReady ? 1 : 0.76)
                .blur(radius: isReady ? 0 : 0.35)
                .shadow(color: .black.opacity(0.72), radius: 22, y: 15)

            if !isReady {
                processingMesh
            }

            if isReady {
                VStack {
                    Spacer()
                    HStack(spacing: 7) {
                        Image(systemName: "sparkles")
                        Text("VISUAL PREVIEW")
                            .tracking(1)
                    }
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.black.opacity(0.72), in: Capsule())
                    .padding(.bottom, 14)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .frame(maxWidth: 440)
        .frame(height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .animation(.easeInOut(duration: 0.35), value: isReady)
        .accessibilityLabel(isReady ? "Finished visual preview of \(product.name)" : "Rebuilding visual preview")
    }

    private var processingMesh: some View {
        GeometryReader { proxy in
            ZStack {
                Canvas { context, size in
                    let spacing: CGFloat = 21
                    var path = Path()
                    stride(from: 0, through: size.width, by: spacing).forEach { x in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    stride(from: 0, through: size.height, by: spacing).forEach { y in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(Color.dishRed.opacity(0.14)), lineWidth: 0.55)
                }

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.dishRed.opacity(0.85), .white.opacity(0.95), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .shadow(color: Color.dishRed, radius: 10)
                    .offset(y: scanTravel ? proxy.size.height / 2 - 10 : -proxy.size.height / 2 + 10)
            }
        }
        .allowsHitTesting(false)
    }

    private var progressPanel: some View {
        VStack(spacing: 10) {
            HStack {
                Text(phases[min(phaseIndex, phases.count - 1)])
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(isReady ? Color.dishSuccess : Color.dishRed)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.dishRedDeep, Color.dishRed, Color.dishWarm],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: safeFrameDimension(proxy.size.width * progress))
                }
            }
            .frame(height: 5)
        }
        .padding(15)
        .background(Color.dishSurfaceRaised.opacity(0.84), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    @ViewBuilder
    private var modificationSummary: some View {
        if !modifierSummary.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(modifierSummary, id: \.ingredientID) { item in
                        Label(
                            item.label,
                            systemImage: item.kind == .removal ? "minus.circle.fill" : "plus.circle.fill"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.06), in: Capsule())
                    }
                }
            }
        }
    }

    private var confirmationButton: some View {
        VStack(spacing: 9) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DISH TOTAL")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1)
                        .foregroundStyle(Color.dishMuted)
                    Text(INR.format(basePricePaise + priceDeltaPaise))
                        .font(.title3.monospacedDigit().bold())
                }
                Spacer()

                Button(action: onDone) {
                    HStack(spacing: 9) {
                        if !isReady {
                            ProgressView().tint(.white)
                        }
                        Text(isReady ? "Confirm Order" : "Building preview")
                        Image(systemName: isReady ? "arrow.right" : "hourglass")
                    }
                }
                .buttonStyle(DishPrimaryButtonStyle())
                .disabled(!isReady)
                .opacity(isReady ? 1 : 0.62)
                .accessibilityIdentifier("reassembly.confirm")
            }

            Text("Visual preview — preparation may vary. Order choices come only from the restaurant catalog.")
                .font(.system(size: 9))
                .foregroundStyle(Color.dishMuted)
                .multilineTextAlignment(.center)
        }
    }

    @MainActor
    private func runReconstruction() async {
        let fast = ProcessInfo.processInfo.arguments.contains("-DishEditFastReconstruction")
        let duration = fast ? 0.5 : 5.2
        let ticks = fast ? 10 : 52

        if !reduceMotion {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                scanTravel = true
            }
        }

        for tick in 1...ticks {
            try? await Task.sleep(for: .milliseconds(Int(duration * 1_000 / Double(ticks))))
            guard !Task.isCancelled else { return }
            withAnimation(.linear(duration: 0.08)) {
                progress = Double(tick) / Double(ticks)
                phaseIndex = min(Int(progress * 4), 3)
            }
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.44, dampingFraction: 0.82)) {
            progress = 1
            phaseIndex = 3
            isReady = true
        }
    }
}
