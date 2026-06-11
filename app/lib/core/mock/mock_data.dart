import 'dart:math';

import 'package:likenovel/core/models/book.dart';

const List<Book> kBooks = [
  Book(
    id: 'b1',
    title: 'Claimed by the Moon',
    author: 'L.K. Ashford',
    genre: Genre.werewolf,
    rating: 4.8,
    reads: '8.2M',
    chapters: 142,
    status: BookStatus.ongoing,
    tropes: ['Fated mates', 'Werewolf', 'Second chance'],
    blurb:
        "She ran from him once. Now he's the Alpha of the largest pack on the "
        "eastern seaboard — and she's walked right back into his territory.",
    badge: 'hot',
    rank: 1,
    chapterPrice: 40,
  ),
  Book(
    id: 'b2',
    title: "The Billionaire's Secret Wife",
    author: 'Mia Calloway',
    genre: Genre.ceo,
    rating: 4.7,
    reads: '6.5M',
    chapters: 188,
    status: BookStatus.complete,
    tropes: ['CEO & Billionaire', 'Contract marriage', 'Enemies to lovers'],
    blurb:
        'One contract. Six months. No feelings allowed. But when Daniel '
        "Whitmore looks at her like that, Maya knows she's already broken "
        'every rule.',
    badge: 'complete',
    rank: 2,
    chapterPrice: 35,
  ),
  Book(
    id: 'b3',
    title: 'My Second Life, Your First Love',
    author: 'Jade Lin',
    genre: Genre.reborn,
    rating: 4.6,
    reads: '4.1M',
    chapters: 210,
    status: BookStatus.ongoing,
    tropes: ['Reborn', 'Second chance', 'Forbidden love'],
    blurb:
        'She died at 32, betrayed by everyone she loved. Reborn as her '
        "19-year-old self, she's ready to change everything — except him.",
    badge: 'hot',
    rank: 3,
    chapterPrice: 25,
  ),
  Book(
    id: 'b4',
    title: 'His Crimson Vow',
    author: 'Selene Voss',
    genre: Genre.vampire,
    rating: 4.9,
    reads: '3.8M',
    chapters: 96,
    status: BookStatus.complete,
    tropes: ['Vampire', 'Forbidden love', 'Fated mates'],
    blurb:
        'Three hundred years of solitude. Then she walked into his gallery, '
        'smelling of rain and old books — and everything changed.',
    badge: 'hot',
    rank: 4,
    chapterPrice: 42,
  ),
  Book(
    id: 'b5',
    title: 'Crown of Thorns and Roses',
    author: 'Evara Night',
    genre: Genre.romantasy,
    rating: 4.7,
    reads: '5.3M',
    chapters: 165,
    status: BookStatus.ongoing,
    tropes: ['Romantasy', 'Enemies to lovers', 'Fated mates'],
    blurb:
        'The princess who cannot die. The assassin sworn to kill her. What '
        'happens when the curse they both carry is the same one?',
    badge: 'hot',
    chapterPrice: 45,
  ),
  Book(
    id: 'b6',
    title: 'Love in the Fast Lane',
    author: 'Cara Monroe',
    genre: Genre.modern,
    rating: 4.5,
    reads: '2.9M',
    chapters: 78,
    status: BookStatus.complete,
    tropes: ['Second chance', 'Enemies to lovers'],
    blurb:
        "She swore she'd never race again. He's the infuriating new team "
        "owner who clearly doesn't know what the word \"no\" means.",
    badge: 'complete',
    chapterPrice: 28,
  ),
  Book(
    id: 'b7',
    title: "Alpha's Forbidden Kiss",
    author: 'Rena Wolfe',
    genre: Genre.werewolf,
    rating: 4.4,
    reads: '2.1M',
    chapters: 120,
    status: BookStatus.ongoing,
    tropes: ['Werewolf', 'Forbidden love'],
    blurb:
        "She's the pack healer. He's the Alpha who promised himself to "
        "another. Some bonds can't be broken — even the ones you fight "
        'against.',
    chapterPrice: 30,
  ),
  Book(
    id: 'b8',
    title: 'Billion-Dollar Bride',
    author: 'Sofía Reyes',
    genre: Genre.ceo,
    rating: 4.6,
    reads: '3.4M',
    chapters: 155,
    status: BookStatus.ongoing,
    tropes: ['CEO & Billionaire', 'Contract marriage'],
    blurb:
        'He needed a wife for the board. She needed tuition money. A simple '
        "transaction — until their first kiss at the altar wasn't simple "
        'at all.',
    chapterPrice: 50,
  ),
];

class LibraryBook {
  final Book book;
  final double progress;
  final int currentChapter;

  const LibraryBook({
    required this.book,
    required this.progress,
    required this.currentChapter,
  });
}

final List<LibraryBook> kLibraryBooks = [
  LibraryBook(
    book: kBooks[0].copyWith(chaptersRead: 47),
    progress: 33,
    currentChapter: 47,
  ),
  LibraryBook(
    book: kBooks[1].copyWith(chaptersRead: 12),
    progress: 6,
    currentChapter: 12,
  ),
  LibraryBook(
    book: kBooks[3].copyWith(chaptersRead: 96),
    progress: 100,
    currentChapter: 96,
  ),
];

List<Chapter> getChapters(String bookId) {
  final book =
      kBooks.cast<Book?>().firstWhere((b) => b?.id == bookId, orElse: () => null);
  final total = book?.chapters ?? 50;
  // 章价随书走；会员全场畅读时不使用章价。
  final price = book?.chapterPrice ?? 38;
  final rng = Random(bookId.hashCode);

  return List.generate(min(total, 30), (i) {
    final title = switch (i) {
      0 => 'A Fateful Encounter',
      1 => "The Alpha's Mark",
      2 => 'Shattered Illusions',
      _ => 'Chapter ${i + 1}',
    };
    return Chapter(
      id: i + 1,
      title: title,
      free: i < 3,
      coins: price,
      wordCount: 2200 + rng.nextInt(800),
    );
  });
}

const List<RechargePackage> kRechargePackages = [
  RechargePackage(
    id: 'p1',
    coins: 100,
    bonus: 100,
    bonusLabel: 'First top-up only',
    price: r'$0.99',
    tag: 'Double coins',
  ),
  RechargePackage(
    id: 'p2',
    coins: 500,
    bonus: 25,
    bonusLabel: '+25 bonus',
    price: r'$4.99',
  ),
  RechargePackage(
    id: 'p3',
    coins: 1000,
    bonus: 80,
    bonusLabel: '+80 bonus',
    price: r'$9.99',
    tag: 'Membership alternative',
  ),
  RechargePackage(
    id: 'p4',
    coins: 2000,
    bonus: 240,
    bonusLabel: '+240 bonus',
    price: r'$19.99',
  ),
];

/// 会员权益：全场畅读是主承诺，不再按 VIP 标签书分流。
const List<String> kMembershipPerks = [
  'Read everything. No limits.',
  'Ad-free reading experience',
  'Download full books offline',
  'Exclusive member badge',
];

/// 会员订阅套餐：订阅优先，金币仅为非会员按章出口。
const List<MembershipPlan> kMembershipPlans = [
  MembershipPlan(
    id: 'm_weekly',
    name: 'Weekly',
    period: '/week',
    price: r'$4.99',
  ),
  MembershipPlan(
    id: 'm_monthly',
    name: 'Monthly',
    period: '/month',
    price: r'$9.99',
    originalPrice: r'$14.99',
    perMonthNote: r'First month $5.99',
    tag: 'Most popular',
    introOffer: r'$5.99 first month',
  ),
  MembershipPlan(
    id: 'm_yearly',
    name: 'Yearly',
    period: '/year',
    price: r'$79.99',
    originalPrice: r'$119.88',
    perMonthNote: r'Just $6.67 / month',
    tag: 'Best value',
  ),
];

/// 题材 → 偏好标签（与 [kTasteTags] 对齐），用于把书籍题材并入偏好打分。
const Map<Genre, String> kGenreTasteTag = {
  Genre.werewolf: 'Werewolf',
  Genre.ceo: 'CEO & Billionaire',
  Genre.reborn: 'Reborn',
  Genre.vampire: 'Vampire',
  Genre.romantasy: 'Romantasy',
  Genre.modern: 'Second chance',
};

/// 按用户偏好给单本书打分：命中题材或标签越多分越高。
int preferenceScore(Book book, Set<String> prefs) {
  if (prefs.isEmpty) return 0;
  var score = 0;
  if (prefs.contains(kGenreTasteTag[book.genre])) score += 2;
  for (final t in book.tropes) {
    if (prefs.contains(t)) score += 1;
  }
  return score;
}

/// 依据偏好对书单做稳定排序（高分在前，未命中保持原序）。
List<Book> sortByPreference(List<Book> books, Set<String> prefs) {
  if (prefs.isEmpty) return books;
  final indexed = books.asMap().entries.toList();
  indexed.sort((a, b) {
    final sa = preferenceScore(a.value, prefs);
    final sb = preferenceScore(b.value, prefs);
    if (sa != sb) return sb.compareTo(sa);
    return a.key.compareTo(b.key); // 稳定：同分保持原顺序
  });
  return indexed.map((e) => e.value).toList();
}

const List<String> kTasteTags = [
  'Werewolf',
  'CEO & Billionaire',
  'Reborn',
  'Vampire',
  'Romantasy',
  'Fated mates',
  'Contract marriage',
  'Second chance',
  'Enemies to lovers',
  'Forbidden love',
];

const List<String> kGenreTabs = [
  'Werewolf',
  'CEO',
  'Reborn',
  'Vampire',
  'Romantasy',
];

/// 与 [kGenreTabs] 一一对应的题材枚举，用于按分类筛选发现页内容。
const List<Genre> kGenreTabValues = [
  Genre.werewolf,
  Genre.ceo,
  Genre.reborn,
  Genre.vampire,
  Genre.romantasy,
];

const String kChapterSampleText =
    "The night smelled of pine and something older — something that made the "
    "hair on the back of Lena's neck stand on end.\n\n"
    "She pressed herself against the truck door and tried to remember how to "
    "breathe. The forest on either side of the mountain road had gone "
    "unnaturally still, the way forests only went still when something apex "
    "was near.\n\n"
    "Her phone had no signal. Of course it didn't.\n\n"
    "The crunch of footsteps on gravel made her spin around. And there he "
    "was — tall, broad-shouldered, wearing nothing but jeans despite the "
    "December cold, his dark eyes catching the moonlight in a way that made "
    "her think of wolves and old stories and every reason she'd been told "
    "never to come back to Ashford County.\n\n"
    '"You\'re on my land," he said.\n\n'
    "His voice was exactly as she remembered. Low. Deliberate. Like a "
    "promise that could go either way.\n\n"
    '"Caleb." She hated that her voice came out steady. She\'d worked so '
    "hard for that steadiness over six years of running.\n\n"
    "He looked at her the way a man looks at something he's been waiting "
    "for. Not surprised — never surprised, even when he should have been.\n\n"
    '"Hello, Lena."\n\n'
    "Three words. Six years dissolved like smoke.\n\n"
    "She thought about her car keys. She thought about the 400 miles "
    "between here and the life she'd built. She thought about all the "
    "excellent, reasonable decisions she'd made since the night she'd "
    "left.\n\n"
    "Then he smiled, just barely, and she stopped thinking about any of "
    "those things.";
