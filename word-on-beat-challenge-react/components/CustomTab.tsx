import React, { useState } from 'react';
import { Challenge, GameState } from '../types';
import { CreateWizard } from './CreateWizard';

interface CustomTabProps {
  customChallenges: Challenge[];
  onAddChallenge: (challenge: Challenge) => void;
  setChallenge: (challenge: Challenge) => void;
  setGameState: (state: GameState) => void;
}

export const CustomTab: React.FC<CustomTabProps> = ({ customChallenges, onAddChallenge, setChallenge, setGameState }) => {
  const [isCreating, setIsCreating] = useState(false);
  const [showToast, setShowToast] = useState(false);

  const handlePlay = (c: Challenge) => {
      setChallenge(c);
      setGameState(GameState.PLAYING);
  };

  const handleFinishCreation = (data: { processedImages: any[], levels: string[][], topicName: string }) => {
    // Convert Wizard Data to Challenge Format
    // processedImages contains {id, name, base64}
    const safeLevels = data.levels.map((lvl: any[]) => lvl.map((id: any) => id || data.processedImages[0].id));

    const newChallenge: Challenge = {
        id: Date.now().toString(),
        topic: data.topicName || 'Custom Mix',
        icon: '📷', // Default icon for custom decks
        isCustom: true,
        rounds: safeLevels.map((levelIds: any[], idx: number) => ({
            id: idx + 1,
            items: levelIds.map((imgId: any) => {
                const img = data.processedImages.find((i: any) => i.id === imgId);
                const fallbackImg = data.processedImages[0]; 
                const safeImg = img || fallbackImg;
                return {
                    word: safeImg.name,
                    emoji: '📷',
                    image: safeImg.base64 // Use the Base64 string here
                };
            })
        }))
    };
    onAddChallenge(newChallenge);
    setIsCreating(false);
    
    // Show Toast
    setShowToast(true);
    setTimeout(() => setShowToast(false), 3000);
  };

  if (isCreating) {
      return <CreateWizard 
        onCancel={() => setIsCreating(false)} 
        onFinish={handleFinishCreation}
      />;
  }

  return (
    <div className="h-full w-full bg-[#111] text-white p-4 md:p-6 flex flex-col items-center custom-scrollbar pb-32">
        {/* Toast Notification */}
        {showToast && (
            <div className="fixed top-10 left-1/2 transform -translate-x-1/2 z-50 bg-green-500 text-black px-6 py-3 rounded-full shadow-[0_0_20px_rgba(34,197,94,0.6)] animate-slide-in-up font-bold uppercase tracking-wider flex items-center gap-2">
                <span>✅</span> Challenge Created!
            </div>
        )}

        {/* Tab Header */}
        <div className="w-full text-center py-4 mb-4 sticky top-0 bg-[#111]/90 backdrop-blur z-40 border-b border-gray-800">
             <h1 className="text-2xl font-display uppercase tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-500">
                 Custom Deck
             </h1>
        </div>

        <div className="max-w-4xl w-full">
            
            {/* Create Button */}
            <button 
                onClick={() => setIsCreating(true)}
                className="w-full py-6 bg-gradient-to-r from-gray-900 to-gray-800 border border-gray-700 rounded-2xl flex flex-row items-center justify-center gap-4 hover:border-yellow-400 transition-all mb-8 group shadow-lg"
            >
                <div className="w-12 h-12 bg-yellow-400 rounded-full flex items-center justify-center text-black font-black text-2xl group-hover:scale-110 group-hover:rotate-90 transition-transform shadow-[0_0_15px_rgba(250,204,21,0.5)]">+</div>
                <div className="text-left">
                    <span className="block font-display text-xl uppercase tracking-wide text-white group-hover:text-yellow-400 transition-colors">Create New</span>
                    <span className="block text-xs text-gray-500 uppercase font-bold tracking-wider">Make your own beat</span>
                </div>
            </button>

            {/* List - Using Grid Layout like TopicList */}
            {customChallenges.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-10 opacity-50">
                    <span className="text-6xl mb-4 grayscale">🎹</span>
                    <p className="text-gray-400 text-center font-bold uppercase tracking-widest text-sm">
                        No custom challenges yet.<br/>Tap above to start!
                    </p>
                </div>
            ) : (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 md:gap-4">
                    {customChallenges.map((c) => {
                         // Get preview images (unique up to 8)
                         const allItems = c.rounds.flatMap(r => r.items);
                         const uniqueImages = Array.from(new Set(allItems.map(i => i.image))).slice(0, 8);
                         // Fill if less than 8
                         while (uniqueImages.length < 8 && uniqueImages.length > 0) {
                             uniqueImages.push(uniqueImages[uniqueImages.length % uniqueImages.length]);
                         }

                         return (
                            <button
                                key={c.id}
                                onClick={() => handlePlay(c)}
                                className="group relative overflow-hidden rounded-2xl border border-gray-700 hover:border-blue-400 transition-all duration-300 flex flex-col items-center justify-center h-32 md:h-44 w-full bg-gray-900"
                            >
                                {/* Background Preview Grid */}
                                <div className="absolute inset-0 bg-white/5">
                                   <div className="w-full h-full grid grid-cols-4 grid-rows-2 gap-0.5 opacity-40 group-hover:opacity-60 blur-[1px] transition-all duration-500">
                                      {uniqueImages.map((imgUrl, idx) => (
                                         <div key={idx} className="w-full h-full bg-black">
                                            <img src={imgUrl} className="w-full h-full object-cover" />
                                         </div>
                                      ))}
                                   </div>
                                </div>

                                {/* Dark Overlay */}
                                <div className="absolute inset-0 bg-gradient-to-t from-black/95 via-black/50 to-transparent" />

                                {/* Content */}
                                <div className="relative z-10 flex flex-col items-center justify-center gap-1 w-full px-2">
                                    <div className="text-3xl mb-1 filter drop-shadow-lg transform group-hover:scale-110 transition-transform">
                                        {c.icon || '📷'}
                                    </div>
                                    <span className="font-display text-lg md:text-xl font-bold uppercase tracking-wide text-white group-hover:text-blue-400 transition-colors text-center leading-tight truncate w-full px-2">
                                        {c.topic}
                                    </span>
                                    <span className="text-[10px] text-gray-400 uppercase font-bold tracking-wider bg-black/50 px-2 py-0.5 rounded-full">
                                        {new Date(parseInt(c.id)).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                                    </span>
                                </div>
                            </button>
                         );
                    })}
                </div>
            )}
        </div>
    </div>
  );
};