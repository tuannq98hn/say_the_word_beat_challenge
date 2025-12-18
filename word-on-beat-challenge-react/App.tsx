import React, { useState, useEffect } from 'react';
import { TopicList } from './components/TopicList';
import { Game } from './components/Game';
import { GameOver } from './components/GameOver';
import { Splash } from './components/Splash';
import { BottomNav } from './components/BottomNav';
import { SettingsTab } from './components/SettingsTab';
import { CustomTab } from './components/CustomTab';
import { VideoTab } from './components/VideoTab';
import { VideoPlayer } from './components/VideoPlayer';
import { GameState, Challenge, GameSettings, Difficulty, MusicStyle, AppTab, TikTokVideo } from './types';
import { TRENDING_TOPICS_LIST, FEATURED_TOPICS_LIST } from './services/geminiService';
import { loadCustomChallenges, saveCustomChallenges } from './services/storageService';

function App() {
  const [gameState, setGameState] = useState<GameState>(GameState.SPLASH);
  const [currentChallenge, setCurrentChallenge] = useState<Challenge | null>(null);
  const [activeTab, setActiveTab] = useState<AppTab>(AppTab.TRENDING);
  
  // Video Player State
  const [currentVideo, setCurrentVideo] = useState<TikTokVideo | null>(null);
  
  // Custom Challenges Data
  const [customChallenges, setCustomChallenges] = useState<Challenge[]>([]);

  // Settings State
  const [settings, setSettings] = useState<GameSettings>({
    showWordText: true,
    difficulty: Difficulty.MEDIUM,
    musicStyle: MusicStyle.FUNK
  });

  // Load Custom Challenges on Mount
  useEffect(() => {
    const loaded = loadCustomChallenges();
    setCustomChallenges(loaded);
  }, []);

  // Splash Screen Logic
  useEffect(() => {
    if (gameState === GameState.SPLASH) {
        const timer = setTimeout(() => {
            setGameState(GameState.MAIN);
        }, 2000); // 2 seconds
        return () => clearTimeout(timer);
    }
  }, [gameState]);

  const updateSettings = (newSettings: Partial<GameSettings>) => {
    setSettings(prev => ({ ...prev, ...newSettings }));
  };

  const handleAddCustomChallenge = (c: Challenge) => {
      const updated = [c, ...customChallenges];
      setCustomChallenges(updated);
      saveCustomChallenges(updated); // Save to local storage
  };

  const handleVideoClick = (video: TikTokVideo) => {
      setCurrentVideo(video);
      setGameState(GameState.VIDEO_PLAYER);
  };

  return (
    <div className="h-[100dvh] w-full bg-black text-white font-sans antialiased selection:bg-pink-500 selection:text-white overflow-hidden touch-none relative flex flex-col">
      
      {gameState === GameState.SPLASH && <Splash />}

      {/* MAIN TABBED INTERFACE */}
      {gameState === GameState.MAIN && (
          <>
            <div className="flex-1 overflow-hidden relative">
                {activeTab === AppTab.TRENDING && (
                    <TopicList 
                        setGameState={setGameState} 
                        setChallenge={setCurrentChallenge}
                        topics={TRENDING_TOPICS_LIST}
                        tabName="Trending Challenge"
                    />
                )}
                {activeTab === AppTab.FEATURED && (
                    <TopicList 
                        setGameState={setGameState} 
                        setChallenge={setCurrentChallenge}
                        topics={FEATURED_TOPICS_LIST}
                        tabName="Featured Challenge"
                    />
                )}
                {activeTab === AppTab.VIDEO && (
                    <VideoTab 
                        onVideoClick={handleVideoClick}
                    />
                )}
                {activeTab === AppTab.CUSTOM && (
                    <CustomTab 
                        customChallenges={customChallenges}
                        onAddChallenge={handleAddCustomChallenge}
                        setChallenge={setCurrentChallenge}
                        setGameState={setGameState}
                    />
                )}
                {activeTab === AppTab.SETTINGS && (
                    <SettingsTab 
                        settings={settings}
                        updateSettings={updateSettings}
                    />
                )}
            </div>
            
            <BottomNav currentTab={activeTab} onTabChange={setActiveTab} />
          </>
      )}

      {/* FULL SCREEN STATES (No Bottom Nav) */}

      {gameState === GameState.PLAYING && currentChallenge && (
        <Game 
          wordSet={currentChallenge} 
          setGameState={setGameState} 
          settings={settings}
        />
      )}

      {gameState === GameState.VIDEO_PLAYER && currentVideo && (
        <VideoPlayer 
          video={currentVideo}
          onBack={() => setGameState(GameState.MAIN)}
        />
      )}

      {gameState === GameState.GAME_OVER && (
        <GameOver 
          setGameState={setGameState} 
        />
      )}

    </div>
  );
}

export default App;