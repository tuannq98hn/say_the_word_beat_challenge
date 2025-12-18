import { Challenge } from "../types";
import { makeChallenge } from "./utils";

export const FEATURED_METADATA = [
  { id: 'nature', label: 'Nature Walk', icon: '🌿', prompt: 'Nature terms' },
  { id: 'city', label: 'City Life', icon: '🏙️', prompt: 'Urban terms' },
  { id: 'home', label: 'Household', icon: '🏠', prompt: 'Home objects' },
  { id: 'sports', label: 'Sports', icon: '⚽', prompt: 'Sports terms' },
  { id: 'colors', label: 'Colors', icon: '🎨', prompt: 'Colors rhyming' },
  { id: 'school', label: 'School Days', icon: '🎒', prompt: 'School items' },
  { id: 'space', label: 'Space Travel', icon: '🚀', prompt: 'Space and planets' },
  { id: 'ocean', label: 'Deep Blue', icon: '🌊', prompt: 'Sea creatures and ocean terms' },
  { id: 'fantasy', label: 'Mythical', icon: '🐉', prompt: 'Fantasy creatures and magic' },
  { id: 'jobs', label: 'Professions', icon: '👨‍⚕️', prompt: 'Jobs and careers' },
  { id: 'clothes', label: 'Fashion', icon: '👗', prompt: 'Clothing items' },
  { id: 'body', label: 'Body Parts', icon: '💪', prompt: 'Body parts rhyming' },
];

export const FEATURED_DATA: Record<string, Challenge> = {
    'nature': makeChallenge('nature', 'Nature Walk', '🌿', [
        [{w:'Leaf',e:'🍂'}, {w:'Reef',e:'🪸'}, {w:'Beef',e:'🥩'}],
        [{w:'Sky',e:'☁️'}, {w:'Fly',e:'🪰'}, {w:'Pie',e:'🥧'}],
        [{w:'Rain',e:'🌧️'}, {w:'Train',e:'🚂'}, {w:'Brain',e:'🧠'}],
        [{w:'Wood',e:'🪵'}, {w:'Hood',e:'🧥'}, {w:'Good',e:'👍'}],
        [{w:'Bloom',e:'🌸'}, {w:'Room',e:'🏠'}, {w:'Broom',e:'🧹'}]
    ]),
    'city': makeChallenge('city', 'City Life', '🏙️', [
        [{w:'Street',e:'🛣️'}, {w:'Sweet',e:'🍬'}, {w:'Feet',e:'👣'}],
        [{w:'Car',e:'🚗'}, {w:'Star',e:'⭐'}, {w:'Jar',e:'🏺'}],
        [{w:'Town',e:'🏙️'}, {w:'Gown',e:'👗'}, {w:'Crown',e:'👑'}],
        [{w:'Bus',e:'🚌'}, {w:'Plus',e:'➕'}, {w:'Us',e:'👥'}],
        [{w:'Mall',e:'🛍️'}, {w:'Ball',e:'⚽'}, {w:'Call',e:'📞'}]
    ]),
    'home': makeChallenge('home', 'Household', '🏠', [
        [{w:'Door',e:'🚪'}, {w:'Floor',e:'🪵'}, {w:'Roar',e:'🦁'}],
        [{w:'Chair',e:'🪑'}, {w:'Hair',e:'💇'}, {w:'Bear',e:'🐻'}],
        [{w:'Lamp',e:'🛋️'}, {w:'Camp',e:'⛺'}, {w:'Stamp',e:'✉️'}],
        [{w:'Rug',e:'🧶'}, {w:'Mug',e:'☕'}, {w:'Bug',e:'🪲'}],
        [{w:'Bed',e:'🛏️'}, {w:'Red',e:'🔴'}, {w:'Sled',e:'🛷'}]
    ]),
    'sports': makeChallenge('sports', 'Sports', '⚽', [
        [{w:'Ball',e:'🏀'}, {w:'Wall',e:'🧱'}, {w:'Call',e:'📞'}],
        [{w:'Bat',e:'🏏'}, {w:'Hat',e:'🧢'}, {w:'Mat',e:'🧘'}],
        [{w:'Run',e:'🏃'}, {w:'Sun',e:'☀️'}, {w:'Fun',e:'🎢'}],
        [{w:'Kick',e:'🦵'}, {w:'Pick',e:'⛏️'}, {w:'Stick',e:'🏒'}],
        [{w:'Score',e:'💯'}, {w:'Door',e:'🚪'}, {w:'More',e:'➕'}]
    ]),
    'colors': makeChallenge('colors', 'Colors', '🎨', [
        [{w:'Blue',e:'🔵'}, {w:'Glue',e:'🧴'}, {w:'Shoe',e:'👟'}],
        [{w:'Red',e:'🔴'}, {w:'Bed',e:'🛏️'}, {w:'Sled',e:'🛷'}],
        [{w:'Pink',e:'🌸'}, {w:'Sink',e:'🚰'}, {w:'Wink',e:'😉'}],
        [{w:'Green',e:'🟢'}, {w:'Queen',e:'👑'}, {w:'Bean',e:'🫘'}],
        [{w:'White',e:'⚪'}, {w:'Light',e:'💡'}, {w:'Kite',e:'🪁'}]
    ]),
    'school': makeChallenge('school', 'School Days', '🎒', [
        [{w:'Book',e:'📚'}, {w:'Cook',e:'👨‍🍳'}, {w:'Look',e:'👀'}],
        [{w:'Pen',e:'🖊️'}, {w:'Hen',e:'🐔'}, {w:'Ten',e:'🔟'}],
        [{w:'Class',e:'🏫'}, {w:'Glass',e:'🥛'}, {w:'Grass',e:'🌱'}],
        [{w:'Map',e:'🗺️'}, {w:'Cap',e:'🧢'}, {w:'Lap',e:'💻'}],
        [{w:'Test',e:'📝'}, {w:'Vest',e:'🦺'}, {w:'Best',e:'🥇'}]
    ]),
    'space': makeChallenge('space', 'Space Travel', '🚀', [
        [{w:'Star',e:'⭐'}, {w:'Car',e:'🚗'}, {w:'Jar',e:'🏺'}],
        [{w:'Moon',e:'🌙'}, {w:'Spoon',e:'🥄'}, {w:'Balloon',e:'🎈'}],
        [{w:'Mars',e:'🔴'}, {w:'Cars',e:'🚗'}, {w:'Bars',e:'📊'}],
        [{w:'Sun',e:'☀️'}, {w:'Run',e:'🏃'}, {w:'Bun',e:'🥯'}],
        [{w:'Space',e:'🌌'}, {w:'Race',e:'🏎️'}, {w:'Face',e:'😀'}]
    ]),
    'ocean': makeChallenge('ocean', 'Deep Blue', '🌊', [
        [{w:'Fish',e:'🐟'}, {w:'Dish',e:'🍽️'}, {w:'Wish',e:'🧞'}],
        [{w:'Whale',e:'🐋'}, {w:'Tail',e:'🐕'}, {w:'Mail',e:'✉️'}],
        [{w:'Shell',e:'🐚'}, {w:'Bell',e:'🔔'}, {w:'Well',e:'🕳️'}],
        [{w:'Shark',e:'🦈'}, {w:'Park',e:'🏞️'}, {w:'Dark',e:'🌑'}],
        [{w:'Sand',e:'🏖️'}, {w:'Hand',e:'✋'}, {w:'Band',e:'🎸'}]
    ]),
    'fantasy': makeChallenge('fantasy', 'Mythical', '🐉', [
        [{w:'King',e:'👑'}, {w:'Ring',e:'💍'}, {w:'Wing',e:'💸'}],
        [{w:'Queen',e:'👸'}, {w:'Green',e:'🟢'}, {w:'Bean',e:'🫘'}],
        [{w:'Dragon',e:'🐉'}, {w:'Wagon',e:'🚃'}, {w:'Flagon',e:'🍺'}],
        [{w:'Knight',e:'⚔️'}, {w:'Light',e:'💡'}, {w:'Night',e:'🌑'}],
        [{w:'Elf',e:'🧝'}, {w:'Shelf',e:'📚'}, {w:'Self',e:'🤳'}]
    ]),
    'jobs': makeChallenge('jobs', 'Professions', '👨‍⚕️', [
        [{w:'Cook',e:'👨‍🍳'}, {w:'Book',e:'📚'}, {w:'Look',e:'👀'}],
        [{w:'Vet',e:'🩺'}, {w:'Pet',e:'🐶'}, {w:'Jet',e:'✈️'}],
        [{w:'Doc',e:'👨‍⚕️'}, {w:'Sock',e:'🧦'}, {w:'Lock',e:'🔒'}],
        [{w:'Cop',e:'👮'}, {w:'Top',e:'🔝'}, {w:'Mop',e:'🧹'}],
        [{w:'Guide',e:'🗺️'}, {w:'Ride',e:'🚲'}, {w:'Slide',e:'🛝'}]
    ]),
    'clothes': makeChallenge('clothes', 'Fashion', '👗', [
        [{w:'Hat',e:'👒'}, {w:'Cat',e:'🐱'}, {w:'Mat',e:'🧘'}],
        [{w:'Shoe',e:'👟'}, {w:'Blue',e:'🔵'}, {w:'Glue',e:'🧴'}],
        [{w:'Sock',e:'🧦'}, {w:'Lock',e:'🔒'}, {w:'Rock',e:'🪨'}],
        [{w:'Dress',e:'👗'}, {w:'Mess',e:'🗑️'}, {w:'Chess',e:'♟️'}],
        [{w:'Tie',e:'👔'}, {w:'Pie',e:'🥧'}, {w:'Fly',e:'🪰'}]
    ]),
    'body': makeChallenge('body', 'Body Parts', '💪', [
        [{w:'Eye',e:'👁️'}, {w:'Pie',e:'🥧'}, {w:'Sky',e:'☁️'}],
        [{w:'Nose',e:'👃'}, {w:'Rose',e:'🌹'}, {w:'Hose',e:'🚿'}],
        [{w:'Hand',e:'✋'}, {w:'Sand',e:'🏖️'}, {w:'Band',e:'🎸'}],
        [{w:'Ear',e:'👂'}, {w:'Gear',e:'⚙️'}, {w:'Deer',e:'🦌'}],
        [{w:'Knee',e:'🦵'}, {w:'Bee',e:'🐝'}, {w:'Key',e:'🔑'}]
    ])
};