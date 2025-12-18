import React, { useEffect, useState, useRef } from 'react';
import { GameState, Challenge, GameSettings, Difficulty } from '../types';
import { audioService } from '../services/audioService';

interface GameProps {
  wordSet: Challenge;
  setGameState: (state: GameState) => void;
  settings: GameSettings;
}

const FEEDBACK_WORDS = ["GOOD!", "PERFECT!", "NICE!", "FIRE!", "WOW!", "AMAZING!", "EXCELLENT!", "COOL!", "NEXT!", "GO!"];

// Decorative stickers
const DECORATIONS = [
  { icon: '⭐', style: 'top-[15%] left-[5%] animate-pulse delay-100 text-yellow-300' },
  { icon: '🎵', style: 'top-[10%] right-[8%] animate-bounce delay-300 text-pink-400' },
  { icon: '✨', style: 'bottom-[20%] left-[8%] animate-pulse delay-500 text-blue-300' },
  { icon: '💖', style: 'bottom-[15%] right-[5%] animate-bounce delay-700 text-red-400' },
  { icon: '🌟', style: 'top-[50%] left-[-10px] md:left-2 animate-spin-slow text-purple-400 opacity-50' },
  { icon: '🚀', style: 'bottom-24 right-[-5px] md:right-2 animate-pulse text-orange-400 opacity-60' }
];

export const Game: React.FC<GameProps> = ({ wordSet: challenge, setGameState, settings }) => {
  const [currentRoundIndex, setCurrentRoundIndex] = useState(0);
  const [beatInBar, setBeatInBar] = useState(0); // 0-3
  
  // Game Logic State
  const [isCountingDown, setIsCountingDown] = useState(true);
  const [countdownValue, setCountdownValue] = useState(3);
  
  // Visual state
  const [activeCardIndex, setActiveCardIndex] = useState<number>(-1);
  const [visibleCardsCount, setVisibleCardsCount] = useState<number>(0);
  
  // Transition flash state
  const [flashFeedback, setFlashFeedback] = useState<string | null>(null);
  
  // Keep track of used feedback words to avoid repetition in a single session
  const usedFeedbackWordsRef = useRef<Set<string>>(new Set());

  const currentRound = challenge.rounds[currentRoundIndex];
  
  const loopRef = useRef({
    tick: 0,
  });

  // --- COUNTDOWN EFFECT ---
  useEffect(() => {
    if (!isCountingDown) return;

    const timer = setInterval(() => {
      setCountdownValue((prev) => {
        if (prev === 1) {
          clearInterval(timer);
          setIsCountingDown(false); // Trigger Game Start
          return 0;
        }
        return prev - 1;
      });
    }, 800); // 800ms per count for a slightly hype feel

    return () => clearInterval(timer);
  }, [isCountingDown]);

  // --- GAME LOOP EFFECT ---
  useEffect(() => {
    // Wait for countdown to finish
    if (isCountingDown) return;

    // Set BPM based on difficulty
    let bpm = 138;
    if (settings.difficulty === Difficulty.EASY) bpm = 120;
    if (settings.difficulty === Difficulty.HARD) bpm = 150;

    audioService.setBpm(bpm);
    audioService.setMusicStyle(settings.musicStyle);
    
    loopRef.current.tick = 0;
    
    // Initial state reset for new round
    setVisibleCardsCount(0);
    setActiveCardIndex(-1);
    setFlashFeedback(null);

    audioService.setOnBeatCallback((beat) => {
      const t = loopRef.current.tick;
      
      // --- 16 BEAT CYCLE (Extended for longer feedback) ---
      // Beats 0-3 (Intro): Populate cards rapidly (2 per beat)
      // Beats 4-11 (Play): Highlight 1 card per beat (8 cards total)
      // Beats 12-15 (Transition): Show Feedback Text (~1.7s)
      
      if (t < 4) {
        // INTRO PHASE
        setActiveCardIndex(-1);
        setVisibleCardsCount((t + 1) * 2); // 2, 4, 6, 8
      } 
      else if (t >= 4 && t < 12) {
        // PLAYING PHASE
        setVisibleCardsCount(8); 
        setActiveCardIndex(t - 4); // Index 0 to 7
      }
      else if (t === 12) {
        // START TRANSITION PHASE
        // Trigger feedback exactly when the last card finishes
        setActiveCardIndex(-1);
        
        // Pick a random word that has NOT been used yet in this session
        const availableWords = FEEDBACK_WORDS.filter(w => !usedFeedbackWordsRef.current.has(w));
        
        let word = "";
        if (availableWords.length > 0) {
            word = availableWords[Math.floor(Math.random() * availableWords.length)];
        } else {
            // Should not happen given 10 words and ~5 rounds, but fallback safely by clearing or picking random
            usedFeedbackWordsRef.current.clear(); 
            word = FEEDBACK_WORDS[Math.floor(Math.random() * FEEDBACK_WORDS.length)];
        }
        
        usedFeedbackWordsRef.current.add(word);
        setFlashFeedback(word);
      }
      else if (t >= 12 && t < 16) {
        // TRANSITION WAIT PHASE
        // Just keeping the beat going, text is displayed
      }

      // Logic to switch round at the VERY END of the cycle (Tick 15 -> 0)
      if (t === 15) {
         const nextRound = currentRoundIndex + 1;
         if (nextRound >= challenge.rounds.length) {
             audioService.stop();
             setGameState(GameState.GAME_OVER);
         } else {
             // This updates state, triggers re-render, and resets this useEffect
             setCurrentRoundIndex(nextRound);
         }
      } else {
         loopRef.current.tick++;
      }
      
      setBeatInBar(beat);
    });
    
    audioService.start();
    
    return () => {
      audioService.stop();
    };
  }, [isCountingDown, currentRoundIndex, challenge.rounds.length, setGameState, settings]);

  const bgPulse = beatInBar === 0 ? 'bg-[#222]' : 'bg-[#111]';

  // --- COUNTDOWN RENDER ---
  if (isCountingDown) {
    return (
      <div className="w-full h-[100dvh] bg-black flex flex-col items-center justify-center relative overflow-hidden">
        {/* Animated Background */}
        <div className="absolute inset-0 opacity-20">
            <div className={`w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-yellow-600 via-black to-black animate-pulse`} />
        </div>
        
        {/* Key prop ensures animation restarts on number change */}
        <h1 
            key={countdownValue}
            className="text-[10rem] md:text-[15rem] font-display font-black text-white italic animate-jump select-none drop-shadow-[0_0_50px_rgba(255,255,0,0.5)]"
        >
          {countdownValue}
        </h1>
        <p className="text-white/50 text-xl font-bold tracking-[1em] uppercase mt-10 animate-slide-up">
          Get Ready
        </p>
      </div>
    );
  }

  // --- MAIN GAME RENDER ---
  return (
    <div className={`relative w-full h-[100dvh] flex flex-col items-center justify-between py-2 md:py-6 overflow-hidden transition-colors duration-75 ${bgPulse}`}>
      
      {/* CUTE BACKGROUND STICKERS */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none z-0">
        {DECORATIONS.map((deco, i) => (
          <div key={i} className={`absolute text-2xl md:text-4xl select-none ${deco.style}`}>
            {deco.icon}
          </div>
        ))}
      </div>

      {/* Top Info Bar */}
      <div className="w-full max-w-4xl px-4 md:px-6 flex items-center justify-between z-10 mt-2">
        <div className="bg-white/10 backdrop-blur px-3 py-1 md:px-4 md:py-2 rounded-xl border border-white/20">
            <span className="text-gray-400 text-[10px] md:text-xs font-bold uppercase tracking-wider mr-2">Topic</span>
            <span className="text-white font-display text-sm md:text-lg tracking-wide">{challenge.topic}</span>
        </div>
        
        <div className="flex flex-col items-center">
            <span className="text-3xl md:text-5xl font-display font-black text-white drop-shadow-lg">
                {currentRoundIndex + 1}<span className="text-xl md:text-2xl text-gray-500">/{challenge.rounds.length}</span>
            </span>
        </div>

        {/* Simple Beat Dots */}
        <div className="flex gap-1.5 md:gap-2">
           {[0,1,2,3].map(i => (
             <div key={i} className={`w-2 h-2 md:w-3 md:h-3 rounded-full transition-all duration-75 ${beatInBar === i ? 'bg-yellow-400 scale-125 shadow-glow' : 'bg-gray-700'}`} />
           ))}
        </div>
      </div>

      {/* Main Grid Area */}
      <div className="flex-1 w-full max-w-5xl flex items-center justify-center p-2 relative z-10">
        
        {/* FEEDBACK FLASH (Between Rounds) */}
        {flashFeedback && (
           <div className="absolute inset-0 z-50 flex items-center justify-center overflow-hidden">
               {/* ANIMATED BACKGROUND FOR FEEDBACK (SAME AS COUNTDOWN) */}
              <div className="absolute inset-0 opacity-80 z-0 bg-black/80"> {/* Dark overlay base */}
                  <div className={`w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-yellow-600 via-black to-black animate-pulse opacity-50`} />
              </div>
              
              {/* FEEDBACK TEXT */}
              <h2 
                key={flashFeedback} /* Also key this to restart animation if same word ever appeared */
                className="relative z-10 text-6xl md:text-[8rem] font-display text-green-400 drop-shadow-[0_0_30px_rgba(0,0,0,1)] animate-[pulse-beat_0.5s_ease-out] rotate-[-5deg]"
                style={{ 
                  WebkitTextStroke: '1px black',
                  paintOrder: 'stroke fill'
                }}
              >
                {flashFeedback}
              </h2>
           </div>
        )}

        {/* Grid Container */}
        <div className="grid grid-cols-4 gap-2 md:gap-5 w-full h-full max-h-[400px] md:max-h-[550px] aspect-[4/2] md:aspect-auto">
           {currentRound.items.map((item, idx) => {
             const isActive = idx === activeCardIndex;
             const isRevealed = idx < visibleCardsCount;
             
             // If not revealed yet, hide it completely (or use placeholder)
             if (!isRevealed) {
                return <div key={idx} className="opacity-0" />;
             }

             return (
               <div 
                 key={idx}
                 className={`
                    relative bg-white rounded-lg md:rounded-xl flex flex-col items-center justify-center
                    overflow-hidden shadow-xl
                    animate-card-enter
                    transition-all duration-75
                    ${isActive 
                        ? 'border-4 md:border-[6px] border-yellow-400 scale-105 z-20 shadow-[0_0_60px_rgba(250,204,21,0.8)]' 
                        : 'border-2 md:border-[6px] border-black scale-100 opacity-100'
                    }
                 `}
               >
                 {/* Card Content (Emoji or Image) */}
                 <div className={`flex-1 flex items-center justify-center w-full overflow-hidden ${!settings.showWordText ? 'h-full' : ''}`}>
                    {item.image ? (
                        <img 
                            src={item.image} 
                            alt={item.word}
                            className={`w-full h-full object-cover transition-transform duration-75 ${isActive ? 'scale-110' : ''}`} 
                        />
                    ) : (
                        <span className={`text-4xl md:text-7xl select-none filter drop-shadow-md transition-transform duration-75 ${isActive ? 'scale-110' : ''}`}>
                            {item.emoji}
                        </span>
                    )}
                 </div>
                 
                 {/* Card Text (Optional) */}
                 {settings.showWordText && (
                   <div className="h-6 md:h-10 w-full flex items-center justify-center bg-black transition-all">
                      <span className={`font-display text-sm md:text-2xl uppercase tracking-wide transition-colors ${isActive ? 'text-yellow-400' : 'text-gray-500'}`}>
                          {item.word}
                      </span>
                   </div>
                 )}
               </div>
             )
           })}
        </div>
      </div>

      {/* Footer Controls */}
      <div className="w-full px-6 pb-4 md:pb-6 flex justify-center z-20">
         <button 
           onClick={() => { audioService.stop(); setGameState(GameState.MAIN); }}
           className="text-gray-600 hover:text-white uppercase font-bold tracking-widest text-xs transition-colors border border-gray-800 hover:border-white px-6 py-2 rounded-full backdrop-blur-sm bg-black/30"
         >
           Stop
         </button>
      </div>

    </div>
  );
};