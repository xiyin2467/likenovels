import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

import 'package:likenovel/app/theme.dart';
import 'package:likenovel/core/models/book.dart';

class _GenrePalette {
  final List<Color> gradient;
  final Color text;
  final Color accent;
  final String pattern;
  final Color shimmer;

  const _GenrePalette({
    required this.gradient,
    required this.text,
    required this.accent,
    required this.pattern,
    required this.shimmer,
  });
}

const _palettes = <Genre, _GenrePalette>{
  Genre.werewolf: _GenrePalette(
    gradient: [Color(0xFF0C1425), Color(0xFF1B2D50), Color(0xFF08111E)],
    text: Color(0xFFE8D5C4),
    accent: Color(0xFF7EB8E8),
    pattern: '🌙',
    shimmer: Color(0xFF3B6FA8),
  ),
  Genre.ceo: _GenrePalette(
    gradient: [Color(0xFF141414), Color(0xFF282828), Color(0xFF0C0C0C)],
    text: Color(0xFFF5E6C8),
    accent: Color(0xFFD4AF37),
    pattern: '◆',
    shimmer: Color(0xFFD4AF37),
  ),
  Genre.reborn: _GenrePalette(
    gradient: [Color(0xFF5C1A18), Color(0xFFA83232), Color(0xFF421210)],
    text: Color(0xFFFCE8E4),
    accent: Color(0xFFF8C4B8),
    pattern: '✦',
    shimmer: Color(0xFFD9705C),
  ),
  Genre.vampire: _GenrePalette(
    gradient: [Color(0xFF07000A), Color(0xFF160010), Color(0xFF030006)],
    text: Color(0xFFE8C4CC),
    accent: Color(0xFFC0224A),
    pattern: '✧',
    shimmer: Color(0xFF901838),
  ),
  Genre.romantasy: _GenrePalette(
    gradient: [Color(0xFF170826), Color(0xFF2B1252), Color(0xFF0F0518)],
    text: Color(0xFFE8D0F8),
    accent: Color(0xFFB388E8),
    pattern: '⋆',
    shimmer: Color(0xFF8B5CF6),
  ),
  Genre.modern: _GenrePalette(
    gradient: [Color(0xFF250C15), Color(0xFF3C1525), Color(0xFF180810)],
    text: Color(0xFFFCE4EC),
    accent: Color(0xFFF48FB1),
    pattern: '♡',
    shimmer: Color(0xFFE06090),
  ),
};

enum CoverSize { sm, md, lg, xl }

const _sizeMap = <CoverSize, (double w, double h, double patternFz, double titleFz, double authorFz)>{
  CoverSize.sm: (80, 112, 40, 9, 7),
  CoverSize.md: (108, 152, 52, 10, 8),
  CoverSize.lg: (140, 196, 68, 12, 9),
  CoverSize.xl: (160, 224, 80, 14, 10),
};

class BookCover extends StatelessWidget {
  final Genre genre;
  final String title;
  final String author;
  final String? badge;
  final int? rank;
  final CoverSize size;

  const BookCover({
    super.key,
    required this.genre,
    required this.title,
    required this.author,
    this.badge,
    this.rank,
    this.size = CoverSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final dim = _sizeMap[size]!;
    return SizedBox(
      width: dim.$1,
      height: dim.$2,
      child: _CoverBody(
        genre: genre,
        title: title,
        author: author,
        badge: badge,
        rank: rank,
        patternFontSize: dim.$3,
        titleFontSize: dim.$4,
        authorFontSize: dim.$5,
        isSmall: size == CoverSize.sm,
        borderRadius: ElRadius.controlR,
      ),
    );
  }
}

class FluidCover extends StatelessWidget {
  final Genre genre;
  final String title;
  final String author;
  final String? badge;
  final int? rank;

  const FluidCover({
    super.key,
    required this.genre,
    required this.title,
    required this.author,
    this.badge,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 7,
      child: _CoverBody(
        genre: genre,
        title: title,
        author: author,
        badge: badge,
        rank: rank,
        patternFontSize: 60,
        titleFontSize: 12,
        authorFontSize: 9,
        isSmall: false,
        borderRadius: ElRadius.controlR,
      ),
    );
  }
}

class HeroCover extends StatelessWidget {
  final Genre genre;
  final String title;
  final String author;
  final String? badge;

  const HeroCover({
    super.key,
    required this.genre,
    required this.title,
    required this.author,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[genre]!;
    return Container(
      width: 148,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: ElRadius.cardR,
        boxShadow: [
          BoxShadow(
            color: palette.shimmer.withValues(alpha: 0.27),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: _CoverBody(
        genre: genre,
        title: title,
        author: author,
        badge: badge,
        patternFontSize: 90,
        titleFontSize: 14,
        authorFontSize: 10,
        isSmall: false,
        borderRadius: ElRadius.cardR,
      ),
    );
  }
}

class _CoverBody extends StatelessWidget {
  final Genre genre;
  final String title;
  final String author;
  final String? badge;
  final int? rank;
  final double patternFontSize;
  final double titleFontSize;
  final double authorFontSize;
  final bool isSmall;
  final BorderRadius borderRadius;

  const _CoverBody({
    required this.genre,
    required this.title,
    required this.author,
    this.badge,
    this.rank,
    required this.patternFontSize,
    required this.titleFontSize,
    required this.authorFontSize,
    required this.isSmall,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[genre]!;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.6, -1),
            end: const Alignment(0.6, 1),
            colors: palette.gradient,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Corner glow
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.shimmer.withValues(alpha: 0.13),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Center pattern symbol
            Center(
              child: Text(
                palette.pattern,
                style: TextStyle(
                  fontSize: patternFontSize,
                  color: palette.accent.withValues(alpha: 0.09),
                ),
              ),
            ),

            // Horizontal texture lines
            Positioned.fill(
              child: CustomPaint(
                painter: _TextureLinesPainter(
                  color: palette.accent.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Bottom gradient overlay + text
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(isSmall ? 6 : 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xB8000000),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.newsreader(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.inter(
                        fontSize: authorFontSize,
                        color: palette.text.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Badge chip (top-left)
            if (badge == 'hot')
              Positioned(
                top: 6,
                left: 6,
                child: _BadgeChip(
                  label: 'Hot',
                  icon: Icons.local_fire_department_rounded,
                  color: ElColors.primary,
                  textColor: ElColors.onPrimary,
                  isSmall: isSmall,
                ),
              ),
            if (badge == 'complete')
              Positioned(
                top: 6,
                left: 6,
                child: _BadgeChip(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  color: ElColors.success,
                  textColor: Colors.white,
                  isSmall: isSmall,
                ),
              ),

            // Rank circle (top-right)
            if (rank != null)
              Positioned(
                top: 6,
                right: 6,
                child: _RankCircle(
                  rank: rank!,
                  palette: palette,
                  isSmall: isSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isSmall;

  const _BadgeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final sz = isSmall ? 7.0 : 9.0;
    final iconSz = isSmall ? 8.0 : 12.0;
    final px = isSmall ? 4.0 : 6.0;
    final py = isSmall ? 2.0 : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSz, color: textColor),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppFont.inter(
              fontSize: sz,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCircle extends StatelessWidget {
  final int rank;
  final _GenrePalette palette;
  final bool isSmall;

  const _RankCircle({
    required this.rank,
    required this.palette,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = isSmall ? 20.0 : 26.0;
    final fontSize = isSmall ? 9.0 : 11.0;
    final isFirst = rank == 1;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFirst ? ElColors.gold : Colors.white.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppFont.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: isFirst ? const Color(0xFF1A1200) : palette.text,
        ),
      ),
    );
  }
}

class _TextureLinesPainter extends CustomPainter {
  final Color color;

  const _TextureLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TextureLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}
