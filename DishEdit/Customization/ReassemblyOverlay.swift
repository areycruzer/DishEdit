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

    private let phases = [
        "Applying your choices",
        "Updating the dish photo",
        "Checking your selections",
        "Preview ready"
    ]

    var body: some View {
        ZStack {
            Color.sushiCanvas.ignoresSafeArea()

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
        .preferredColorScheme(.light)
        .task { await runReconstruction() }
    }

    private var processingHeader: some View {
        VStack(spacing: 6) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "photo.badge.arrow.down")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(isReady ? Color.dishSuccess : Color.sushiRed)

            Text(isReady ? "Your preview is ready" : "Preparing your preview")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(Color.sushiCoal)

            Text(isReady
                 ? "Your selected customisations are shown in the dish photo."
                 : "Your selected customisations are being added to the dish photo.")
                .font(.subheadline)
                .foregroundStyle(Color.sushiGrey)
                .multilineTextAlignment(.center)
        }
    }

    private var previewStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.sushiDivider, lineWidth: 1)
                )

            BundledImage.image(named: previewAssetName ?? product.assembledAssetName)
                .resizable()
                .scaledToFit()
                .padding(8)
                .scaleEffect(isReady ? 1 : 0.96)
                .saturation(isReady ? 1 : 0.92)
                .opacity(isReady ? 1 : 0.82)
                .shadow(color: .black.opacity(0.14), radius: 14, y: 7)

            if !isReady {
                VStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.sushiRed)
                    Text("Updating photo")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.sushiGrey)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(.white.opacity(0.94), in: Capsule())
                .overlay(Capsule().stroke(Color.sushiDivider, lineWidth: 1))
            }

            if isReady {
                VStack {
                    Spacer()
                    HStack(spacing: 7) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("CUSTOMISED")
                    }
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color.sushiCoal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.94), in: Capsule())
                    .overlay(Capsule().stroke(Color.sushiDivider, lineWidth: 1))
                    .padding(.bottom, 14)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .frame(maxWidth: 440)
        .frame(height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .animation(.easeInOut(duration: 0.35), value: isReady)
        .accessibilityLabel(isReady ? "Finished visual preview of \(product.name)" : "Rebuilding visual preview")
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
                    Capsule().fill(Color.sushiDivider)
                    Capsule()
                        .fill(Color.sushiRed)
                        .frame(width: safeFrameDimension(proxy.size.width * progress))
                }
            }
            .frame(height: 5)
        }
        .padding(15)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.sushiDivider, lineWidth: 1))
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
                        .foregroundStyle(item.kind == .removal ? Color.sushiRed : Color.dishSuccess)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 8)
                        .background((item.kind == .removal ? Color.sushiRed : Color.dishSuccess).opacity(0.08), in: Capsule())
                    }
                }
            }
        }
    }

    private var confirmationButton: some View {
        VStack(spacing: 9) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
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
                        Text(isReady ? "Continue" : "Preparing preview")
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
