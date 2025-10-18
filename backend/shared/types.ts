// Shared types for macOS app and backend

export interface TonePreset {
  id: string;
  userId: string;
  name: string;
  systemPrompt: string;
  style: {
    formality: number; // 0-10
    empathy: number; // 0-10
    brevity: number; // 0-10
    emojisAllowed: boolean;
  };
  isDefault: boolean;
}

export interface Voice {
  id: string;
  userId: string;
  elevenVoiceId: string;
  displayName: string;
}

export interface UsageEvent {
  id: string;
  userId: string;
  eventType: 'rephrase' | 'tts';
  tokensIn?: number;
  tokensOut?: number;
  latencyMs: number;
  createdAt: Date;
}

export interface RephraseRequest {
  text: string;
  tonePresetId?: string;
}

export interface RephraseResponse {
  originalText: string;
  rephrasedText: string;
  tokensUsed: number;
}

export interface TTSRequest {
  text: string;
  voiceId?: string;
}

export interface TTSResponse {
  audioUrl: string;
  durationMs: number;
}

export const DEFAULT_TONE_PRESETS: Omit<TonePreset, 'id' | 'userId'>[] = [
  {
    name: 'Professional',
    systemPrompt: 'Rewrite the following message in a professional, formal tone. Preserve the core meaning and intent. Fix any grammar or spelling errors. Be concise and clear.',
    style: {
      formality: 9,
      empathy: 5,
      brevity: 7,
      emojisAllowed: false,
    },
    isDefault: false,
  },
  {
    name: 'Friendly',
    systemPrompt: 'Rewrite the following message in a warm, friendly tone. Keep it conversational and approachable. Add appropriate emojis if they enhance the message. Preserve the core meaning.',
    style: {
      formality: 3,
      empathy: 8,
      brevity: 5,
      emojisAllowed: true,
    },
    isDefault: true,
  },
  {
    name: 'Concise',
    systemPrompt: 'Rewrite the following message to be brief and to-the-point. Remove unnecessary words while preserving all key information. Maintain a neutral, clear tone.',
    style: {
      formality: 5,
      empathy: 5,
      brevity: 10,
      emojisAllowed: false,
    },
    isDefault: false,
  },
  {
    name: 'Empathetic',
    systemPrompt: 'Rewrite the following message with empathy and understanding. Show genuine care and consideration. Use warm, supportive language while preserving the original intent.',
    style: {
      formality: 4,
      empathy: 10,
      brevity: 4,
      emojisAllowed: true,
    },
    isDefault: false,
  },
];

