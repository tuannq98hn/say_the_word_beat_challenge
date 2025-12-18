import { TikTokVideo } from "../types";

// Mock Data representing "Word On Beat" challenges on TikTok.
// Since we cannot fetch real TikTok thumbnails client-side due to CORS without a backend proxy,
// we use high-quality Unsplash images with a "music/party" theme as placeholders for the UI.
const MOCK_VIDEOS: TikTokVideo[] = [
    {
        id: "7234567890123456789", // Example ID
        author: "@rhythm_master",
        description: "Trying the hardest level! 😱 #wordonbeat",
        tags: ["challenge", "music", "fyp"],
        thumbnailUrl: "https://images.unsplash.com/photo-1514525253440-b393452e8d26?w=500&q=80" 
    },
    {
        id: "7234567890123456790",
        author: "@beat_queen",
        description: "Wait for the drop... 🔥",
        tags: ["viral", "game", "trending"],
        thumbnailUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80"
    },
    {
        id: "7234567890123456791",
        author: "@chill_vibes",
        description: "My cat played this better than me 🐱",
        tags: ["funny", "cat", "wordgame"],
        thumbnailUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80"
    },
    {
        id: "7234567890123456792",
        author: "@speed_runner",
        description: "Can you beat this score? 💯",
        tags: ["speedrun", "skill", "beat"],
        thumbnailUrl: "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=500&q=80"
    },
    {
        id: "7234567890123456793",
        author: "@party_crew",
        description: "Saturday night challenge with the gang!",
        tags: ["party", "friends", "fun"],
        thumbnailUrl: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&q=80"
    },
    {
        id: "7234567890123456794",
        author: "@neon_dreams",
        description: "This visual style is sick ✨",
        tags: ["aesthetic", "neon", "design"],
        thumbnailUrl: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80"
    }
];

export const fetchTikTokVideos = (): Promise<TikTokVideo[]> => {
    return new Promise((resolve) => {
        // Simulate network delay (1.5 seconds) to show shimmer effect
        setTimeout(() => {
            resolve(MOCK_VIDEOS);
        }, 1500);
    });
};