import React, { useState } from 'react';
import { GameState, Challenge } from '../types';
import { generateWordChallenge, PREDEFINED_CHALLENGES } from '../services/geminiService';
import { audioService } from '../services/audioService';

interface TopicListProps {
  setGameState: (state: GameState) => void;
  setChallenge: (challenge: Challenge) => void;
  topics: { id: string, label: string, icon: string, prompt: string }[];
  tabName: string;
}

export const TopicList: React.FC<TopicListProps> = ({ setGameState, setChallenge, topics, tabName }) => {
  const [loadingId, setLoadingId] = useState<string | null>(null);

  const handleSelectTopic = async (topicId: string, prompt: string) => {
    setLoadingId(topicId);
    audioService.init(); // Init audio context
    
    try {
      const data = await generateWordChallenge(topicId, prompt);
      setChallenge(data);
      setGameState(GameState.PLAYING);
    } catch (e) {
      console.error(e);
      setLoadingId(null);
    }
  };

  const getPreviewEmojis = (topicId: string) => {
    const challenge = PREDEFINED_CHALLENGES[topicId];
    if (!challenge) return ['❓', '❓', '❓', '❓', '❓', '❓', '❓', '❓'];
    
    const allItems = challenge.rounds.flatMap(r => r.items);
    const uniqueEmojis = Array.from(new Set(allItems.map(i => i.emoji))).slice(0, 8);
    while (uniqueEmojis.length < 8 && uniqueEmojis.length > 0) {
        uniqueEmojis.push(uniqueEmojis[uniqueEmojis.length % uniqueEmojis.length]);
    }
    return uniqueEmojis;
  };

  return (
    <div className="h-full w-full overflow-y-auto bg-[#111] text-white p-4 md:p-6 flex flex-col items-center custom-scrollbar pb-32">
      {/* Tab Header */}
      <div className="w-full text-center py-4 mb-4 sticky top-0 bg-[#111]/90 backdrop-blur z-40 border-b border-gray-800">
         <h1 className="text-2xl font-display uppercase tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-orange-500">
             {tabName}
         </h1>
      </div>

      <div className="max-w-4xl w-full">
        {/* Grid of Topics */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 md:gap-4">
          {topics.map((topic) => {
             const previewEmojis = getPreviewEmojis(topic.id);
             
             return (
              <button
                key={topic.id}
                onClick={() => handleSelectTopic(topic.id, topic.prompt)}
                disabled={loadingId !== null}
                className={`
                  group relative overflow-hidden rounded-2xl border border-gray-700 
                  hover:border-yellow-400 transition-all duration-300
                  flex flex-col items-center justify-center h-32 md:h-44 w-full
                  bg-gray-900
                  ${loadingId === topic.id ? 'ring-4 ring-yellow-400' : ''}
                  ${loadingId && loadingId !== topic.id ? 'opacity-30' : ''}
                `}
              >
                {/* Background Preview */}
                <div className="absolute inset-0 bg-white/5">
                   <div className="w-full h-full grid grid-cols-4 grid-rows-2 gap-1 p-2 opacity-30 group-hover:opacity-60 blur-[1px] transition-all duration-500">
                      {previewEmojis.map((emoji, idx) => (
                         <div key={idx} className="flex items-center justify-center text-lg">{emoji}</div>
                      ))}
                   </div>
                </div>

                {/* Dark Overlay */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/90 to-transparent" />

                {/* Content */}
                <div className="relative z-10 flex flex-col items-center justify-center gap-1 w-full px-2">
                  {loadingId === topic.id ? (
                    <div className="animate-spin text-3xl">💿</div>
                  ) : (
                    <>
                      <div className="text-3xl mb-1 filter drop-shadow-lg transform group-hover:scale-110 transition-transform">{topic.icon}</div>
                      <span className="font-display text-lg md:text-xl font-bold uppercase tracking-wide text-white group-hover:text-yellow-400 transition-colors text-center leading-tight">
                        {topic.label}
                      </span>
                    </>
                  )}
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};