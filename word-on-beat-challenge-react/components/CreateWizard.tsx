import React, { useState, useRef } from 'react';
import { UploadedImage, CustomCreationData } from '../types';
import { compressImage } from '../services/storageService';

interface CreateWizardProps {
  onCancel: () => void;
  onFinish: (data: any) => void; // Using any here because we pass back processed Base64, not just UploadedImage
}

export const CreateWizard: React.FC<CreateWizardProps> = ({ onCancel, onFinish }) => {
  const [step, setStep] = useState<'UPLOAD' | 'MODE' | 'MANUAL'>('UPLOAD');
  const [images, setImages] = useState<UploadedImage[]>([]);
  const [names, setNames] = useState<Record<string, string>>({});
  const [topicName, setTopicName] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  
  // Manual Sort State
  const [currentLevel, setCurrentLevel] = useState(0); // 0-4
  const [levels, setLevels] = useState<string[][]>(Array(5).fill([]).map(() => Array(8).fill(null)));
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  // --- STEP 1: UPLOAD ---
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const newImages: UploadedImage[] = [];
      Array.from(e.target.files).forEach((item) => {
        const file = item as File;
        newImages.push({
          id: Math.random().toString(36).substr(2, 9),
          file,
          previewUrl: URL.createObjectURL(file),
          name: '' // Init empty name
        });
      });
      // Limit to 4 max total
      const combined = [...images, ...newImages].slice(0, 4);
      setImages(combined);
    }
  };

  const updateName = (id: string, name: string) => {
    setNames(prev => ({ ...prev, [id]: name }));
    setImages(prev => prev.map(img => img.id === id ? { ...img, name } : img));
  };

  // VALIDATION
  const allNamesFilled = images.length > 0 && images.every(img => img.name.trim().length > 0);
  const canProceedFromUpload = images.length >= 2 && allNamesFilled;

  // --- STEP 2: MODE & LOGIC ---
  const handleRandomMode = () => {
    const generatedLevels: string[][] = [];
    const maxLevels = 5;
    const beatPattern = [0, 1, 2, 0, 2, 1, 0, 1]; // Standard rhythm pattern indices

    for (let i = 0; i < maxLevels; i++) {
        let attempts = 0;
        let levelPattern: string[] = [];
        let isUnique = false;

        while (!isUnique && attempts < 20) {
            let subsetSize = images.length;
            if (images.length >= 3) {
                if (i === 0) subsetSize = 2;
                else if (i === 1) subsetSize = Math.min(3, images.length);
            }

            const shuffledImages = [...images].sort(() => 0.5 - Math.random());
            const activeSubset = shuffledImages.slice(0, subsetSize);

            levelPattern = beatPattern.map(beatIdx => {
                const img = activeSubset[beatIdx % activeSubset.length];
                return img.id;
            });

            const currentPatternStr = levelPattern.join(',');
            const isDuplicate = generatedLevels.some(lvl => lvl.join(',') === currentPatternStr);

            if (!isDuplicate) {
                isUnique = true;
            }
            attempts++;
        }
        generatedLevels.push(levelPattern);
    }
    setLevels(generatedLevels);
    setStep('MANUAL');
  };

  // --- STEP 3: MANUAL ---
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);

  const handleSlotClick = (index: number) => {
    setSelectedSlot(index);
  };

  const selectImageForSlot = (imageId: string) => {
    if (selectedSlot !== null) {
        const newLevels = [...levels];
        newLevels[currentLevel][selectedSlot] = imageId;
        setLevels(newLevels);
        setSelectedSlot(null);
    }
  };

  const autoFillLevel = () => {
     const newLevels = [...levels];
     const shuffled = [...images].sort(() => 0.5 - Math.random());
     const patternIndices = [0, 1, 2, 0, 2, 1, 0, 1];
     const filled = patternIndices.map(i => shuffled[i % shuffled.length].id);
     newLevels[currentLevel] = filled;
     setLevels(newLevels);
  };

  const clearCurrentLevel = () => {
      const newLevels = [...levels];
      newLevels[currentLevel] = Array(8).fill(null);
      setLevels(newLevels);
  };

  const handleRestart = () => {
      setLevels(Array(5).fill([]).map(() => Array(8).fill(null)));
      setCurrentLevel(0);
      setStep('UPLOAD');
  };

  // --- FINISH & PROCESSING ---
  const handleFinish = async () => {
      if (!topicName.trim()) {
          alert("Please enter a name for your topic!");
          return;
      }
      setIsProcessing(true);

      try {
        // Compress all images to Base64
        const processedImages = await Promise.all(
            images.map(async (img) => ({
                id: img.id,
                name: img.name,
                // The key part: convert file to compressed base64 string
                base64: await compressImage(img.file) 
            }))
        );

        onFinish({ 
            processedImages, 
            levels, 
            topicName 
        });
      } catch (error) {
          console.error("Error processing images", error);
          alert("Failed to process images. Please try again.");
          setIsProcessing(false);
      }
  };

  // Common wrapper for full screen modal behavior (Hides BottomNav)
  const WizardWrapper: React.FC<{children: React.ReactNode}> = ({children}) => (
      <div className="fixed inset-0 z-[100] bg-black flex flex-col animate-slide-up">
          {children}
          {isProcessing && (
              <div className="absolute inset-0 z-[110] bg-black/80 flex flex-col items-center justify-center">
                  <div className="animate-spin text-4xl mb-4">⏳</div>
                  <div className="text-white font-bold uppercase tracking-widest animate-pulse">Saving Deck...</div>
              </div>
          )}
      </div>
  );

  // RENDERERS (Only showing modified MANUAL renderer for brevity, UPLOAD and MODE are visually same but wrapped)
  
  if (step === 'UPLOAD') {
    return (
      <WizardWrapper>
        <div className="p-6 pb-32 overflow-y-auto custom-scrollbar flex-1">
            <h2 className="text-3xl font-display uppercase text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-orange-500 mb-6 text-center">
                Upload Photos
            </h2>
            
            <button 
                onClick={() => fileInputRef.current?.click()}
                className="w-full h-32 border-2 border-dashed border-gray-700 bg-gray-900/50 rounded-2xl flex flex-col items-center justify-center text-gray-500 hover:border-yellow-400 hover:text-yellow-400 hover:bg-gray-800 transition-all mb-6 group"
            >
                <span className="text-4xl mb-2 group-hover:scale-110 transition-transform">+</span>
                <span className="font-bold uppercase text-xs tracking-widest">Select Photos (2-4)</span>
            </button>
            <input type="file" ref={fileInputRef} hidden multiple accept="image/*" onChange={handleFileChange} />

            <div className="space-y-4">
                {images.map(img => (
                    <div key={img.id} className={`flex items-center bg-gray-900 border ${!img.name.trim() ? 'border-red-500/50' : 'border-gray-800'} p-3 rounded-xl gap-4 animate-slide-up transition-colors`}>
                        <img src={img.previewUrl} alt="preview" className="w-16 h-16 object-cover rounded-lg border border-gray-700" />
                        <div className="flex-1">
                            <label className={`text-[10px] uppercase font-bold tracking-wider ${!img.name.trim() ? 'text-red-400' : 'text-gray-500'}`}>
                                {img.name.trim() ? 'Word Name' : 'Name Required'}
                            </label>
                            <input 
                                type="text" 
                                value={img.name}
                                onChange={(e) => updateName(img.id, e.target.value)}
                                maxLength={10}
                                className="bg-transparent border-b border-gray-700 text-white font-display text-xl focus:border-yellow-400 outline-none w-full placeholder-gray-700"
                                placeholder="ENTER NAME"
                            />
                        </div>
                        <button 
                            onClick={() => setImages(images.filter(i => i.id !== img.id))}
                            className="w-8 h-8 flex items-center justify-center rounded-full bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white transition-colors"
                        >✕</button>
                    </div>
                ))}
            </div>
        </div>

        <div className="absolute bottom-0 left-0 w-full bg-[#111] border-t border-gray-800 p-4 pb-8 z-50 flex justify-between items-center shadow-2xl">
            <button onClick={onCancel} className="text-gray-400 font-bold uppercase tracking-wider text-sm px-4 py-3 hover:text-white transition-colors">
                Cancel
            </button>
            <div className="flex flex-col items-end">
                {!allNamesFilled && images.length > 0 && (
                    <span className="text-[10px] text-red-400 font-bold uppercase mb-2 animate-pulse">Name all images to proceed</span>
                )}
                <button 
                    disabled={!canProceedFromUpload}
                    onClick={() => setStep('MODE')}
                    className={`px-8 py-3 rounded-full font-bold uppercase tracking-widest text-sm shadow-lg transition-all ${canProceedFromUpload ? 'bg-yellow-400 text-black hover:scale-105 hover:bg-yellow-300' : 'bg-gray-800 text-gray-600 cursor-not-allowed'}`}
                >
                    Next Step
                </button>
            </div>
        </div>
      </WizardWrapper>
    );
  }

  if (step === 'MODE') {
      return (
        <WizardWrapper>
            <div className="p-6 h-full flex flex-col items-center justify-center space-y-8 bg-[#111]">
                <h2 className="text-2xl font-display uppercase text-white text-center">How to arrange?</h2>
                <button 
                    onClick={handleRandomMode}
                    className="group w-full max-w-xs p-6 bg-gradient-to-br from-blue-600 to-purple-700 rounded-3xl relative overflow-hidden shadow-2xl hover:scale-105 transition-transform"
                >
                    <div className="relative z-10 flex flex-col items-center">
                        <span className="text-4xl mb-2">🎲</span>
                        <span className="text-xl font-black uppercase text-white tracking-widest">Auto Random</span>
                        <span className="text-xs text-blue-200 mt-2 uppercase font-bold opacity-70">Instant Fun • Smart Mix</span>
                    </div>
                    <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-20 transition-opacity" />
                </button>
                <div className="text-gray-600 font-black uppercase tracking-widest text-sm">- OR -</div>
                <button 
                    onClick={() => setStep('MANUAL')}
                    className="group w-full max-w-xs p-6 bg-gray-900 border border-gray-700 rounded-3xl relative overflow-hidden shadow-lg hover:border-white transition-colors"
                >
                    <div className="relative z-10 flex flex-col items-center">
                        <span className="text-4xl mb-2">🖐️</span>
                        <span className="text-xl font-black uppercase text-gray-300 group-hover:text-white tracking-widest transition-colors">Manual Sort</span>
                        <span className="text-xs text-gray-500 mt-2 uppercase font-bold">Customize beats</span>
                    </div>
                </button>
                <button onClick={() => setStep('UPLOAD')} className="text-gray-500 uppercase font-bold tracking-widest text-xs mt-10 hover:text-white transition-colors">Back to Upload</button>
            </div>
        </WizardWrapper>
      );
  }

  if (step === 'MANUAL') {
      return (
        <WizardWrapper>
            <div className="p-4 pb-32 overflow-y-auto custom-scrollbar flex-1 bg-[#111]">
                 <div className="mb-6 bg-gray-900 p-4 rounded-xl border border-gray-800">
                     <label className="text-[10px] text-gray-500 font-bold uppercase tracking-widest block mb-2">Challenge Topic Name (Required)</label>
                     <input 
                        type="text" 
                        value={topicName}
                        onChange={(e) => setTopicName(e.target.value)}
                        placeholder="e.g. My Funny Mix"
                        className="w-full bg-transparent text-white font-display text-3xl outline-none placeholder-gray-700 border-b-2 border-transparent focus:border-yellow-400 transition-colors"
                        maxLength={20}
                     />
                 </div>

                 <div className="flex justify-between items-center mb-4">
                    <div>
                        <h2 className="text-xl font-display uppercase text-yellow-400">Level {currentLevel + 1}<span className="text-gray-600">/5</span></h2>
                    </div>
                    <div className="flex gap-2">
                         <button 
                            onClick={clearCurrentLevel}
                            className="flex items-center justify-center w-8 h-8 bg-red-500/10 border border-red-500/30 hover:bg-red-500 hover:text-white rounded-full text-red-500 transition-all"
                            title="Clear this level"
                        >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                        <button 
                            onClick={autoFillLevel} 
                            className="flex items-center gap-1 bg-gray-800 hover:bg-gray-700 border border-gray-700 px-3 py-1.5 rounded-full text-blue-400 text-[10px] font-bold uppercase tracking-wider transition-all"
                        >
                            <span>⚡</span> Auto Fill
                        </button>
                    </div>
                 </div>

                 <div className="grid grid-cols-4 gap-3 mb-6">
                    {Array(8).fill(0).map((_, idx) => {
                        const imgId = levels[currentLevel][idx];
                        const img = images.find(i => i.id === imgId);
                        const isSelected = selectedSlot === idx;
                        
                        return (
                            <button 
                                key={idx}
                                onClick={() => handleSlotClick(idx)}
                                className={`
                                    aspect-square rounded-xl flex items-center justify-center overflow-hidden relative transition-all duration-200
                                    ${isSelected 
                                        ? 'border-2 border-yellow-400 ring-4 ring-yellow-400/20 scale-105 z-10' 
                                        : 'border border-gray-800 bg-gray-900 hover:border-gray-600'
                                    }
                                    ${!img ? 'border-dashed' : ''}
                                `}
                            >
                                {img ? (
                                    <>
                                        <img src={img.previewUrl} className="w-full h-full object-cover" />
                                        <div className="absolute inset-x-0 bottom-0 bg-black/70 py-0.5">
                                            <p className="text-[8px] text-white font-bold uppercase text-center truncate px-1">{img.name}</p>
                                        </div>
                                        <div className="absolute top-1 left-1 w-4 h-4 rounded-full bg-black/50 text-[8px] flex items-center justify-center text-white border border-white/20 font-mono">
                                            {idx + 1}
                                        </div>
                                    </>
                                ) : (
                                    <div className="flex flex-col items-center text-gray-700">
                                        <span className="text-xl">+</span>
                                        <span className="text-[8px] font-mono mt-1">{idx + 1}</span>
                                    </div>
                                )}
                            </button>
                        );
                    })}
                 </div>

                 <div className={`transition-all duration-300 ${selectedSlot !== null ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4 pointer-events-none'}`}>
                     <div className="bg-gray-900 border border-gray-800 p-4 rounded-2xl mb-4 shadow-2xl relative z-10">
                         <div className="flex justify-between items-center mb-3">
                            <div className="text-xs text-gray-400 uppercase font-bold tracking-widest">Select Image for Beat {selectedSlot !== null ? selectedSlot + 1 : ''}</div>
                            <button onClick={() => setSelectedSlot(null)} className="text-gray-500 hover:text-white">✕</button>
                         </div>
                         <div className="flex gap-3 overflow-x-auto pb-2 custom-scrollbar">
                            {images.map(img => (
                                <button 
                                    key={img.id} 
                                    onClick={() => selectImageForSlot(img.id)} 
                                    className="shrink-0 w-20 h-20 rounded-xl overflow-hidden border border-gray-700 hover:border-yellow-400 hover:scale-105 transition-all group relative"
                                >
                                    <img src={img.previewUrl} className="w-full h-full object-cover" />
                                    <div className="absolute inset-0 bg-black/40 group-hover:bg-transparent transition-colors" />
                                    <span className="absolute bottom-1 left-1 text-[8px] text-white font-bold uppercase bg-black/60 px-1 rounded">{img.name}</span>
                                </button>
                            ))}
                         </div>
                     </div>
                 </div>
            </div>

             <div className="absolute bottom-0 left-0 w-full bg-[#111] border-t border-gray-800 p-4 pb-8 z-50 flex justify-between items-center shadow-2xl">
                 {currentLevel > 0 ? (
                     <button onClick={() => setCurrentLevel(c => c - 1)} className="px-6 py-3 text-gray-400 hover:text-white font-bold uppercase text-sm tracking-wider">← Back</button>
                 ) : (
                     <button onClick={handleRestart} className="px-6 py-3 text-gray-400 hover:text-white font-bold uppercase text-sm tracking-wider">Restart</button>
                 )}
                 {currentLevel < 4 ? (
                     <button onClick={() => setCurrentLevel(c => c + 1)} className="px-8 py-3 bg-white text-black rounded-full font-bold uppercase text-sm tracking-widest hover:bg-gray-200 transition-colors shadow-lg">Next Level →</button>
                 ) : (
                     <button 
                        onClick={handleFinish}
                        disabled={!topicName.trim()}
                        className={`px-8 py-3 rounded-full font-bold uppercase text-sm tracking-widest shadow-lg transition-all ${topicName.trim() ? 'bg-green-500 text-black hover:bg-green-400 shadow-[0_0_20px_rgba(34,197,94,0.4)]' : 'bg-gray-800 text-gray-500 cursor-not-allowed'}`}
                     >
                        Finish & Save
                     </button>
                 )}
             </div>
        </WizardWrapper>
      );
  }

  return null;
};