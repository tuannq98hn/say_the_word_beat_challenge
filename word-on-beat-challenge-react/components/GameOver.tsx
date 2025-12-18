import React, { useEffect, useRef } from 'react';
import { GameState } from '../types';

interface GameOverProps {
  setGameState: (state: GameState) => void;
}

export const GameOver: React.FC<GameOverProps> = ({ setGameState }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // --- FIREWORKS EFFECT ---
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let width = canvas.width = window.innerWidth;
    let height = canvas.height = window.innerHeight;

    interface Particle {
      x: number;
      y: number;
      vx: number;
      vy: number;
      alpha: number;
      color: string;
      decay: number;
    }

    let particles: Particle[] = [];
    
    // Real firework colors (Gold, Silver, Copper, Soft Blue, Soft Red)
    // Less neon/saturated, more elegant
    const colors = ['#FFD700', '#C0C0C0', '#FF8C00', '#87CEEB', '#FF6B6B', '#FFFFFF'];

    const createFirework = (x: number, y: number) => {
      const particleCount = 80; // More particles for a fuller look
      // Real fireworks usually have one dominant color per shell
      const shellColor = colors[Math.floor(Math.random() * colors.length)];
      
      for (let i = 0; i < particleCount; i++) {
        const angle = Math.random() * Math.PI * 2;
        // Non-uniform speed for more natural explosion
        const velocity = Math.random() * 4 + 1; 
        
        particles.push({
          x: x,
          y: y,
          vx: Math.cos(angle) * velocity,
          vy: Math.sin(angle) * velocity,
          alpha: 1,
          color: shellColor,
          decay: Math.random() * 0.015 + 0.005 // Random decay rates
        });
      }
    };

    const animate = () => {
      // Create a trail effect by filling with semi-transparent black
      // Increased opacity (0.2) makes the trail fade faster, reducing visual clutter
      ctx.globalCompositeOperation = 'source-over';
      ctx.fillStyle = 'rgba(0, 0, 0, 0.2)'; 
      ctx.fillRect(0, 0, width, height);
      
      // Use 'lighter' for a glowing light effect where particles overlap
      ctx.globalCompositeOperation = 'lighter';

      for (let i = particles.length - 1; i >= 0; i--) {
        const p = particles[i];
        
        // Physics
        p.vx *= 0.95; // Friction (air resistance) - slows them down
        p.vy *= 0.95; 
        p.vy += 0.04; // Gravity - pulls them down slowly
        
        p.x += p.vx;
        p.y += p.vy;
        p.alpha -= p.decay;

        if (p.alpha <= 0) {
          particles.splice(i, 1);
          continue;
        }

        // Draw particle with glow
        ctx.beginPath();
        ctx.arc(p.x, p.y, 1.5, 0, Math.PI * 2);
        ctx.fillStyle = p.color;
        ctx.globalAlpha = p.alpha * 0.8; // Slightly dim
        
        // Add glow/blur effect
        ctx.shadowBlur = 10;
        ctx.shadowColor = p.color;
        
        ctx.fill();
        
        // Reset shadow for next operations to save performance
        ctx.shadowBlur = 0;
      }

      // Randomly spawn fireworks
      if (Math.random() < 0.03) {
        createFirework(
          Math.random() * width,
          height * 0.2 + Math.random() * (height * 0.5) // Spawn in upper/middle screen
        );
      }

      requestAnimationFrame(animate);
    };

    animate();

    const handleResize = () => {
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <div className="flex flex-col items-center justify-center h-[100dvh] bg-black text-white space-y-8 p-6 relative overflow-hidden">
      
      {/* Canvas for Fireworks */}
      <canvas ref={canvasRef} className="absolute inset-0 z-0 pointer-events-none" />

      <div className="relative z-10 flex flex-col items-center space-y-8 animate-slide-in-up">
        <h1 className="text-6xl md:text-8xl font-display text-transparent bg-clip-text bg-gradient-to-r from-green-400 via-yellow-400 to-blue-500 mb-4 neon-text text-center leading-tight drop-shadow-2xl">
          Challenge<br/>Complete!
        </h1>
        
        <p className="text-xl text-gray-300 max-w-lg text-center font-bold tracking-wide">
          You conquered the beat! What's next?
        </p>

        <div className="flex flex-col md:flex-row gap-4 mt-8 w-full max-w-xs md:max-w-none justify-center">
            <button
            onClick={() => setGameState(GameState.MAIN)}
            className="px-8 py-4 bg-yellow-400 text-black font-black text-xl uppercase rounded-full hover:scale-105 hover:bg-yellow-300 transition-all shadow-[0_0_20px_rgba(250,204,21,0.5)]"
            >
            Play Again
            </button>
            
            <button
            onClick={() => {
                if (navigator.share) {
                navigator.share({
                    title: 'Word On Beat',
                    text: 'I just crushed the Word On Beat challenge!',
                    url: window.location.href
                });
                } else {
                alert("Share URL copied!");
                }
            }}
            className="px-8 py-4 border-2 border-white text-white font-bold text-xl uppercase rounded-full hover:bg-white hover:text-black transition-colors backdrop-blur-sm bg-black/20"
            >
            Share Score
            </button>
        </div>
      </div>
    </div>
  );
};