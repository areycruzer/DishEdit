import SwiftUI

// MARK: - Image Playground Bridge

@available(iOS 26.0, *)
struct ImagePlaygroundBridge {
    enum PlaygroundError: Error, Sendable {
        case unavailable
        case cancelled
        case generationFailed(String)
    }

    static var isAvailable: Bool {
        FeatureAvailability.isImagePlaygroundAvailable
    }

    static func engineAvailability() -> EngineAvailability {
        guard isAvailable else { return .unavailable }
        return .available
    }
}

// MARK: - Image Playground Sheet Modifier

@available(iOS 26.0, *)
struct ImagePlaygroundSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let prompt: String
    let onCompletion: (Result<URL, Error>) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ImagePlaygroundPlaceholderView(
                    prompt: prompt,
                    onDismiss: {
                        isPresented = false
                        onCompletion(.failure(ImagePlaygroundBridge.PlaygroundError.cancelled))
                    }
                )
            }
    }
}

@available(iOS 26.0, *)
private struct ImagePlaygroundPlaceholderView: View {
    let prompt: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Image Playground")
                .font(.title2.bold())

            Text("Experimental feature — uses Apple's system Image Playground sheet when available on device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Prompt: \(prompt)")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button("Close") { onDismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - View Extension

@available(iOS 26.0, *)
extension View {
    func imagePlaygroundSheet(
        isPresented: Binding<Bool>,
        prompt: String,
        onCompletion: @escaping (Result<URL, Error>) -> Void
    ) -> some View {
        modifier(ImagePlaygroundSheetModifier(
            isPresented: isPresented,
            prompt: prompt,
            onCompletion: onCompletion
        ))
    }
}
