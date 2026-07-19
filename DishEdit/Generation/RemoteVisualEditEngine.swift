import Foundation
import CoreGraphics

// MARK: - Remote Visual Edit Engine

actor RemoteVisualEditEngine: VisualEditEngineProtocol {
    nonisolated let engineMode: GenerationEngineMode = .remote

    private let isConfigured: Bool
    private let endpointURL: URL?
    private let timeoutSeconds: TimeInterval

    init(
        endpointURL: URL? = nil,
        timeoutSeconds: TimeInterval = 30
    ) {
        self.endpointURL = endpointURL
        self.isConfigured = endpointURL != nil
        self.timeoutSeconds = timeoutSeconds
    }

    func availability() async -> EngineAvailability {
        guard isConfigured, endpointURL != nil else {
            return .unavailable
        }
        return .available
    }

    func generate(request: VisualEditRequest) async throws -> VisualEditResult {
        guard isConfigured, let url = endpointURL else {
            return .unavailable(reason: "Remote engine not configured")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = timeoutSeconds
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = RemoteEditPayload(
            productID: request.productID,
            removedIngredientIDs: Array(request.removedIngredientIDs),
            addedIngredientIDs: Array(request.addedIngredientIDs),
            revision: request.revision
        )

        urlRequest.httpBody = try payload.jsonData()

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            return .unavailable(reason: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200:
            guard let provider = CGDataProvider(data: data as CFData),
                  let image = CGImage(
                      pngDataProviderSource: provider,
                      decode: nil,
                      shouldInterpolate: true,
                      intent: .defaultIntent
                  ) else {
                return .unavailable(reason: "Invalid image data from remote")
            }
            return .generated(image: image, engine: .remote, durationMs: 0)
        case 401:
            return .unavailable(reason: "Unauthorized — check credentials")
        case 429:
            return .unavailable(reason: "Rate limited — try again later")
        default:
            return .unavailable(reason: "Remote error: HTTP \(httpResponse.statusCode)")
        }
    }
}

// MARK: - Remote Payload

private nonisolated struct RemoteEditPayload: Sendable {
    let productID: String
    let removedIngredientIDs: [String]
    let addedIngredientIDs: [String]
    let revision: UInt64

    func jsonData() throws -> Data {
        let dict: [String: Any] = [
            "productID": productID,
            "removedIngredientIDs": removedIngredientIDs,
            "addedIngredientIDs": addedIngredientIDs,
            "revision": revision
        ]
        return try JSONSerialization.data(withJSONObject: dict)
    }
}
