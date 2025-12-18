import React, { useEffect, useState } from 'react';
import { TikTokVideo } from '../types';
import { fetchTikTokVideos } from '../services/videoService';

interface VideoTabProps {
  onVideoClick: (video: TikTokVideo) => void;
}

export const VideoTab: React.FC<VideoTabProps> = ({ onVideoClick }) => {
  const [videos, setVideos] = useState<TikTokVideo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
        try {
            const data = await fetchTikTokVideos();
            setVideos(data);
        } catch (error) {
            console.error("Failed to load videos", error);
        } finally {
            setLoading(false);
        }
    };
    loadData();
  }, []);

  // Shimmer Item Component
  const ShimmerItem = () => (
      <div className="bg-gray-900 rounded-xl overflow-hidden h-64 flex flex-col relative">
          <div className="flex-1 bg-gray-800 animate-pulse relative overflow-hidden">
             <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent skew-x-12 animate-shimmer" />
          </div>
          <div className="p-3 space-y-2">
              <div className="h-3 w-1/2 bg-gray-800 rounded animate-pulse" />
              <div className="h-3 w-3/4 bg-gray-800 rounded animate-pulse" />
          </div>
      </div>
  );

  return (
    <div className="h-full w-full bg-[#111] text-white p-4 md:p-6 flex flex-col items-center custom-scrollbar pb-32 overflow-y-auto">
        
        {/* Header */}
        <div className="w-full text-center py-4 mb-4 sticky top-0 bg-[#111]/90 backdrop-blur z-40 border-b border-gray-800">
             <h1 className="text-2xl font-display uppercase tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-pink-500 to-cyan-500">
                 Video Challenge
             </h1>
        </div>

        <div className="max-w-4xl w-full grid grid-cols-2 md:grid-cols-3 gap-4">
            {loading ? (
                // Render 6 Shimmer Items
                Array(6).fill(0).map((_, i) => <ShimmerItem key={i} />)
            ) : (
                videos.map((video) => (
                    <button 
                        key={video.id}
                        onClick={() => onVideoClick(video)}
                        className="group bg-gray-900 rounded-xl overflow-hidden text-left border border-gray-800 hover:border-pink-500 transition-all duration-300 relative hover:-translate-y-1 shadow-lg"
                    >
                        {/* Thumbnail Container */}
                        <div className="aspect-[9/16] relative overflow-hidden">
                            <img 
                                src={video.thumbnailUrl} 
                                alt={video.description} 
                                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                            />
                            {/* Play Icon Overlay */}
                            <div className="absolute inset-0 bg-black/30 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                <div className="w-12 h-12 bg-white/20 backdrop-blur rounded-full flex items-center justify-center">
                                    <svg className="w-6 h-6 text-white fill-current" viewBox="0 0 24 24">
                                        <path d="M8 5v14l11-7z" />
                                    </svg>
                                </div>
                            </div>
                            
                            {/* Gradient Overlay at Bottom */}
                            <div className="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-black to-transparent opacity-80" />
                        </div>

                        {/* Info */}
                        <div className="absolute bottom-0 left-0 w-full p-3 z-10">
                            <div className="flex items-center gap-1 mb-1">
                                <span className="text-[10px] bg-pink-600 text-white px-1.5 py-0.5 rounded font-bold uppercase tracking-wider">
                                    TikTok
                                </span>
                                <span className="text-xs font-bold text-gray-300 truncate">{video.author}</span>
                            </div>
                            <p className="text-sm font-medium text-white line-clamp-2 leading-tight drop-shadow-md">
                                {video.description}
                            </p>
                            <div className="flex gap-1 mt-1.5 flex-wrap">
                                {video.tags.map(tag => (
                                    <span key={tag} className="text-[9px] text-cyan-400 font-bold uppercase">#{tag}</span>
                                ))}
                            </div>
                        </div>
                    </button>
                ))
            )}
        </div>
    </div>
  );
};