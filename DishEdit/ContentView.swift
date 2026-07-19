import SwiftUI

struct ContentView: View {
    @State private var coordinator = DishEditCoordinator()
    @State private var motion = MotionController()
    @State private var isDropValid = false
    @State private var beforeAfterFraction: CGFloat?
    @State private var stageNavigation = StageNavigation()
    @State private var showSummary = false
    @State private var showDiagnostics = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            WarmBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                dishSelector
                    .padding(.horizontal, 20)
                    .padding(.top, 9)

                DishStage(
                    coordinator: coordinator,
                    motion: motion,
                    reduceMotion: reduceMotion,
                    beforeAfterFraction: $beforeAfterFraction,
                    isDropValid: $isDropValid,
                    navigation: $stageNavigation
                )
                .padding(.horizontal, 10)
                .padding(.top, 2)

                modifierChips
                    .frame(minHeight: 42)
                    .padding(.horizontal, 20)

                AddOnTray(
                    coordinator: coordinator
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                bottomBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { if !reduceMotion { motion.start() } }
        .onDisappear { motion.stop() }
        .onChange(of: reduceMotion) { _, newValue in
            if newValue { motion.stop() } else { motion.start() }
        }
        .sheet(isPresented: $showSummary) { OrderSummaryView(coordinator: coordinator) }
        .sheet(isPresented: $showDiagnostics) { LegacyDiagnosticsView(coordinator: coordinator) }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DishEdit")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Touch your food")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button { showDiagnostics = true } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Open technical diagnostics")
        }
    }

    private var modifierChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Text("Tap to remove · Drag to add")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(coordinator.activeModifiers.isEmpty ? .white.opacity(0.72) : .secondary)

                ForEach(coordinator.activeModifiers) { modifier in
                    Button { coordinator.restore(modifierID: modifier.id) } label: {
                        Label(modifier.shortLabel, systemImage: "xmark")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 7)
                            .background(.red.opacity(0.18), in: Capsule())
                            .overlay(Capsule().stroke(.red.opacity(0.5), lineWidth: 0.7))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Double tap to restore this ingredient")
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentTransition(.numericText())
    }

    private var dishSelector: some View {
        HStack(spacing: 7) {
            ForEach(coordinator.catalog.dishes) { dish in
                Button { coordinator.selectDish(dish.id) } label: {
                    Text(dish.id.capitalized)
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .frame(maxWidth: .infinity)
                        .background(coordinator.selectedDishID == dish.id ? .red.opacity(0.22) : .white.opacity(0.035), in: Capsule())
                        .overlay(Capsule().stroke(coordinator.selectedDishID == dish.id ? .red.opacity(0.8) : .white.opacity(0.1), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dish.select.\(dish.id)")
                .accessibilityLabel("Select \(dish.name)")
                .accessibilityAddTraits(coordinator.selectedDishID == dish.id ? .isSelected : [])
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            Button(action: coordinator.undo) { Image(systemName: "arrow.uturn.backward") }
                .disabled(!coordinator.state.canUndo)
                .accessibilityLabel("Undo")
            Button(action: coordinator.redo) { Image(systemName: "arrow.uturn.forward") }
                .disabled(!coordinator.state.canRedo)
                .accessibilityLabel("Redo")
            Button(action: coordinator.reset) { Image(systemName: "arrow.counterclockwise") }
                .disabled(coordinator.state.activeModifierIDs.isEmpty)
                .accessibilityLabel("Reset dish")

            Spacer()

            Button { showSummary = true } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your dish").font(.caption2).foregroundStyle(.secondary)
                        Text(INR.format(coordinator.totalPricePaise)).font(.headline)
                    }
                    Image(systemName: "arrow.up.right")
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
            }
            .buttonStyle(.glassProminent)
            .tint(.red)
            .accessibilityIdentifier("order.summary")
            .accessibilityLabel("Open order summary, total \(INR.format(coordinator.totalPricePaise))")
        }
        .buttonStyle(.glass)
    }
}

private struct DishStage: View {
    @Bindable var coordinator: DishEditCoordinator
    @Bindable var motion: MotionController
    let reduceMotion: Bool
    @Binding var beforeAfterFraction: CGFloat?
    @Binding var isDropValid: Bool
    @Binding var navigation: StageNavigation
    @State private var selectionFlash = false
    @State private var removalGhostAsset: String?
    @State private var removalGhostMaskAsset: String?
    @State private var removalGhostProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let viewport = ImageViewport(
                containerWidth: geometry.size.width,
                containerHeight: geometry.size.height,
                imageWidth: 1_536,
                imageHeight: 1_536
            )

            ZStack {
                if let rendered = CatalogVisualRenderer.image(
                    for: coordinator.dish,
                    visualStateKey: coordinator.displayedVisualStateKey
                ) {
                    Image(uiImage: rendered)
                        .resizable()
                        .scaledToFit()
                        .offset(
                            x: reduceMotion ? 0 : -motion.roll * 13,
                            y: reduceMotion ? 0 : -motion.pitch * 13
                        )
                        .id("\(coordinator.dish.id):\(coordinator.displayedVisualStateKey)")
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.012)))
                        .accessibilityLabel(coordinator.dish.fallbackStates[coordinator.state.visualStateKey]?.accessibilityDescription ?? coordinator.dish.name)

                    let depth = coordinator.dish.depthLayers.first?.depth ?? 0.4
                    Image(uiImage: rendered)
                        .resizable()
                        .scaledToFit()
                        .mask {
                            FoodSilhouetteMask(
                                dishID: coordinator.dish.id,
                                imageFrame: viewport.imageFrame
                            )
                        }
                        .offset(
                            x: reduceMotion ? 0 : motion.roll * depth * 64,
                            y: reduceMotion ? 0 : motion.pitch * depth * 64
                        )
                        .allowsHitTesting(false)
                }

                if let session = coordinator.reconstruction {
                    ReconstructionOverlay(
                        session: session,
                        reduceMotion: reduceMotion
                    )
                    .transition(.opacity)
                } else if coordinator.lastActionDescription == "Visual preview ready" {
                    VStack {
                        HStack(spacing: 7) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Visual preview ready")
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.72), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.13), lineWidth: 0.7))
                        .accessibilityIdentifier("reconstruction.ready")
                        Spacer()
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                    .allowsHitTesting(false)
                }

                if let fraction = beforeAfterFraction {
                    BundledImage.image(named: coordinator.dish.baseImageAsset)
                        .resizable()
                        .scaledToFit()
                        .mask(alignment: .leading) {
                            Rectangle().frame(width: safeFrameDimension(geometry.size.width * fraction))
                        }
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(.white.opacity(0.9))
                                .frame(width: 1.5)
                                .offset(x: geometry.size.width * fraction)
                        }
                        .allowsHitTesting(false)
                }

                if let ghostAsset = removalGhostAsset,
                   let ghostMask = removalGhostMaskAsset,
                   let cutout = CatalogVisualRenderer.ingredientCutout(
                       imageAsset: ghostAsset,
                       maskAsset: ghostMask
                   ) {
                    Image(uiImage: cutout)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1 + removalGhostProgress * 0.035)
                        .offset(y: removalGhostProgress * -12)
                        .opacity(1 - removalGhostProgress)
                        .shadow(color: .black.opacity(0.45), radius: 10, y: 10)
                        .allowsHitTesting(false)
                }

                if isDropValid, let addition = coordinator.dish.additionModifier,
                   let anchor = addition.approvedAnchors.first {
                    let frame = viewport.imageFrame
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.red.opacity(0.08))
                        .stroke(.white.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                        .frame(width: frame.width * anchor.width, height: frame.height * anchor.height)
                        .position(
                            x: frame.x + frame.width * (anchor.x + anchor.width / 2),
                            y: frame.y + frame.height * (anchor.y + anchor.height / 2)
                        )
                        .shadow(color: .red.opacity(0.45), radius: 18)
                        .allowsHitTesting(false)
                }

                if selectionFlash, let removal = coordinator.dish.removalModifier {
                    Color.white
                        .mask {
                            BundledImage.image(named: removal.authorMaskAsset)
                                .resizable()
                                .scaledToFit()
                                .luminanceToAlpha()
                        }
                        .opacity(0.8)
                        .shadow(color: .red.opacity(0.8), radius: 10)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(coordinator.dish.name).font(.headline.weight(.bold))
                            Text(coordinator.dish.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Text(INR.format(coordinator.totalPricePaise)).font(.headline.monospacedDigit())
                    }
                    .padding(13)
                    .background(.black.opacity(0.48))
                }
                .allowsHitTesting(false)
            }
            .scaleEffect(navigation.zoom)
            .offset(navigation.pan)
            .rotation3DEffect(.degrees(reduceMotion ? 0 : motion.roll * 52), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(reduceMotion ? 0 : -motion.pitch * 52), axis: (x: 1, y: 0, z: 0))
            .animation(
                reduceMotion ? .easeOut(duration: 0.14) : .spring(response: 0.38, dampingFraction: 0.84),
                value: coordinator.state.visualStateKey
            )
            .contentShape(Rectangle())
            .gesture(tapGesture(viewport: viewport))
            .simultaneousGesture(inspectionGesture(width: geometry.size.width))
            .simultaneousGesture(magnificationGesture)
            .simultaneousGesture(panGesture)
            .dropDestination(for: String.self) { items, location in
                acceptDrop(items: items, location: location, viewport: viewport)
            } isTargeted: { targeted in
                if targeted && !isDropValid { HapticDirector.anchor() }
                isDropValid = targeted
            }
            .onTapGesture(count: 2) { resetNavigation() }
            .accessibilityAction(named: "Show original") {
                beforeAfterFraction = beforeAfterFraction == nil ? 0.5 : nil
            }
            .accessibilityAction(named: Text(coordinator.state.activeModifierIDs.contains(coordinator.dish.removalModifier?.id ?? "") ? "Restore ingredient" : coordinator.dish.removalModifier?.name ?? "Remove ingredient")) {
                if let modifier = coordinator.dish.removalModifier {
                    if coordinator.state.activeModifierIDs.contains(modifier.id) {
                        coordinator.restore(modifierID: modifier.id)
                    } else {
                        coordinator.toggleRemoval(modifier)
                    }
                }
            }
            .accessibilityElement(children: .combine)
                .accessibilityLabel(coordinator.dish.fallbackStates[coordinator.displayedVisualStateKey]?.accessibilityDescription ?? coordinator.dish.name)
            .accessibilityIdentifier("dish.stage")
        }
        .aspectRatio(0.88, contentMode: .fit)
        .clipped()
    }

    private func tapGesture(viewport: ImageViewport) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                let transform = ImageInteractionTransform(
                    containerWidth: viewport.containerWidth,
                    containerHeight: viewport.containerHeight,
                    zoom: navigation.zoom,
                    panX: navigation.pan.width,
                    panY: navigation.pan.height
                )
                let unprojected = transform.unproject(value.location)
                guard let point = viewport.normalizedPoint(
                    screenX: unprojected.x,
                    screenY: unprojected.y
                ), let modifier = coordinator.dish.removalModifier,
                   CatalogVisualRenderer.maskContains(point, assetName: modifier.authorMaskAsset) else {
                    coordinator.rejectIngredientTap()
                    return
                }
                if !coordinator.state.activeModifierIDs.contains(modifier.id), !reduceMotion {
                    beginRemovalGhost(
                        assetName: coordinator.displayedImageAssetName,
                        maskAssetName: modifier.authorMaskAsset
                    )
                }
                coordinator.toggleRemoval(modifier)
                selectionFlash = true
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(260))
                    withAnimation(.easeOut(duration: 0.22)) { selectionFlash = false }
                }
            }
    }

    private func acceptDrop(
        items: [String],
        location: CGPoint,
        viewport: ImageViewport
    ) -> Bool {
        guard let modifier = coordinator.dish.additionModifier,
              items.contains(modifier.id) else {
            return false
        }

        let transform = ImageInteractionTransform(
            containerWidth: viewport.containerWidth,
            containerHeight: viewport.containerHeight,
            zoom: navigation.zoom,
            panX: navigation.pan.width,
            panY: navigation.pan.height
        )
        let unprojected = transform.unproject(location)
        guard let point = viewport.normalizedPoint(
            screenX: unprojected.x,
            screenY: unprojected.y
        ) else {
            return false
        }
        return coordinator.add(modifier, at: point)
    }

    private func beginRemovalGhost(assetName: String, maskAssetName: String) {
        removalGhostAsset = assetName
        removalGhostMaskAsset = maskAssetName
        removalGhostProgress = 0
        Task { @MainActor in
            await Task.yield()
            withAnimation(.easeInOut(duration: 0.46)) {
                removalGhostProgress = 1
            }
            try? await Task.sleep(for: .milliseconds(500))
            removalGhostAsset = nil
            removalGhostMaskAsset = nil
            removalGhostProgress = 0
        }
    }

    private func inspectionGesture(width: CGFloat) -> some Gesture {
        LongPressGesture(minimumDuration: 0.28)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .second(true, let drag?):
                    beforeAfterFraction = min(1, max(0, drag.location.x / width))
                default: break
                }
            }
            .onEnded { _ in withAnimation(.easeOut(duration: 0.18)) { beforeAfterFraction = nil } }
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                navigation.zoom = min(1.6, max(1, navigation.settledZoom * value.magnification))
            }
            .onEnded { _ in navigation.settledZoom = navigation.zoom }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 14)
            .onChanged { value in
                guard navigation.zoom > 1 else { return }
                let limit = 90 * (navigation.zoom - 1)
                navigation.pan = CGSize(
                    width: min(limit, max(-limit, navigation.settledPan.width + value.translation.width)),
                    height: min(limit, max(-limit, navigation.settledPan.height + value.translation.height))
                )
            }
            .onEnded { _ in navigation.settledPan = navigation.pan }
    }

    private func resetNavigation() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
            navigation = StageNavigation()
        }
    }
}

private struct AddOnTray: View {
    @Bindable var coordinator: DishEditCoordinator

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("ADD TO YOUR DISH").font(.caption2.weight(.bold)).tracking(1.25).foregroundStyle(.secondary)
                Spacer()
                Text("Drag onto food").font(.caption).foregroundStyle(.secondary)
            }

            if let addition = coordinator.dish.additionModifier {
                HStack(spacing: 12) {
                    BundledImage.image(named: addition.trayAsset ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 66, height: 54)
                        .rotationEffect(.degrees(-4))
                        .shadow(color: .black.opacity(0.55), radius: 7, y: 8)
                        .draggable(addition.id)
                        .accessibilityElement()
                        .accessibilityLabel("Drag \(addition.shortLabel) onto the dish")
                        .accessibilityIdentifier("modifier.drag.asset")

                    VStack(alignment: .leading, spacing: 3) {
                        Text(addition.shortLabel).font(.headline)
                        Text(addition.priceDeltaPaise == 0 ? "Included" : "+\(INR.format(addition.priceDeltaPaise))")
                            .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(coordinator.state.activeModifierIDs.contains(addition.id) ? "Added" : "Add") {
                        if coordinator.state.activeModifierIDs.contains(addition.id) {
                            coordinator.restore(modifierID: addition.id)
                        } else {
                            coordinator.addAccessibly(addition)
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .accessibilityIdentifier("modifier.add")
                    .accessibilityLabel(coordinator.state.activeModifierIDs.contains(addition.id) ? "Remove \(addition.shortLabel)" : addition.name)
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 76)
            }
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
    }
}

private struct OrderSummaryView: View {
    @Bindable var coordinator: DishEditCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Dish") {
                    LabeledContent(coordinator.dish.name, value: INR.format(coordinator.dish.basePricePaise))
                }
                Section("Merchant modifiers") {
                    if coordinator.activeModifiers.isEmpty {
                        Text("No changes")
                    }
                    ForEach(coordinator.activeModifiers) { modifier in
                        LabeledContent(modifier.shortLabel, value: modifier.priceDeltaPaise == 0 ? "Included" : "+\(INR.format(modifier.priceDeltaPaise))")
                        Text(modifier.id).font(.caption2.monospaced()).foregroundStyle(.secondary)
                    }
                }
                Section("Total") {
                    LabeledContent("Your dish", value: INR.format(coordinator.totalPricePaise)).font(.headline)
                    Text("Visual preview — preparation may vary.")
                        .font(.footnote.weight(.semibold))
                        .accessibilityIdentifier("order.disclaimer")
                    Text("In production, these deterministic IDs map to the restaurant’s existing modifier catalog. Visual AI never changes the order.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Order truth")
            .toolbar { Button("Done") { dismiss() } }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct LegacyDiagnosticsView: View {
    @Bindable var coordinator: DishEditCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Current transition") {
                    LabeledContent("Mask", value: coordinator.lastMaskSource)
                    LabeledContent("Engine", value: coordinator.lastEngine.rawValue)
                    LabeledContent("Preview", value: "BUNDLED · OFFLINE")
                    LabeledContent("Latency", value: "\(coordinator.lastDurationMilliseconds) ms")
                    LabeledContent("Revision", value: "\(coordinator.state.revision)")
                    LabeledContent("State", value: coordinator.state.visualStateKey)
                }
                Section("Stage guarantee") {
                    Toggle("Force catalog fallback", isOn: $coordinator.forceCatalogFallback)
                        .disabled(true)
                    Button("Reset dish") { coordinator.reset() }
                }
                Section("Technical honesty") {
                    Text("The stage path currently uses reviewed catalog masks and matched destination photographs. The 5.4-second reconstruction treatment runs live, but its pixels are prepared catalog assets. Live LCM remains disabled until a physical iPhone 16 passes the memory and latency gate.")
                    Text("No network, private API, payment, identity, allergy, or nutrition claim is used.")
                }
            }
            .navigationTitle("Engine room")
            .toolbar { Button("Done") { dismiss() } }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct WarmBackdrop: View {
    var body: some View {
        Color(red: 0.035, green: 0.027, blue: 0.025)
            .overlay(alignment: .top) {
                RadialGradient(colors: [.red.opacity(0.16), .clear], center: .topTrailing, startRadius: 10, endRadius: 360)
                    .frame(height: 500)
            }
            .ignoresSafeArea()
    }
}

private struct StageNavigation: Equatable {
    var zoom: CGFloat = 1
    var settledZoom: CGFloat = 1
    var pan = CGSize.zero
    var settledPan = CGSize.zero
}

private struct FoodSilhouetteMask: View {
    let dishID: String
    let imageFrame: ImageFrame

    var body: some View {
        Canvas { context, _ in
            let frame = CGRect(
                x: imageFrame.x,
                y: imageFrame.y,
                width: imageFrame.width,
                height: imageFrame.height
            )
            let silhouette: CGRect
            var path = Path()

            switch dishID {
            case "burger":
                silhouette = CGRect(
                    x: frame.minX + frame.width * 0.11,
                    y: frame.minY + frame.height * 0.20,
                    width: frame.width * 0.78,
                    height: frame.height * 0.72
                )
                path.addRoundedRect(in: silhouette, cornerSize: CGSize(width: 72, height: 72))
            case "pizza":
                silhouette = CGRect(
                    x: frame.minX + frame.width * 0.04,
                    y: frame.minY + frame.height * 0.10,
                    width: frame.width * 0.92,
                    height: frame.height * 0.77
                )
                path.addEllipse(in: silhouette)
            default:
                silhouette = CGRect(
                    x: frame.minX + frame.width * 0.07,
                    y: frame.minY + frame.height * 0.18,
                    width: frame.width * 0.86,
                    height: frame.height * 0.69
                )
                path.addEllipse(in: silhouette)
            }

            context.fill(path, with: .color(.white))
        }
        .allowsHitTesting(false)
    }
}

private struct ReconstructionOverlay: View {
    let session: ReconstructionSession
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 0.12 : 1 / 30)) { context in
            let progress = session.progress(at: context.date)
            let phase = session.phase(at: context.date)

            ZStack {
                if !reduceMotion {
                    processingField(progress: progress)
                        .mask {
                            BundledImage.image(named: session.maskAssetName)
                                .resizable()
                                .scaledToFit()
                                .luminanceToAlpha()
                        }
                        .blendMode(.screen)
                }

                VStack {
                    statusPill(phase: phase, progress: progress)
                    Spacer()
                }
                .padding(.top, 12)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("On-device preview. Reconstructing selected region.")
        .accessibilityIdentifier("reconstruction.overlay")
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func processingField(progress: Double) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let scanY = height * CGFloat(0.08 + progress * 0.84)

            ZStack {
                Color.white.opacity(0.08 + sin(progress * .pi * 8) * 0.04)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.12), .red.opacity(0.9), .white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 44)
                    .blur(radius: 5)
                    .position(x: width / 2, y: scanY)

                Canvas { canvas, size in
                    for index in 0 ..< 34 {
                        let seed = Double(index) * 0.618_033_988_75
                        let x = (seed.truncatingRemainder(dividingBy: 1) * 0.84 + 0.08) * size.width
                        let travel = (progress * 1.7 + seed).truncatingRemainder(dividingBy: 1)
                        let y = (0.12 + travel * 0.76) * size.height
                        let radius = 1.3 + Double(index % 4) * 0.65
                        let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                        canvas.fill(
                            Path(ellipseIn: rect),
                            with: .color(index.isMultiple(of: 3) ? .red : .white.opacity(0.9))
                        )
                    }
                }
                .blur(radius: 0.35)
            }
        }
    }

    private func statusPill(
        phase: ReconstructionPhase,
        progress: Double
    ) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(.white.opacity(0.16), lineWidth: 2)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.red, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "sparkles")
                    .font(.caption2.weight(.bold))
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                Text("ON-DEVICE PREVIEW")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.red)
                Text(phase.title)
                    .font(.caption.weight(.semibold))
                    .contentTransition(.numericText())
            }

            Text("\(Int(progress * 100))%")
                .font(.caption2.monospacedDigit().weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(.black.opacity(0.78), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.14), lineWidth: 0.7))
        .shadow(color: .black.opacity(0.5), radius: 14, y: 7)
        .accessibilityIdentifier("reconstruction.status")
    }
}

#Preview { ContentView() }
