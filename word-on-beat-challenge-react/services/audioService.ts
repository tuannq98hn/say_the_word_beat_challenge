import { MusicStyle } from "../types";

export class AudioService {
  private audioContext: AudioContext | null = null;
  private nextNoteTime: number = 0;
  private timerID: number | null = null;
  private isPlaying: boolean = false;
  private bpm: number = 138; 
  private lookahead: number = 25.0; // ms
  private scheduleAheadTime: number = 0.1; // s
  private currentBeat: number = 0; // 0-3 (quarter notes)
  private currentSubBeat: number = 0; // 0-7 (eighth notes)
  private onBeatCallback: ((beat: number) => void) | null = null;
  private musicStyle: MusicStyle = MusicStyle.FUNK;

  constructor() {
    // Context is initialized on user interaction to comply with browser policies
  }

  public init() {
    if (!this.audioContext) {
      this.audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
  }

  public setBpm(bpm: number) {
    this.bpm = bpm;
  }

  public setMusicStyle(style: MusicStyle) {
    this.musicStyle = style;
  }

  public setOnBeatCallback(cb: (beat: number) => void) {
    this.onBeatCallback = cb;
  }

  public start() {
    if (this.isPlaying) return;
    this.init();
    if (this.audioContext?.state === 'suspended') {
      this.audioContext.resume();
    }
    
    this.isPlaying = true;
    this.currentBeat = 0;
    this.currentSubBeat = 0;
    this.nextNoteTime = this.audioContext!.currentTime + 0.1;
    this.scheduler();
  }

  public stop() {
    this.isPlaying = false;
    if (this.timerID) {
      window.clearTimeout(this.timerID);
      this.timerID = null;
    }
  }

  private scheduler() {
    if (!this.audioContext) return;

    // Schedule up to the next 100ms
    while (this.nextNoteTime < this.audioContext.currentTime + this.scheduleAheadTime) {
      this.scheduleNote(this.currentSubBeat, this.nextNoteTime);
      this.nextNote();
    }
    
    if (this.isPlaying) {
      this.timerID = window.setTimeout(() => this.scheduler(), this.lookahead);
    }
  }

  private nextNote() {
    // We schedule eighth notes now for better hi-hats
    const secondsPerEighth = (60.0 / this.bpm) / 2;
    this.nextNoteTime += secondsPerEighth;
    
    this.currentSubBeat++;
    if (this.currentSubBeat === 8) {
      this.currentSubBeat = 0;
    }
    
    // Update quarter beat counter every 2 eighths
    if (this.currentSubBeat % 2 === 0) {
      this.currentBeat = this.currentSubBeat / 2;
    }
  }

  private scheduleNote(subBeat: number, time: number) {
    if (!this.audioContext) return;

    const isDownBeat = subBeat % 2 === 0;
    const quarterBeat = Math.floor(subBeat / 2);

    // Call visual callback only on quarter notes (the main beat)
    if (isDownBeat) {
        const delay = (time - this.audioContext.currentTime) * 1000;
        setTimeout(() => {
        if (this.onBeatCallback && this.isPlaying) {
            this.onBeatCallback(quarterBeat);
        }
        }, Math.max(0, delay));
    }

    const osc = this.audioContext.createOscillator();
    const gainNode = this.audioContext.createGain();
    osc.connect(gainNode);
    gainNode.connect(this.audioContext.destination);

    // Tone Configuration based on MusicStyle
    let kickFreq = 150;
    let hiHatType: OscillatorType = 'square';
    let snareType: OscillatorType = 'triangle';

    switch (this.musicStyle) {
      case MusicStyle.SYNTH:
        kickFreq = 120;
        hiHatType = 'sawtooth';
        snareType = 'square';
        break;
      case MusicStyle.CHILL:
        kickFreq = 100;
        hiHatType = 'sine'; // Softer
        snareType = 'sine';
        break;
      case MusicStyle.FUNK:
      default:
        kickFreq = 150;
        hiHatType = 'square';
        snareType = 'triangle';
        break;
    }

    if (isDownBeat) {
      // KICK (Every downbeat)
      osc.frequency.setValueAtTime(kickFreq, time);
      osc.frequency.exponentialRampToValueAtTime(0.01, time + 0.5);
      gainNode.gain.setValueAtTime(1.0, time);
      gainNode.gain.exponentialRampToValueAtTime(0.01, time + 0.5);
      osc.start(time);
      osc.stop(time + 0.5);
      
      // CLAP/SNARE (On beats 2 and 4 - indices 1 and 3)
      if (quarterBeat === 1 || quarterBeat === 3) {
         const noiseOsc = this.audioContext.createOscillator();
         const noiseGain = this.audioContext.createGain();
         noiseOsc.connect(noiseGain);
         noiseGain.connect(this.audioContext.destination);
         
         noiseOsc.type = snareType; 
         noiseOsc.frequency.setValueAtTime(400, time);
         if (this.musicStyle === MusicStyle.CHILL) {
             noiseOsc.frequency.setValueAtTime(200, time); // Lower snare for chill
         }

         noiseGain.gain.setValueAtTime(0.5, time);
         noiseGain.gain.exponentialRampToValueAtTime(0.01, time + 0.15);
         
         noiseOsc.start(time);
         noiseOsc.stop(time + 0.2);
      }
    } else {
      // HI-HAT (Off-beats)
      osc.type = hiHatType;
      osc.frequency.setValueAtTime(3000, time); 
      
      const vol = this.musicStyle === MusicStyle.CHILL ? 0.05 : 0.1;

      gainNode.gain.setValueAtTime(vol, time);
      gainNode.gain.exponentialRampToValueAtTime(0.01, time + 0.05);
      osc.start(time);
      osc.stop(time + 0.05);
    }
  }
}

export const audioService = new AudioService();