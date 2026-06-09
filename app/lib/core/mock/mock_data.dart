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
  final total = kBooks
      .cast<Book?>()
      .firstWhere((b) => b?.id == bookId, orElse: () => null)
      ?.chapters ?? 50;
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
      coins: 38,
      wordCount: 2200 + rng.nextInt(800),
    );
  });
}

const List<RechargePackage> kRechargePackages = [
  RechargePackage(
    id: 'p1',
    coins: 300,
    bonus: 0,
    bonusLabel: 'First-time price',
    price: r'$0.99',
    tag: 'Starter',
  ),
  RechargePackage(
    id: 'p2',
    coins: 600,
    bonus: 60,
    bonusLabel: '+60 bonus',
    price: r'$4.99',
  ),
  RechargePackage(
    id: 'p3',
    coins: 1400,
    bonus: 240,
    bonusLabel: '+240 bonus',
    price: r'$9.99',
    tag: 'Best value',
  ),
  RechargePackage(
    id: 'p4',
    coins: 3200,
    bonus: 720,
    bonusLabel: '+720 bonus',
    price: r'$19.99',
  ),
];

/// 会员权益（VIP）通用列表。
const List<String> kMembershipPerks = [
  'Unlock VIP-tagged stories for free',
  'Ad-free reading experience',
  'Daily bonus coins, auto-credited',
  'Early access to new chapters',
  'Exclusive member badge',
];

/// 会员订阅套餐：与金币充值并行的第二套变现体系。
const List<MembershipPlan> kMembershipPlans = [
  MembershipPlan(
    id: 'm_weekly',
    name: 'Weekly',
    period: '/week',
    price: r'$2.99',
    dailyCoins: 30,
  ),
  MembershipPlan(
    id: 'm_monthly',
    name: 'Monthly',
    period: '/month',
    price: r'$9.99',
    originalPrice: r'$12.99',
    perMonthNote: 'Billed monthly',
    tag: 'Most popular',
    dailyCoins: 50,
  ),
  MembershipPlan(
    id: 'm_yearly',
    name: 'Yearly',
    period: '/year',
    price: r'$79.99',
    originalPrice: r'$119.88',
    perMonthNote: r'Just $6.67 / month',
    tag: 'Best value',
    dailyCoins: 80,
  ),
];

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
