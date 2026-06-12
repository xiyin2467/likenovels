enum Genre { werewolf, ceo, reborn, vampire, romantasy, modern }

enum BookStatus { ongoing, complete }

class Book {
  final String id;
  final String title;
  final String author;
  final Genre genre;
  final double rating;
  final String reads;
  final int chapters;
  final int? chaptersRead;
  final BookStatus status;
  final List<String> tropes;
  final String blurb;
  final String? badge;
  final int? rank;

  /// 非会员单章金币价格（会员全场畅读，不看章价）。
  final int chapterPrice;

  bool get isFree => chapterPrice == 0;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.rating,
    required this.reads,
    required this.chapters,
    this.chaptersRead,
    required this.status,
    required this.tropes,
    required this.blurb,
    this.badge,
    this.rank,
    this.chapterPrice = 38,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    Genre? genre,
    double? rating,
    String? reads,
    int? chapters,
    int? chaptersRead,
    BookStatus? status,
    List<String>? tropes,
    String? blurb,
    String? badge,
    int? rank,
    int? chapterPrice,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      reads: reads ?? this.reads,
      chapters: chapters ?? this.chapters,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      status: status ?? this.status,
      tropes: tropes ?? this.tropes,
      blurb: blurb ?? this.blurb,
      badge: badge ?? this.badge,
      rank: rank ?? this.rank,
      chapterPrice: chapterPrice ?? this.chapterPrice,
    );
  }
}

class Chapter {
  final int id;
  final String title;
  final bool free;
  final int coins;
  final int wordCount;

  const Chapter({
    required this.id,
    required this.title,
    required this.free,
    required this.coins,
    required this.wordCount,
  });
}

class RechargePackage {
  final String id;
  final int coins;
  final int bonus;
  final String bonusLabel;
  final String price;
  final String? tag;

  const RechargePackage({
    required this.id,
    required this.coins,
    required this.bonus,
    required this.bonusLabel,
    required this.price,
    this.tag,
  });
}

/// 会员订阅套餐：订阅是主付费产品，金币仅作为非会员按章出口。
class MembershipPlan {
  final String id;
  final String name;
  final String period;
  final String price;
  final String? originalPrice;
  final String? perMonthNote;
  final String? tag;
  final String? introOffer;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.period,
    required this.price,
    this.originalPrice,
    this.perMonthNote,
    this.tag,
    this.introOffer,
  });
}
