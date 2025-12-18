import { GoogleGenAI, Type } from "@google/genai";
import { Challenge } from "../types";
import { TRENDING_DATA, TRENDING_METADATA } from "../data/trending";
import { FEATURED_DATA, FEATURED_METADATA } from "../data/featured";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

// Export Metadata for UI
export const TRENDING_TOPICS_LIST = TRENDING_METADATA;
export const FEATURED_TOPICS_LIST = FEATURED_METADATA;

// Combine data for lookup
export const PREDEFINED_CHALLENGES: Record<string, Challenge> = {
  ...TRENDING_DATA,
  ...FEATURED_DATA
};

export const generateWordChallenge = async (topicId: string, promptTopic: string): Promise<Challenge> => {
  if (PREDEFINED_CHALLENGES[topicId]) {
    return Promise.resolve(PREDEFINED_CHALLENGES[topicId]);
  }

  const prompt = `
    Generate a "Word On Beat" rhythm game challenge.
    Topic: "${promptTopic}".
    Structure: 5 rounds, 8 items per round.
    Phonetic rhymes. 3 distinct objects per round distributed 8 times.
    Return JSON.
  `;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            topic: { type: Type.STRING },
            icon: { type: Type.STRING }, // Request icon
            rounds: {
              type: Type.ARRAY,
              items: {
                type: Type.OBJECT,
                properties: {
                  id: { type: Type.INTEGER },
                  items: {
                    type: Type.ARRAY,
                    items: {
                      type: Type.OBJECT,
                      properties: {
                        word: { type: Type.STRING },
                        emoji: { type: Type.STRING }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    });

    if (response.text) {
      const data = JSON.parse(response.text);
      return {
        id: Date.now().toString(),
        topic: data.topic,
        icon: data.icon || '🎵',
        rounds: data.rounds
      };
    }
    throw new Error("No response text");
  } catch (error) {
    console.error("Gemini generation failed, using fallback:", error);
    // Fallback logic for offline/error
    return PREDEFINED_CHALLENGES['classic'];
  }
};