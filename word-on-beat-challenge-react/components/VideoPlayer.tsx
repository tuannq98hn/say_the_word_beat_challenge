import React from 'react';
import { TikTokVideo } from '../types';

interface VideoPlayerProps {
  video: TikTokVideo;
  onBack: () => void;
}

export const VideoPlayer: React.FC<VideoPlayerProps> = ({ video, onBack }) => {
  // TikTok Embed URL structure
  // Using generic video embed URL. 
  const embedUrl = `https://www.tiktok.com/embed/v2/${video.id}`;
  
  // Real TikTok link to open in app
  const webLink = `https://www.tiktok.com/${video.author}/video/${video.id}`;

  return (
    <div className="fixed inset-0 z-[100] bg-black flex flex-col animate-slide-up">
        {/* Header Bar with prominent Back Button */}
        {/* Changed z-index from z-10 to z-50 to overlap the video iframe */}
        <div className="flex items-center justify-between p-4 bg-gradient-to-b from-black/90 to-transparent absolute top-0 w-full z-50">
            <button 
                onClick={onBack}
                className="group flex items-center gap-2 text-white hover:text-pink-500 transition-all bg-black/60 hover:bg-black/80 px-5 py-2.5 rounded-full backdrop-blur-md border border-white/20 hover:border-pink-500/50 shadow-lg"
            >
                <svg className="w-5 h-5 group-hover:-translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
                </svg>
                <span className="font-bold uppercase text-xs tracking-widest">Back</span>
            </button>
            
            <div className="bg-black/40 px-4 py-2 rounded-full backdrop-blur-md border border-white/10 hidden md:block">
                 <span className="text-white font-display uppercase tracking-wider text-sm">{video.author}</span>
            </div>
        </div>

        {/* Video Area */}
        <div className="flex-1 w-full bg-[#111] flex items-center justify-center relative">
            {/* Background Blur Effect */}
            <div className="absolute inset-0 opacity-20 blur-3xl">
                <img src={video.thumbnailUrl} className="w-full h-full object-cover" />
            </div>

            {/* Iframe Container */}
            <div className="relative z-10 w-full h-full md:w-[400px] md:h-[700px] bg-black shadow-2xl overflow-hidden md:rounded-2xl border border-gray-800">
                 <iframe
                    src={embedUrl}
                    className="w-full h-full"
                    allowFullScreen
                    allow="autoplay; encrypted-media;"
                    title={video.description}
                />
            </div>
        </div>

        {/* Bottom Info Bar */}
        <div className="bg-[#111] border-t border-gray-800 p-6 pb-8 z-50 flex flex-col md:flex-row gap-4 items-center justify-between">
            <div className="flex-1">
                <p className="text-white font-medium text-lg leading-tight mb-2">{video.description}</p>
                <div className="flex gap-2">
                     {video.tags.map(tag => (
                         <span key={tag} className="text-pink-500 text-xs font-bold uppercase tracking-wider">#{tag}</span>
                     ))}
                </div>
            </div>

            <a 
                href={webLink}
                target="_blank"
                rel="noreferrer"
                className="w-full md:w-auto px-8 py-3 bg-gradient-to-r from-pink-600 to-red-600 text-white rounded-full font-bold uppercase tracking-widest text-sm flex items-center justify-center gap-2 hover:scale-105 transition-transform shadow-[0_0_20px_rgba(236,72,153,0.4)]"
            >
                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                     <path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.65-1.58-1.09v8.32c0 2.85-1.87 5.37-4.6 6.27-2.61.9-5.63.26-7.64-1.63-2-1.89-2.58-4.9-1.47-7.44 1.12-2.53 3.9-4.04 6.64-3.61v4.24c-1.39-.31-2.91.48-3.37 1.84-.45 1.37.28 2.89 1.63 3.38 1.48.51 3.12-.22 3.65-1.69.21-.58.26-1.2.14-1.81V.02h.9z" />
                </svg>
                Open in TikTok
            </a>
        </div>
    </div>
  );
};