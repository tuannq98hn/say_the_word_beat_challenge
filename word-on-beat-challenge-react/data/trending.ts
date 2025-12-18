import { Challenge } from "../types";
import { makeChallenge } from "./utils";

export const TRENDING_METADATA = [
  { id: 'classic', label: 'Classic Mix', icon: '🎤', prompt: 'Classic simple English rhymes' },
  { id: 'animals', label: 'Animal Farm', icon: '🐮', prompt: 'Animals that rhyme' },
  { id: 'halloween', label: 'Spooky Vibes', icon: '👻', prompt: 'Halloween themes' },
  { id: 'food', label: 'Yummy Foods', icon: '🍔', prompt: 'Foods that rhyme' },
  { id: 'tech', label: 'Tech Life', icon: '💻', prompt: 'Technology terms' },
  { id: 'hard', label: 'Tongue Twisters', icon: '🔥', prompt: 'Difficult similar sounding words' },
  { id: 'viral', label: 'Viral Trends', icon: '📈', prompt: 'Trending social media words' },
  { id: 'slang', label: 'Gen Z Slang', icon: '😎', prompt: 'Modern slang words' },
  { id: 'christmas', label: 'Xmas Time', icon: '🎄', prompt: 'Christmas rhyming words' },
  { id: 'summer', label: 'Summer Fun', icon: '🏖️', prompt: 'Summer vacation words' },
  { id: 'gaming', label: 'Gamer Zone', icon: '🎮', prompt: 'Video game terminology' },
  { id: 'music', label: 'Music Genres', icon: '🎵', prompt: 'Musical instruments and styles' },
];

export const TRENDING_DATA: Record<string, Challenge> = {
    'classic': makeChallenge('classic', 'Classic Mix', '🎤', [
        [{w:'Cat',e:'🐱'}, {w:'Bat',e:'🦇'}, {w:'Hat',e:'🎩'}],
        [{w:'Dog',e:'🐶'}, {w:'Log',e:'🪵'}, {w:'Frog',e:'🐸'}],
        [{w:'Pen',e:'🖊️'}, {w:'Hen',e:'🐔'}, {w:'Ten',e:'🔟'}],
        [{w:'Box',e:'📦'}, {w:'Fox',e:'🦊'}, {w:'Sox',e:'🧦'}],
        [{w:'Sun',e:'☀️'}, {w:'Run',e:'🏃'}, {w:'Bun',e:'🥯'}]
    ]),
    'animals': makeChallenge('animals', 'Animal Farm', '🐮', [
        [{w:'Bear',e:'🐻'}, {w:'Pear',e:'🍐'}, {w:'Hare',e:'🐇'}],
        [{w:'Mouse',e:'🐭'}, {w:'House',e:'🏠'}, {w:'Blouse',e:'👚'}],
        [{w:'Bee',e:'🐝'}, {w:'Key',e:'🔑'}, {w:'Tree',e:'🌳'}],
        [{w:'Snake',e:'🐍'}, {w:'Cake',e:'🍰'}, {w:'Lake',e:'🌊'}],
        [{w:'Goat',e:'🐐'}, {w:'Boat',e:'⛵'}, {w:'Coat',e:'🧥'}]
    ]),
    'halloween': makeChallenge('halloween', 'Spooky Vibes', '👻', [
        [{w:'Ghost',e:'👻'}, {w:'Toast',e:'🍞'}, {w:'Post',e:'📮'}],
        [{w:'Witch',e:'🧙‍♀️'}, {w:'Switch',e:'🔘'}, {w:'Pitch',e:'⛺'}],
        [{w:'Bat',e:'🦇'}, {w:'Cat',e:'🐈‍⬛'}, {w:'Mat',e:'🧘'}],
        [{w:'Bone',e:'🦴'}, {w:'Phone',e:'📱'}, {w:'Cone',e:'🍦'}],
        [{w:'Night',e:'🌑'}, {w:'Light',e:'💡'}, {w:'Kite',e:'🪁'}]
    ]),
    'food': makeChallenge('food', 'Yummy Foods', '🍔', [
        [{w:'Pie',e:'🥧'}, {w:'Eye',e:'👁️'}, {w:'Fly',e:'🪰'}],
        [{w:'Cake',e:'🍰'}, {w:'Rake',e:'🍂'}, {w:'Snake',e:'🐍'}],
        [{w:'Ice',e:'🧊'}, {w:'Rice',e:'🍚'}, {w:'Mice',e:'🐁'}],
        [{w:'Nut',e:'🥜'}, {w:'Hut',e:'🛖'}, {w:'Cut',e:'✂️'}],
        [{w:'Jam',e:'🍓'}, {w:'Ham',e:'🍖'}, {w:'Ram',e:'🐏'}]
    ]),
    'tech': makeChallenge('tech', 'Tech Life', '💻', [
        [{w:'Code',e:'💻'}, {w:'Road',e:'🛣️'}, {w:'Load',e:'⏳'}],
        [{w:'Byte',e:'💾'}, {w:'Kite',e:'🪁'}, {w:'Light',e:'💡'}],
        [{w:'Mouse',e:'🖱️'}, {w:'House',e:'🏠'}, {w:'Douse',e:'🧯'}],
        [{w:'Net',e:'🌐'}, {w:'Jet',e:'✈️'}, {w:'Pet',e:'🐕'}],
        [{w:'Chip',e:'💾'}, {w:'Ship',e:'🚢'}, {w:'Dip',e:'🥣'}]
    ]),
    'hard': makeChallenge('hard', 'Tongue Twisters', '🔥', [
        [{w:'Shells',e:'🐚'}, {w:'Bells',e:'🔔'}, {w:'Wells',e:'🕳️'}],
        [{w:'Fuzzy',e:'🧶'}, {w:'Wuzzy',e:'🧸'}, {w:'Buzz',e:'🐝'}],
        [{w:'Wood',e:'🪵'}, {w:'Hood',e:'🧥'}, {w:'Good',e:'👍'}],
        [{w:'Scream',e:'😱'}, {w:'Dream',e:'💭'}, {w:'Cream',e:'🍦'}],
        [{w:'Butter',e:'🧈'}, {w:'Gutter',e:'🛣️'}, {w:'Mutter',e:'🗣️'}]
    ]),
    'viral': makeChallenge('viral', 'Viral Trends', '📈', [
        [{w:'Tok',e:'🎵'}, {w:'Clock',e:'⏰'}, {w:'Rock',e:'🪨'}],
        [{w:'Meme',e:'🐸'}, {w:'Team',e:'👥'}, {w:'Beam',e:'🔦'}],
        [{w:'Post',e:'📝'}, {w:'Toast',e:'🥂'}, {w:'Ghost',e:'👻'}],
        [{w:'Like',e:'👍'}, {w:'Bike',e:'🚲'}, {w:'Hike',e:'🥾'}],
        [{w:'Stream',e:'🔴'}, {w:'Dream',e:'💤'}, {w:'Cream',e:'🍨'}]
    ]),
    'slang': makeChallenge('slang', 'Gen Z Slang', '😎', [
        [{w:'Cap',e:'🧢'}, {w:'Map',e:'🗺️'}, {w:'Nap',e:'😴'}],
        [{w:'Slay',e:'💅'}, {w:'Play',e:'🎮'}, {w:'Tray',e:'📥'}],
        [{w:'Drip',e:'💧'}, {w:'Trip',e:'✈️'}, {w:'Ship',e:'🚢'}],
        [{w:'Lit',e:'🔥'}, {w:'Fit',e:'👗'}, {w:'Kit',e:'🧰'}],
        [{w:'Bet',e:'🤝'}, {w:'Jet',e:'✈️'}, {w:'Net',e:'🥅'}]
    ]),
    'christmas': makeChallenge('christmas', 'Xmas Time', '🎄', [
        [{w:'Snow',e:'❄️'}, {w:'Bow',e:'🎀'}, {w:'Glow',e:'🌟'}],
        [{w:'Deer',e:'🦌'}, {w:'Gear',e:'⚙️'}, {w:'Ear',e:'👂'}],
        [{w:'Sled',e:'🛷'}, {w:'Bed',e:'🛏️'}, {w:'Red',e:'🔴'}],
        [{w:'Gift',e:'🎁'}, {w:'Lift',e:'🏋️'}, {w:'Sift',e:'🥣'}],
        [{w:'Tree',e:'🎄'}, {w:'Free',e:'🕊️'}, {w:'Key',e:'🔑'}]
    ]),
    'summer': makeChallenge('summer', 'Summer Fun', '🏖️', [
        [{w:'Sun',e:'☀️'}, {w:'Bun',e:'🌭'}, {w:'Fun',e:'🎢'}],
        [{w:'Sand',e:'🏖️'}, {w:'Hand',e:'✋'}, {w:'Band',e:'🎸'}],
        [{w:'Hot',e:'🥵'}, {w:'Pot',e:'🍲'}, {w:'Dot',e:'⚫'}],
        [{w:'Pool',e:'🏊'}, {w:'Cool',e:'😎'}, {w:'Tool',e:'🔧'}],
        [{w:'Sea',e:'🌊'}, {w:'Tea',e:'🍵'}, {w:'Bee',e:'🐝'}]
    ]),
    'gaming': makeChallenge('gaming', 'Gamer Zone', '🎮', [
        [{w:'Game',e:'🎮'}, {w:'Name',e:'🏷️'}, {w:'Flame',e:'🔥'}],
        [{w:'Win',e:'🏆'}, {w:'Bin',e:'🗑️'}, {w:'Pin',e:'📌'}],
        [{w:'Lag',e:'🐌'}, {w:'Bag',e:'🎒'}, {w:'Flag',e:'🚩'}],
        [{w:'Mod',e:'🛠️'}, {w:'Pod',e:'🎧'}, {w:'Nod',e:'🙆'}],
        [{w:'Quest',e:'🛡️'}, {w:'Vest',e:'🦺'}, {w:'Chest',e:'📦'}]
    ]),
    'music': makeChallenge('music', 'Music Genres', '🎵', [
        [{w:'Beat',e:'🥁'}, {w:'Seat',e:'🪑'}, {w:'Heat',e:'🔥'}],
        [{w:'Song',e:'🎵'}, {w:'Long',e:'📏'}, {w:'Gong',e:'🛎️'}],
        [{w:'Rap',e:'🎤'}, {w:'Cap',e:'🧢'}, {w:'Map',e:'🗺️'}],
        [{w:'Pop',e:'🍿'}, {w:'Top',e:'🔝'}, {w:'Mop',e:'🧹'}],
        [{w:'Jazz',e:'🎷'}, {w:'Fuzz',e:'🧶'}, {w:'Buzz',e:'🐝'}]
    ])
};