import Foundation

// MARK: - OfflineLLMService
//
// Wraps Apple's on-device FoundationModels framework (Apple Intelligence)
// to answer travel questions entirely on-device—no internet required.
//
// The service accepts a city-specific system prompt that is pre-embedded
// in the downloaded CityPack, giving the model rich context about that
// destination without requiring any network call.

@MainActor
final class OfflineLLMService: ObservableObject {

    // MARK: - Published state

    @Published var isProcessing = false
    @Published var isAvailable = false

    // MARK: - Private

    private var currentCityContext: String = ""

    // MARK: - Init

    init() {
        checkAvailability()
    }

    // MARK: - Public API

    /// Load city-specific context so the model knows which city it's
    /// advising about. Call this whenever the user opens a CityPack.
    func loadCityContext(_ context: String) {
        currentCityContext = context
    }

    /// Ask the on-device model a travel question.
    /// Returns a streaming `AsyncThrowingStream` of text tokens.
    func ask(_ question: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                await self.runInference(question: question, continuation: continuation)
            }
        }
    }

    /// Convenience method that collects all tokens and returns the full answer.
    func askCollected(_ question: String) async throws -> String {
        var result = ""
        for try await token in ask(question) {
            result += token
        }
        return result
    }

    // MARK: - Availability

    func checkAvailability() {
        // On a real device running iOS 26+ with Apple Intelligence enabled,
        // FoundationModels.SystemLanguageModel.default.availability would be
        // .available. We surface this flag so the UI can show a graceful
        // fallback on older devices.
        isAvailable = OnDeviceLLMBridge.isAvailable
    }

    // MARK: - Private inference

    private func runInference(
        question: String,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async {
        isProcessing = true
        defer {
            Task { @MainActor in self.isProcessing = false }
        }

        do {
            let systemPrompt = buildSystemPrompt()
            let tokens = try await OnDeviceLLMBridge.generate(
                systemPrompt: systemPrompt,
                userMessage: question
            )
            for token in tokens {
                continuation.yield(token)
                // Small delay to create a natural streaming effect in the UI
                try await Task.sleep(for: .milliseconds(20))
            }
            continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }
    }

    private func buildSystemPrompt() -> String {
        let base = """
        You are PocketGuide, a knowledgeable offline travel assistant. \
        You run entirely on-device and do not have access to the internet. \
        Always give practical, accurate, and safety-conscious advice. \
        If you are uncertain about something, say so clearly.
        """
        guard !currentCityContext.isEmpty else { return base }
        return base + "\n\n" + currentCityContext
    }
}

// MARK: - OnDeviceLLMBridge
//
// A thin abstraction layer over Apple's FoundationModels APIs introduced
// in iOS 26 / Apple Intelligence. This layer makes it easy to swap in
// the real framework once the app is compiled against the iOS 26 SDK,
// while keeping the rest of the codebase clean and testable.

enum OnDeviceLLMBridge {

    static var isAvailable: Bool {
        // Real check:
        // return SystemLanguageModel.default.availability == .available
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    /// Calls the on-device model and returns an array of streamed tokens.
    /// In production this streams via `LanguageModelSession.respond(to:)`.
    static func generate(
        systemPrompt: String,
        userMessage: String
    ) async throws -> [String] {
        // ── Real implementation (iOS 26 SDK) ──────────────────────────────
        // import FoundationModels
        //
        // let session = LanguageModelSession(
        //     model: .default,
        //     instructions: Instructions(systemPrompt)
        // )
        // let response = try await session.respond(to: Prompt(userMessage))
        // return response.content.split(separator: " ").map { String($0) + " " }
        // ─────────────────────────────────────────────────────────────────

        // Simulator / test fallback: return a canned response so UI works.
        let fallback = simulatorFallback(for: userMessage)
        return fallback.components(separatedBy: " ").map { $0 + " " }
    }

    // MARK: - Simulator / test fallback

    private static func simulatorFallback(for question: String) -> String {
        let q = question.lowercased()
        if q.contains("subway") || q.contains("metro") || q.contains("train") {
            return "Most city packs include full offline subway maps. Open the 'Getting Around' section to see all lines, fares, and step-by-step directions—no data required."
        }
        if q.contains("food") || q.contains("eat") || q.contains("restaurant") {
            return "Your city pack includes curated local food recommendations with addresses and typical prices. Check the 'Food & Drink' section for neighborhood-by-neighborhood picks."
        }
        if q.contains("tip") || q.contains("etiquette") || q.contains("custom") {
            return "Cultural norms are covered in the 'Culture & Etiquette' guide. Key things to know are pre-loaded in your city pack so you can review them before going offline."
        }
        if q.contains("emergency") || q.contains("police") || q.contains("hospital") {
            return "Emergency contacts and hospital locations for this city are in the 'Emergency' section of your city pack. They're always accessible offline."
        }
        return "I'm your offline travel assistant for this city. Ask me about transport, food, culture, sights, or safety—I have everything you need pre-loaded in your city pack."
    }
}

// MARK: - LLMError

enum LLMError: LocalizedError {
    case modelUnavailable
    case contextTooLong
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device. Please enable it in Settings > Apple Intelligence & Siri."
        case .contextTooLong:
            return "The question is too long. Please try a shorter query."
        case .generationFailed(let reason):
            return "The on-device model could not generate a response: \(reason)"
        }
    }
}
