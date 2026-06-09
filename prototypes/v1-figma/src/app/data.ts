export type Genre = 'werewolf' | 'ceo' | 'reborn' | 'vampire' | 'romantasy' | 'modern';
export type BookStatus = 'ongoing' | 'complete';

export interface Book {
  id: string;
  title: string;
  author: string;
  genre: Genre;
  rating: number;
  reads: string;
  chapters: number;
  chaptersRead?: number;
  status: BookStatus;
  tropes: string[];
  blurb: string;
  badge?: 'hot' | 'complete';
  rank?: number;
}

export interface Chapter {
  id: number;
  title: string;
  free: boolean;
  coins: number;
  wordCount: number;
}

export const BOOKS: Book[] = [
  {
    id: 'b1',
    title: 'Claimed by the Moon',
    author: 'L.K. Ashford',
    genre: 'werewolf',
    rating: 4.8,
    reads: '8.2M',
    chapters: 142,
    status: 'ongoing',
    tropes: ['Fated mates', 'Werewolf', 'Second chance'],
    blurb: 'She ran from him once. Now he\'s the Alpha of the largest pack on the eastern seaboard — and she\'s walked right back into his territory.',
    badge: 'hot',
    rank: 1,
  },
  {
    id: 'b2',
    title: 'The Billionaire\'s Secret Wife',
    author: 'Mia Calloway',
    genre: 'ceo',
    rating: 4.7,
    reads: '6.5M',
    chapters: 188,
    status: 'complete',
    tropes: ['CEO & Billionaire', 'Contract marriage', 'Enemies to lovers'],
    blurb: 'One contract. Six months. No feelings allowed. But when Daniel Whitmore looks at her like that, Maya knows she\'s already broken every rule.',
    badge: 'complete',
    rank: 2,
  },
  {
    id: 'b3',
    title: 'My Second Life, Your First Love',
    author: 'Jade Lin',
    genre: 'reborn',
    rating: 4.6,
    reads: '4.1M',
    chapters: 210,
    status: 'ongoing',
    tropes: ['Reborn', 'Second chance', 'Forbidden love'],
    blurb: 'She died at 32, betrayed by everyone she loved. Reborn as her 19-year-old self, she\'s ready to change everything — except him.',
    badge: 'hot',
    rank: 3,
  },
  {
    id: 'b4',
    title: 'His Crimson Vow',
    author: 'Selene Voss',
    genre: 'vampire',
    rating: 4.9,
    reads: '3.8M',
    chapters: 96,
    status: 'complete',
    tropes: ['Vampire', 'Forbidden love', 'Fated mates'],
    blurb: 'Three hundred years of solitude. Then she walked into his gallery, smelling of rain and old books — and everything changed.',
    badge: 'hot',
    rank: 4,
  },
  {
    id: 'b5',
    title: 'Crown of Thorns and Roses',
    author: 'Evara Night',
    genre: 'romantasy',
    rating: 4.7,
    reads: '5.3M',
    chapters: 165,
    status: 'ongoing',
    tropes: ['Romantasy', 'Enemies to lovers', 'Fated mates'],
    blurb: 'The princess who cannot die. The assassin sworn to kill her. What happens when the curse they both carry is the same one?',
    badge: 'hot',
  },
  {
    id: 'b6',
    title: 'Love in the Fast Lane',
    author: 'Cara Monroe',
    genre: 'modern',
    rating: 4.5,
    reads: '2.9M',
    chapters: 78,
    status: 'complete',
    tropes: ['Second chance', 'Enemies to lovers'],
    blurb: 'She swore she\'d never race again. He\'s the infuriating new team owner who clearly doesn\'t know what the word "no" means.',
    badge: 'complete',
  },
  {
    id: 'b7',
    title: 'Alpha\'s Forbidden Kiss',
    author: 'Rena Wolfe',
    genre: 'werewolf',
    rating: 4.4,
    reads: '2.1M',
    chapters: 120,
    status: 'ongoing',
    tropes: ['Werewolf', 'Forbidden love'],
    blurb: 'She\'s the pack healer. He\'s the Alpha who promised himself to another. Some bonds can\'t be broken — even the ones you fight against.',
  },
  {
    id: 'b8',
    title: 'Billion-Dollar Bride',
    author: 'Sofía Reyes',
    genre: 'ceo',
    rating: 4.6,
    reads: '3.4M',
    chapters: 155,
    status: 'ongoing',
    tropes: ['CEO & Billionaire', 'Contract marriage'],
    blurb: 'He needed a wife for the board. She needed tuition money. A simple transaction — until their first kiss at the altar wasn\'t simple at all.',
  },
];

export const LIBRARY_BOOKS: (Book & { progress: number; currentChapter: number })[] = [
  { ...BOOKS[0], chaptersRead: 47, progress: 33, currentChapter: 47 },
  { ...BOOKS[1], chaptersRead: 12, progress: 6, currentChapter: 12 },
  { ...BOOKS[3], chaptersRead: 96, progress: 100, currentChapter: 96 },
];

export function getChapters(bookId: string): Chapter[] {
  const total = BOOKS.find(b => b.id === bookId)?.chapters ?? 50;
  return Array.from({ length: Math.min(total, 30) }, (_, i) => ({
    id: i + 1,
    title: i === 0 ? 'A Fateful Encounter' :
      i === 1 ? 'The Alpha\'s Mark' :
      i === 2 ? 'Shattered Illusions' :
      `Chapter ${i + 1}`,
    free: i < 3,
    coins: 38,
    wordCount: 2200 + Math.floor(Math.random() * 800),
  }));
}

export const RECHARGE_PACKAGES = [
  { id: 'p1', coins: 300, bonus: 0, bonusLabel: 'First-time price', price: '$0.99', tag: 'Starter' },
  { id: 'p2', coins: 600, bonus: 60, bonusLabel: '+60 bonus', price: '$4.99', tag: null },
  { id: 'p3', coins: 1400, bonus: 240, bonusLabel: '+240 bonus', price: '$9.99', tag: 'Best value' },
  { id: 'p4', coins: 3200, bonus: 720, bonusLabel: '+720 bonus', price: '$19.99', tag: null },
];

export const TASTE_TAGS = [
  'Werewolf', 'CEO & Billionaire', 'Reborn', 'Vampire',
  'Romantasy', 'Fated mates', 'Contract marriage', 'Second chance',
  'Enemies to lovers', 'Forbidden love',
];

export const GENRE_TABS = ['For you', 'Werewolf', 'CEO', 'Reborn', 'Vampire', 'Romantasy'];

export const CHAPTER_SAMPLE_TEXT = `The night smelled of pine and something older — something that made the hair on the back of Lena's neck stand on end.

She pressed herself against the truck door and tried to remember how to breathe. The forest on either side of the mountain road had gone unnaturally still, the way forests only went still when something apex was near.

Her phone had no signal. Of course it didn't.

The crunch of footsteps on gravel made her spin around. And there he was — tall, broad-shouldered, wearing nothing but jeans despite the December cold, his dark eyes catching the moonlight in a way that made her think of wolves and old stories and every reason she'd been told never to come back to Ashford County.

"You're on my land," he said.

His voice was exactly as she remembered. Low. Deliberate. Like a promise that could go either way.

"Caleb." She hated that her voice came out steady. She'd worked so hard for that steadiness over six years of running.

He looked at her the way a man looks at something he's been waiting for. Not surprised — never surprised, even when he should have been.

"Hello, Lena."

Three words. Six years dissolved like smoke.

She thought about her car keys. She thought about the 400 miles between here and the life she'd built. She thought about all the excellent, reasonable decisions she'd made since the night she'd left.

Then he smiled, just barely, and she stopped thinking about any of those things.`;
