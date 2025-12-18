export interface ChallengeItem {
  word: string;
  emoji: string;
  image?: string; // Optional URL for custom images (Base64 or URL)
}

export interface Round {
  id: number;
  items: ChallengeItem[]; // Exactly 8 items per round
}

export interface Challenge {
  id: string;
  topic: string;
  icon?: string; // Icon/Emoji representing the topic
  rounds: Round[];
  isCustom?: boolean;
}

export enum GameState {
  SPLASH = 'SPLASH',
  MAIN = 'MAIN', // Replaces MENU, acts as container for Tabs
  GENERATING = 'GENERATING',
  PLAYING = 'PLAYING',
  GAME_OVER = 'GAME_OVER',
  VIDEO_PLAYER = 'VIDEO_PLAYER' // New state for full screen video
}

export enum Difficulty {
  EASY = 'EASY',     // 120 BPM
  MEDIUM = 'MEDIUM', // 138 BPM
  HARD = 'HARD'      // 150 BPM
}

export enum MusicStyle {
  FUNK = 'FUNK',
  SYNTH = 'SYNTH',
  CHILL = 'CHILL'
}

export interface GameSettings {
  showWordText: boolean;
  difficulty: Difficulty;
  musicStyle: MusicStyle;
}

export interface BeatConfig {
  bpm: number;
  isPlaying: boolean;
  currentBeat: number;
}

export enum AppTab {
  TRENDING = 'TRENDING',
  FEATURED = 'FEATURED',
  VIDEO = 'VIDEO', // New Tab
  CUSTOM = 'CUSTOM',
  SETTINGS = 'SETTINGS'
}

// Interfaces for Custom Challenge Creation
export interface UploadedImage {
  id: string;
  file: File;
  previewUrl: string;
  name: string;
}

export interface CustomCreationData {
  topicName: string;
  images: UploadedImage[];
  levels: string[][]; // 5 levels, each has 8 image IDs
}

// Interface for TikTok Video
export interface TikTokVideo {
  id: string; // The numeric/string ID of the video from TikTok
  author: string;
  description: string;
  tags: string[];
  thumbnailUrl: string; // URL for the preview image
}