import { Challenge, ChallengeItem } from "../types";

// Helper to expand 3 items into 8 for a round using the standard rhythm pattern
export const expandItems = (items: ChallengeItem[]): ChallengeItem[] => {
  if (items.length < 3) return items;
  const pattern = [0, 1, 2, 0, 2, 1, 0, 1]; 
  return pattern.map(i => items[i]);
};

// Helper to create a Challenge object from compact data
export const makeChallenge = (
  id: string, 
  topic: string, 
  icon: string, 
  wordSets: {w:string, e:string}[][]
): Challenge => {
    return {
        id, 
        topic, 
        icon,
        isCustom: false,
        rounds: wordSets.map((set, idx) => ({
            id: idx + 1,
            items: expandItems(set.map(s => ({ word: s.w, emoji: s.e })))
        }))
    };
};