
export interface ChallengeItem {
  word: string;
  emoji: string;
  image?: string;
}

export interface Round {
  id: number;
  items: ChallengeItem[];
}

export interface Challenge {
  id: string;
  topic: string;
  icon?: string;
  rounds: Round[];
  isCustom?: boolean;
}

export enum GameState {
  SPLASH = 'SPLASH',
  GUIDE = 'GUIDE',
  STYLE_SELECTION = 'STYLE_SELECTION',
  MAIN = 'MAIN',
  GENERATING = 'GENERATING',
  PLAYING = 'PLAYING',
  GAME_OVER = 'GAME_OVER',
  VIDEO_PLAYER = 'VIDEO_PLAYER'
}

export enum Difficulty {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD'
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

export enum AppTab {
  TRENDING = 'TRENDING',
  FEATURED = 'FEATURED',
  VIDEO = 'VIDEO',
  CUSTOM = 'CUSTOM',
  SETTINGS = 'SETTINGS'
}

export interface TikTokVideo {
  id: string;
  author: string;
  description: string;
  tags: string[];
  thumbnailUrl: string;
}

// Added UploadedImage interface to match usage in CreateWizard
export interface UploadedImage {
  id: string;
  file: File;
  previewUrl: string;
  name: string;
}

// Added CustomCreationData interface to match usage in CreateWizard
export interface CustomCreationData {
  processedImages: {
    id: string;
    name: string;
    base64: string;
  }[];
  levels: string[][];
  topicName: string;
}
