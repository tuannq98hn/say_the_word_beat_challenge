import React from 'react';
import { AppTab } from '../types';

interface BottomNavProps {
  currentTab: AppTab;
  onTabChange: (tab: AppTab) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ currentTab, onTabChange }) => {
  
  const navItems = [
    { id: AppTab.TRENDING, label: 'Trending', icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
      </svg>
    )},
    { id: AppTab.FEATURED, label: 'Featured', icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    )},
    { id: AppTab.VIDEO, label: 'Video', icon: (
       <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
         <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
         <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
       </svg>
    )},
    { id: AppTab.CUSTOM, label: 'Custom', icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
      </svg>
    )},
    { id: AppTab.SETTINGS, label: 'Settings', icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
    )},
  ];

  return (
    <div className="fixed bottom-0 left-0 w-full z-50">
        {/* Gradient Fade Top */}
        <div className="absolute -top-10 left-0 w-full h-10 bg-gradient-to-t from-black to-transparent pointer-events-none" />
        
        {/* Glassmorphism Bar */}
        <div className="absolute inset-0 bg-black/90 backdrop-blur-xl border-t border-white/10 shadow-[0_-5px_20px_rgba(0,0,0,0.5)]"></div>
        
        <div className="relative flex justify-around items-center pt-3 pb-6 md:pb-6">
            {navItems.map((item) => {
                const isActive = currentTab === item.id;
                // Highlight Video Tab slightly differently
                const isVideo = item.id === AppTab.VIDEO;
                
                return (
                    <button
                        key={item.id}
                        onClick={() => onTabChange(item.id)}
                        className={`group flex flex-col items-center justify-center w-full transition-all duration-300 
                            ${isActive 
                                ? (isVideo ? 'text-pink-500' : 'text-yellow-400') 
                                : 'text-gray-500 hover:text-gray-300'
                            }`}
                    >
                        <div className={`relative p-1 transition-transform duration-300 
                            ${isActive ? '-translate-y-1 scale-110' : 'group-hover:scale-105'}
                        `}>
                            {item.icon}
                            {isActive && (
                                <div className={`absolute inset-0 blur-md rounded-full 
                                    ${isVideo ? 'bg-pink-500/30' : 'bg-yellow-400/30'}`} 
                                />
                            )}
                        </div>
                        <span className={`text-[10px] uppercase font-black tracking-widest transition-opacity duration-300 ${isActive ? 'opacity-100' : 'opacity-70'}`}>
                          {item.label}
                        </span>
                        
                        {/* Active Indicator Dot */}
                        <div className={`w-1 h-1 rounded-full mt-1 transition-all duration-300 
                            ${isActive ? 'opacity-100 scale-100' : 'opacity-0 scale-0'}
                            ${isVideo ? 'bg-pink-500' : 'bg-yellow-400'}
                        `} />
                    </button>
                );
            })}
        </div>
    </div>
  );
};