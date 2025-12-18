import { Challenge } from "../types";

const STORAGE_KEY = 'word_on_beat_custom_challenges';

// Helper: Compress image to Base64 to save space in LocalStorage
// Limits max dimension to 500px and quality to 0.7
export const compressImage = (file: File): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = (event) => {
      const img = new Image();
      img.src = event.target?.result as string;
      img.onload = () => {
        const canvas = document.createElement('canvas');
        const MAX_WIDTH = 500;
        const MAX_HEIGHT = 500;
        let width = img.width;
        let height = img.height;

        if (width > height) {
          if (width > MAX_WIDTH) {
            height *= MAX_WIDTH / width;
            width = MAX_WIDTH;
          }
        } else {
          if (height > MAX_HEIGHT) {
            width *= MAX_HEIGHT / height;
            height = MAX_HEIGHT;
          }
        }

        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        ctx?.drawImage(img, 0, 0, width, height);
        
        // Return Base64 JPEG with quality 0.7
        resolve(canvas.toDataURL('image/jpeg', 0.7));
      };
      img.onerror = (err) => reject(err);
    };
    reader.onerror = (err) => reject(err);
  });
};

export const saveCustomChallenges = (challenges: Challenge[]) => {
  try {
    const json = JSON.stringify(challenges);
    localStorage.setItem(STORAGE_KEY, json);
  } catch (e) {
    console.error("Failed to save to local storage (quota exceeded?)", e);
    alert("Storage full! Try deleting some old custom challenges.");
  }
};

export const loadCustomChallenges = (): Challenge[] => {
  try {
    const json = localStorage.getItem(STORAGE_KEY);
    if (!json) return [];
    return JSON.parse(json);
  } catch (e) {
    console.error("Failed to load custom challenges", e);
    return [];
  }
};

export const deleteCustomChallenge = (id: string): Challenge[] => {
  const current = loadCustomChallenges();
  const updated = current.filter(c => c.id !== id);
  saveCustomChallenges(updated);
  return updated;
};