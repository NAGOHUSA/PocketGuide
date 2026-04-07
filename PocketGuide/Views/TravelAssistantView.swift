import SwiftUI

/// Offline AI travel assistant powered by Apple's on-device LLMs.
/// All inference runs locally—no Wi-Fi or cellular data required.
struct TravelAssistantView: View {

    let cityPack: CityPack
    @EnvironmentObject private var llmService: OfflineLLMService

    @State private var inputText = ""
    @State private var messages: [ChatMessage] = []
    @State private var streamingText = ""
    @FocusState private var isInputFocused: Bool

    // Suggested questions shown when there are no messages yet
    private let suggestions: [String] = [
        "What's the best way to get from the airport to the city center?",
        "What are the local dining customs I should know?",
        "What are the top sights to see?",
        "Are there any safety tips I should know?",
        "What useful phrases should I learn?"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Status banner
            statusBanner

            Divider()

            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            suggestionsView
                                .padding(.top, 24)
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }

                            // Streaming token display
                            if !streamingText.isEmpty {
                                MessageBubble(
                                    message: ChatMessage(
                                        role: .assistant,
                                        content: streamingText + "▌"
                                    )
                                )
                                .id("streaming")
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: streamingText) { _, _ in
                    withAnimation { proxy.scrollTo("streaming") }
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation { proxy.scrollTo(messages.last?.id) }
                }
            }

            Divider()

            // Input bar
            inputBar
        }
        .navigationTitle("AI Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var statusBanner: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(llmService.isAvailable ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            Text(llmService.isAvailable
                 ? "On-device AI · No internet needed"
                 : "Apple Intelligence unavailable — enable in Settings")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if !messages.isEmpty {
                Button("Clear") {
                    withAnimation { messages.removeAll() }
                }
                .font(.caption)
                .foregroundStyle(.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.accentColor)
                Text("Ask your offline AI guide about \(cityPack.city)")
                    .font(.headline)
            }
            .padding(.bottom, 4)

            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                    sendMessage(suggestion)
                } label: {
                    HStack {
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask about \(cityPack.city)…", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isInputFocused)
                .onSubmit { sendMessage(inputText) }

            Button {
                sendMessage(inputText)
            } label: {
                Image(systemName: llmService.isProcessing ? "stop.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                     ? .secondary : .accentColor)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || llmService.isProcessing)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Actions

    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        inputText = ""
        isInputFocused = false
        messages.append(ChatMessage(role: .user, content: trimmed))
        streamingText = ""

        Task {
            do {
                for try await token in llmService.ask(trimmed) {
                    streamingText += token
                }
                messages.append(ChatMessage(role: .assistant, content: streamingText))
                streamingText = ""
            } catch {
                messages.append(ChatMessage(
                    role: .assistant,
                    content: "Sorry, I couldn't generate a response: \(error.localizedDescription)"
                ))
                streamingText = ""
            }
        }
    }
}

// MARK: - ChatMessage

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role {
        case user, assistant
    }
}

// MARK: - MessageBubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.role == .user
                                ? Color.accentColor
                                : Color(.secondarySystemGroupedBackground))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
            }

            if message.role == .assistant { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    let pack = CityPack(
        id: "tokyo",
        city: "Tokyo",
        country: "Japan",
        region: "Asia",
        storeProductID: "com.pocketguide.citypack.tokyo",
        overview: "Navigate Tokyo offline.",
        latitude: 35.6762,
        longitude: 139.6503,
        sizeInMB: 142.5,
        coverImageName: "tokyo_cover"
    )
    return NavigationStack {
        TravelAssistantView(cityPack: pack)
    }
    .environmentObject(OfflineLLMService())
}
