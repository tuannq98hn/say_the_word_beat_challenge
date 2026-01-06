
import React from 'react';
import { MusicStyle, Difficulty, GameSettings } from '../types';

interface StyleSelectionProps {
  onSelect: (settings: Partial<GameSettings>) => void;
}

const STYLES = [
  {
    id: MusicStyle.FUNK,
    name: "Classic Funk",
    desc: "Nhịp 138 BPM tiêu chuẩn. Vui nhộn và dễ bắt nhịp.",
    icon: "🎸",
    diff: Difficulty.MEDIUM,
    color: "border-yellow-500/50 bg-yellow-500/10"
  },
  {
    id: MusicStyle.SYNTH,
    name: "Neon Hype",
    desc: "150 BPM cực bốc. Dành cho những pro đọc từ siêu tốc.",
    icon: "🌃",
    diff: Difficulty.HARD,
    color: "border-pink-500/50 bg-pink-500/10"
  },
  {
    id: MusicStyle.CHILL,
    name: "Lo-fi Chill",
    desc: "120 BPM thư giãn. Hoàn hảo để luyện tập cảm nhịp.",
    icon: "☁️",
    diff: Difficulty.EASY,
    color: "border-blue-500/50 bg-blue-500/10"
  }
];

export const StyleSelection: React.FC<StyleSelectionProps> = ({ onSelect }) => {
  return (
    <div className="fixed inset-0 z-[150] bg-black/95 backdrop-blur-md flex flex-col items-center justify-center p-6 overflow-y-auto">
      <h1 className="text-3xl font-display uppercase text-white mb-2 tracking-tighter">Choose Your Style</h1>
      <p className="text-gray-500 text-sm uppercase font-bold tracking-widest mb-8">Personalize your challenge experience</p>

      <div className="grid grid-cols-1 gap-4 w-full max-w-sm">
        {STYLES.map((style) => (
          <button
            key={style.id}
            onClick={() => onSelect({ musicStyle: style.id, difficulty: style.diff })}
            className={`flex items-center p-5 rounded-2xl border-2 transition-all hover:scale-[1.02] active:scale-95 text-left group ${style.color}`}
          >
            <div className="text-4xl mr-5 group-hover:rotate-12 transition-transform">{style.icon}</div>
            <div className="flex-1">
              <h3 className="text-white font-black uppercase text-lg leading-none mb-1">{style.name}</h3>
              <p className="text-gray-400 text-xs leading-tight mb-2">{style.desc}</p>
              <span className="text-[10px] font-black uppercase tracking-widest bg-white/10 px-2 py-0.5 rounded text-white/50">
                {style.diff} • {style.id}
              </span>
            </div>
          </button>
        ))}
      </div>

      <p className="mt-8 text-gray-600 text-[10px] uppercase font-bold tracking-widest">You can change this anytime in Settings</p>
    </div>
  );
};
