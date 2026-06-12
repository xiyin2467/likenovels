// ---------------------------------------------------------------------------
// 内存数据层 (in-memory store)
// 种子数据与前台 app/lib/core/mock/mock_data.dart 保持一致，便于管理后台演示
// 完整的 增删改查 闭环。进程重启后数据复位。
// ---------------------------------------------------------------------------

let _seq = 1000;
const nextId = (prefix) => `${prefix}_${++_seq}`;

// ── 题材 / 状态枚举 ────────────────────────────────────────────────────────
export const GENRES = ['werewolf', 'ceo', 'reborn', 'vampire', 'romantasy', 'modern'];
export const BOOK_STATUS = ['ongoing', 'complete'];

// ── 书籍种子 ────────────────────────────────────────────────────────────────
const seedBooks = [
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
    blurb:
      "She ran from him once. Now he's the Alpha of the largest pack on the eastern seaboard — and she's walked right back into his territory.",
    badge: 'hot',
    rank: 1,
    coinPrice: 40,
    freeChapters: 5,
  },
  {
    id: 'b2',
    title: "The Billionaire's Secret Wife",
    author: 'Mia Calloway',
    genre: 'ceo',
    rating: 4.7,
    reads: '6.5M',
    chapters: 188,
    status: 'complete',
    tropes: ['CEO & Billionaire', 'Contract marriage', 'Enemies to lovers'],
    blurb:
      'One contract. Six months. No feelings allowed. But when Daniel Whitmore looks at her like that, Maya knows she has already broken every rule.',
    badge: 'complete',
    rank: 2,
    coinPrice: 35,
    freeChapters: 5,
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
    blurb:
      "She died at 32, betrayed by everyone she loved. Reborn as her 19-year-old self, she's ready to change everything — except him.",
    badge: 'hot',
    rank: 3,
    coinPrice: 25,
    freeChapters: 5,
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
    blurb:
      'Three hundred years of solitude. Then she walked into his gallery, smelling of rain and old books — and everything changed.',
    badge: 'hot',
    rank: 4,
    coinPrice: 42,
    freeChapters: 5,
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
    blurb:
      'The princess who cannot die. The assassin sworn to kill her. What happens when the curse they both carry is the same one?',
    badge: 'hot',
    rank: null,
    coinPrice: 45,
    freeChapters: 5,
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
    blurb:
      "She swore she'd never race again. He's the infuriating new team owner who clearly doesn't know what the word \"no\" means.",
    badge: 'complete',
    rank: null,
    coinPrice: 28,
    freeChapters: 5,
  },
  {
    id: 'b7',
    title: "Alpha's Forbidden Kiss",
    author: 'Rena Wolfe',
    genre: 'werewolf',
    rating: 4.4,
    reads: '2.1M',
    chapters: 120,
    status: 'ongoing',
    tropes: ['Werewolf', 'Forbidden love'],
    blurb:
      "She's the pack healer. He's the Alpha who promised himself to another. Some bonds can't be broken — even the ones you fight against.",
    badge: null,
    rank: null,
    coinPrice: 30,
    freeChapters: 5,
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
    blurb:
      'He needed a wife for the board. She needed tuition money. A simple transaction — until their first kiss at the altar was not simple at all.',
    badge: null,
    rank: null,
    coinPrice: 50,
    freeChapters: 5,
  },
];

// ── 章节生成 (最多 30 章，免费章数 / 非会员单章价格由书籍配置决定) ──────────
function buildChapters(book) {
  const total = Math.min(book.chapters, 30);
  const isFreeBook = Number(book.coinPrice) === 0;
  const list = [];
  for (let i = 0; i < total; i++) {
    const title =
      i === 0
        ? 'A Fateful Encounter'
        : i === 1
          ? "The Alpha's Mark"
          : i === 2
            ? 'Shattered Illusions'
            : `Chapter ${i + 1}`;
    list.push({
      id: i + 1,
      bookId: book.id,
      title,
      free: isFreeBook || i < (book.freeChapters ?? 3),
      coins: isFreeBook ? 0 : book.coinPrice ?? 38,
      wordCount: 2200 + ((i * 137) % 800),
      published: true,
    });
  }
  return list;
}

// ── 按书籍配置同步章节的免费/金币状态 (修改书籍配置后调用) ────────────────
// 会员全场畅读；金币价格仅用于非会员按章购买。
export function syncChaptersPaywall(book, chapters) {
  const list = chapters || [];
  const isFreeBook = Number(book.coinPrice) === 0;
  list.forEach((c, i) => {
    c.free = isFreeBook || i < (book.freeChapters ?? 0);
    c.coins = isFreeBook ? 0 : book.coinPrice ?? 0;
  });
  return list;
}

// ── 充值套餐种子 ────────────────────────────────────────────────────────────
const seedPackages = [
  { id: 'p1', coins: 100, bonus: 100, bonusLabel: 'First top-up only', price: '$0.99', pricevalue: 0.99, googlePlayProductId: 'coins_100', tag: 'Double coins', active: true },
  { id: 'p2', coins: 500, bonus: 25, bonusLabel: '+25 bonus', price: '$4.99', pricevalue: 4.99, googlePlayProductId: 'coins_500', tag: null, active: true },
  { id: 'p3', coins: 1000, bonus: 80, bonusLabel: '+80 bonus', price: '$9.99', pricevalue: 9.99, googlePlayProductId: 'coins_1000', tag: 'Membership alternative', active: true },
  { id: 'p4', coins: 2000, bonus: 240, bonusLabel: '+240 bonus', price: '$19.99', pricevalue: 19.99, googlePlayProductId: 'coins_2000', tag: null, active: true },
];

// ── 会员套餐种子 ────────────────────────────────────────────────────────────
const seedPlans = [
  { id: 'm_weekly', name: 'Weekly', period: '/week', price: '$4.99', googlePlayProductId: 'vip_weekly', originalPrice: null, introOffer: null, tag: null, active: true },
  { id: 'm_monthly', name: 'Monthly', period: '/month', price: '$9.99', googlePlayProductId: 'vip_monthly', originalPrice: '$14.99', introOffer: '$5.99 first month', tag: 'Most popular', active: true },
  { id: 'm_yearly', name: 'Yearly', period: '/year', price: '$79.99', googlePlayProductId: 'vip_yearly', originalPrice: '$119.88', introOffer: null, tag: 'Best value', active: true },
];

// ── 用户种子 ────────────────────────────────────────────────────────────────
const FIRST = ['Ava', 'Mia', 'Luna', 'Zoe', 'Ivy', 'Nora', 'Ella', 'Ruby', 'Hazel', 'Sage', 'Cora', 'Wren'];
const LAST = ['Reader', 'Bennett', 'Hayes', 'Quinn', 'Rivera', 'Cole', 'Foster', 'Lane', 'Reid', 'Vale'];

function buildUsers() {
  const users = [];
  const now = Date.now();
  for (let i = 0; i < 24; i++) {
    const name = `${FIRST[i % FIRST.length]} ${LAST[i % LAST.length]}`;
    const isVip = i % 4 === 0;
    users.push({
      id: `user_${String(i + 1).padStart(3, '0')}`,
      name,
      email: `${name.toLowerCase().replace(/\s+/g, '.')}@likenovel.app`,
      coins: 80 + ((i * 53) % 1400),
      membership: isVip ? seedPlans[(i % 3)].id : null,
      status: i % 9 === 0 ? 'banned' : 'active',
      chaptersRead: (i * 31) % 420,
      createdAt: new Date(now - (i + 1) * 36e5 * 11).toISOString(),
      lastActive: new Date(now - (i % 7) * 36e5 * 6).toISOString(),
    });
  }
  return users;
}

// ── 订单 / 充值流水种子 ──────────────────────────────────────────────────────
function buildOrders(users) {
  const orders = [];
  const now = Date.now();
  const types = ['recharge', 'membership'];
  for (let i = 0; i < 40; i++) {
    const user = users[i % users.length];
    const type = types[i % 2];
    const pkg = seedPackages[i % seedPackages.length];
    const plan = seedPlans[i % seedPlans.length];
    const isRecharge = type === 'recharge';
    const amount = isRecharge ? pkg.pricevalue ?? pkg.priceValue ?? 0.99 : Number(plan.price.replace('$', ''));
    orders.push({
      id: nextId('ord'),
      userId: user.id,
      userName: user.name,
      type,
      itemId: isRecharge ? pkg.id : plan.id,
      itemLabel: isRecharge ? `${pkg.coins + pkg.bonus} coins` : `${plan.name} membership`,
      amount: Number(amount.toFixed(2)),
      coins: isRecharge ? pkg.coins + pkg.bonus : 0,
      status: i % 11 === 0 ? 'refunded' : i % 7 === 0 ? 'pending' : 'paid',
      channel: 'Google Play',
      createdAt: new Date(now - i * 36e5 * 3).toISOString(),
    });
  }
  return orders;
}

// ── 数据库实例 ──────────────────────────────────────────────────────────────
function createDb() {
  const books = seedBooks.map((b) => ({ ...b, tropes: [...b.tropes] }));
  const chapters = {};
  for (const b of books) chapters[b.id] = buildChapters(b);
  const packages = seedPackages.map((p) => ({ ...p }));
  const plans = seedPlans.map((p) => ({ ...p }));
  const users = buildUsers();
  const orders = buildOrders(users);
  return { books, chapters, packages, plans, users, orders };
}

export const db = createDb();
export { nextId };
