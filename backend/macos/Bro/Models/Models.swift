//
//  Models.swift
//  Bro
//

import Foundation

// MARK: - Tone Profiles
enum ToneProfile: String, CaseIterable, Codable {
    case nice_guy
    case meme_god
    case no_filter
    
    var displayName: String {
        switch self {
        case .nice_guy: return "Nice Guy"
        case .meme_god: return "Meme God"
        case .no_filter: return "No Filter"
        }
    }
}

// MARK: - Tone Preset
struct TonePreset: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let name: String
    let systemPrompt: String
    let style: ToneStyle
    let isDefault: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case systemPrompt = "system_prompt"
        case style
        case isDefault = "is_default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ToneStyle: Codable, Equatable {
    let formality: Int
    let empathy: Int
    let brevity: Int
    let emojisAllowed: Bool
    
    enum CodingKeys: String, CodingKey {
        case formality
        case empathy
        case brevity
        case emojisAllowed
    }
}

// MARK: - Voice
struct Voice: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let elevenVoiceId: String
    let displayName: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case elevenVoiceId = "eleven_voice_id"
        case displayName = "display_name"
        case createdAt = "created_at"
    }
}

// MARK: - Usage Event
struct UsageEvent: Codable, Identifiable {
    let id: String
    let userId: String
    let eventType: EventType
    let tokensIn: Int?
    let tokensOut: Int?
    let latencyMs: Int
    let createdAt: Date
    
    enum EventType: String, Codable {
        case rephrase
        case tts
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventType = "event_type"
        case tokensIn = "tokens_in"
        case tokensOut = "tokens_out"
        case latencyMs = "latency_ms"
        case createdAt = "created_at"
    }
}

// MARK: - API Responses
struct TonePresetsResponse: Codable {
    let tonePresets: [TonePreset]
}

struct VoicesResponse: Codable {
    let voices: [Voice]
}

struct UsageStatsResponse: Codable {
    let totalEvents: Int
    let rephraseCount: Int
    let ttsCount: Int
    let totalTokensIn: Int
    let totalTokensOut: Int
    let avgLatencyMs: Double
    let events: [UsageEvent]
}

// MARK: - Rephrase Stream Event
struct RephraseStreamEvent: Codable {
    let content: String?
    let done: Bool?
    let tokensOut: Int?
    let latencyMs: Int?
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let error: String
}

