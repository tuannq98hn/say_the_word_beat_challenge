import React from 'react';
import { GameSettings, Difficulty, MusicStyle } from '../types';

interface SettingsTabProps {
  settings: GameSettings;
  updateSettings: (newSettings: Partial<GameSettings>) => void;
}

export const SettingsTab: React.FC<SettingsTabProps> = ({ settings, updateSettings }) => {
  return (
    <div className="h-full w-full bg-[#111] text-white p-6 flex flex-col pb-24 overflow-y-auto">
        
        {/* Header */}
        <div className="w-full text-center py-4 mb-8 border-b border-gray-800">
            <h1 className="text-2xl font-display uppercase tracking-widest text-white">
                Settings
            </h1>
        </div>

        {/* Content */}
        <div className="space-y-8 max-w-md mx-auto w-full">
            
            {/* 1. Show Text */}
            <div className="space-y-3">
                <label className="text-gray-400 text-xs font-bold uppercase tracking-widest">Visuals</label>
                <div className="flex items-center justify-between bg-gray-900 p-5 rounded-2xl border border-gray-800">
                    <span className="text-white font-bold">Show Text</span>
                    <button 
                        onClick={() => updateSettings({ showWordText: !settings.showWordText })}
                        className={`w-14 h-8 rounded-full p-1 transition-colors duration-300 ${settings.showWordText ? 'bg-green-500' : 'bg-gray-600'}`}
                    >
                        <div className={`w-6 h-6 bg-white rounded-full shadow-md transform transition-transform duration-300 ${settings.showWordText ? 'translate-x-6' : 'translate-x-0'}`} />
                    </button>
                </div>
            </div>

            {/* 2. Difficulty */}
            <div className="space-y-3">
                <label className="text-gray-400 text-xs font-bold uppercase tracking-widest">Difficulty (Speed)</label>
                <div className="grid grid-cols-3 gap-3 bg-gray-900 p-3 rounded-2xl border border-gray-800">
                    {[Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD].map((diff) => (
                        <button
                            key={diff}
                            onClick={() => updateSettings({ difficulty: diff })}
                            className={`py-3 px-1 rounded-xl text-sm font-bold uppercase transition-all ${
                                settings.difficulty === diff 
                                ? 'bg-yellow-500 text-black shadow-lg' 
                                : 'text-gray-500 hover:bg-gray-800'
                            }`}
                        >
                            {diff}
                        </button>
                    ))}
                </div>
            </div>

            {/* 3. Music */}
            <div className="space-y-3">
                <label className="text-gray-400 text-xs font-bold uppercase tracking-widest">Music Style</label>
                <div className="grid grid-cols-3 gap-3 bg-gray-900 p-3 rounded-2xl border border-gray-800">
                    {[MusicStyle.FUNK, MusicStyle.SYNTH, MusicStyle.CHILL].map((style) => (
                        <button
                            key={style}
                            onClick={() => updateSettings({ musicStyle: style })}
                            className={`py-3 px-1 rounded-xl text-sm font-bold uppercase transition-all ${
                                settings.musicStyle === style 
                                ? 'bg-purple-500 text-white shadow-lg' 
                                : 'text-gray-500 hover:bg-gray-800'
                            }`}
                        >
                            {style}
                        </button>
                    ))}
                </div>
            </div>

            <div className="pt-8 text-center text-gray-600 text-xs">
                Version 1.2.0 • Build 2024
            </div>

        </div>
    </div>
  );
};