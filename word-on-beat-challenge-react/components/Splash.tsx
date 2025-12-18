import React from 'react';

export const Splash: React.FC = () => {
  return (
    <div className="h-[100dvh] w-full bg-black flex flex-col items-center justify-center relative overflow-hidden">
        {/* Abstract Background Animation */}
        <div className="absolute inset-0 flex items-center justify-center opacity-30">
            <div className="w-64 h-64 bg-yellow-500 rounded-full blur-[100px] animate-pulse"></div>
            <div className="w-64 h-64 bg-red-500 rounded-full blur-[100px] animate-bounce delay-75 absolute top-1/4 left-1/4"></div>
        </div>

        <div className="z-10 flex flex-col items-center animate-slide-in-up">
            <span className="text-8xl mb-4">🎵</span>
            <h1 className="text-6xl md:text-8xl font-display uppercase tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 via-orange-500 to-red-500 neon-text">
                Say The Word
            </h1>
            <p className="text-white/70 tracking-[0.5em] uppercase text-sm mt-4 animate-pulse">
                Loading Assets...
            </p>
        </div>
    </div>
  );
};