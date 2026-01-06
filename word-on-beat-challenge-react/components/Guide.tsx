
import React, { useState } from 'react';
import { GameState } from '../types';

interface GuideProps {
  onComplete: () => void;
}

const STEPS = [
  {
    title: "Say On Beat",
    desc: "Đọc to từ hiển thị đúng vào khoảnh khắc thẻ nháy sáng theo nhịp trống.",
    icon: "🎤",
    color: "from-yellow-400 to-orange-500"
  },
  {
    title: "Watch The Flash",
    desc: "Mỗi vòng có 8 nhịp. Hãy giữ sự tập trung vào thẻ có viền vàng rực rỡ.",
    icon: "⚡",
    color: "from-pink-500 to-purple-600"
  },
  {
    title: "Increase Speed",
    desc: "Thử thách bản thân với các mức BPM từ 120 (Dễ) đến 150 (Khó).",
    icon: "🚀",
    color: "from-blue-500 to-cyan-500"
  },
  {
    title: "Create Yours",
    desc: "Tải ảnh của chính bạn lên để tạo những thử thách độc nhất vô nhị!",
    icon: "📸",
    color: "from-green-400 to-emerald-600"
  }
];

export const Guide: React.FC<GuideProps> = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);

  const next = () => {
    if (currentStep < STEPS.length - 1) setCurrentStep(currentStep + 1);
    else onComplete();
  };

  const step = STEPS[currentStep];

  return (
    <div className="fixed inset-0 z-[200] bg-black flex flex-col items-center justify-center p-6">
      <div className="absolute top-10 right-10">
        <button onClick={onComplete} className="text-gray-500 uppercase font-black text-xs tracking-widest hover:text-white">Skip</button>
      </div>

      <div className="w-full max-w-sm flex flex-col items-center text-center animate-card-enter">
        <div className={`w-32 h-32 rounded-3xl bg-gradient-to-br ${step.color} flex items-center justify-center text-6xl shadow-2xl mb-8 animate-bounce`}>
          {step.icon}
        </div>
        
        <h2 className="text-4xl font-display uppercase text-white mb-4 tracking-tight">{step.title}</h2>
        <p className="text-gray-400 text-lg leading-relaxed mb-12">
          {step.desc}
        </p>

        <div className="flex gap-2 mb-12">
          {STEPS.map((_, i) => (
            <div key={i} className={`h-1.5 rounded-full transition-all duration-300 ${i === currentStep ? 'w-8 bg-white' : 'w-2 bg-gray-800'}`} />
          ))}
        </div>

        <button 
          onClick={next}
          className={`w-full py-4 rounded-full font-black uppercase tracking-widest text-sm transition-all transform active:scale-95 bg-white text-black shadow-[0_0_20px_rgba(255,255,255,0.3)]`}
        >
          {currentStep === STEPS.length - 1 ? "Let's Play!" : "Next Step"}
        </button>
      </div>
    </div>
  );
};
