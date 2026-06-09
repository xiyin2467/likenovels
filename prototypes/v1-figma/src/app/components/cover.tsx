import { Flame, Check } from './icons';
import type { Genre } from '../data';

/* ─── Genre visual palettes ─────────────────────────────── */
const GENRE_STYLES: Record<Genre, {
  bg: string; text: string; accent: string; pattern: string;
  overlay: string; shimmer: string;
}> = {
  werewolf: {
    bg: 'linear-gradient(160deg, #0c1425 0%, #1b2d50 45%, #08111e 100%)',
    text: '#e8d5c4', accent: '#7eb8e8',
    pattern: '🌙',
    overlay: 'rgba(30,60,120,0.25)',
    shimmer: '#3b6fa8',
  },
  ceo: {
    bg: 'linear-gradient(160deg, #141414 0%, #282828 50%, #0c0c0c 100%)',
    text: '#f5e6c8', accent: '#d4af37',
    pattern: '◆',
    overlay: 'rgba(212,175,55,0.08)',
    shimmer: '#d4af37',
  },
  reborn: {
    bg: 'linear-gradient(160deg, oklch(0.32 0.14 16) 0%, oklch(0.46 0.17 18) 55%, oklch(0.25 0.12 15) 100%)',
    text: '#fce8e4', accent: '#f8c4b8',
    pattern: '✦',
    overlay: 'rgba(220,60,40,0.12)',
    shimmer: '#d9705c',
  },
  vampire: {
    bg: 'linear-gradient(160deg, #07000a 0%, #160010 55%, #030006 100%)',
    text: '#e8c4cc', accent: '#c0224a',
    pattern: '✧',
    overlay: 'rgba(150,0,50,0.2)',
    shimmer: '#901838',
  },
  romantasy: {
    bg: 'linear-gradient(160deg, #170826 0%, #2b1252 50%, #0f0518 100%)',
    text: '#e8d0f8', accent: '#b388e8',
    pattern: '⋆',
    overlay: 'rgba(120,40,220,0.12)',
    shimmer: '#8b5cf6',
  },
  modern: {
    bg: 'linear-gradient(160deg, #250c15 0%, #3c1525 50%, #180810 100%)',
    text: '#fce4ec', accent: '#f48fb1',
    pattern: '♡',
    overlay: 'rgba(200,60,100,0.12)',
    shimmer: '#e06090',
  },
};

/* ─── Shared inner content ───────────────────────────────── */
function CoverInner({
  genre, title, author, badge, rank, patternSize, titleSize, authorSize, badgeSize,
}: {
  genre: Genre; title: string; author: string;
  badge?: 'hot' | 'complete'; rank?: number;
  patternSize: string; titleSize: string; authorSize: string; badgeSize: 'sm' | 'md';
}) {
  const s = GENRE_STYLES[genre];
  const bs = badgeSize === 'sm';
  return (
    <>
      {/* corner glow */}
      <div
        className="absolute -top-4 -right-4 rounded-full pointer-events-none"
        style={{ width: '60%', height: '60%', background: `radial-gradient(circle, ${s.shimmer}22 0%, transparent 70%)` }}
      />
      {/* pattern */}
      <div className="absolute inset-0 flex items-center justify-center opacity-[0.09] pointer-events-none select-none" aria-hidden>
        <span style={{ fontSize: patternSize, color: s.accent }}>{s.pattern}</span>
      </div>
      {/* subtle texture lines */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{ backgroundImage: `repeating-linear-gradient(0deg, ${s.accent}08 0px, transparent 1px, transparent 18px)` }}
      />
      {/* bottom gradient + text */}
      <div
        className="absolute inset-0 flex flex-col justify-end"
        style={{ padding: bs ? '6px' : '10px', background: 'linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 55%)' }}
      >
        <p className={`font-semibold leading-tight mb-0.5 ${titleSize}`} style={{ color: s.text, fontFamily: 'Newsreader, serif' }}>
          {title}
        </p>
        <p className={`${authorSize} opacity-65`} style={{ color: s.text, fontFamily: 'Inter, sans-serif' }}>
          {author}
        </p>
      </div>
      {/* badge */}
      {badge === 'hot' && (
        <div
          className={`absolute top-1.5 left-1.5 flex items-center gap-0.5 rounded-full font-semibold ${bs ? 'px-1.5 py-0.5 text-[7px]' : 'px-2 py-0.5 text-[9px]'}`}
          style={{ background: 'oklch(0.52 0.158 16)', color: 'oklch(0.99 0.01 80)' }}
        >
          <Flame className={bs ? 'w-2 h-2' : 'w-3 h-3'} />Hot
        </div>
      )}
      {badge === 'complete' && (
        <div
          className={`absolute top-1.5 left-1.5 flex items-center gap-0.5 rounded-full font-semibold ${bs ? 'px-1.5 py-0.5 text-[7px]' : 'px-2 py-0.5 text-[9px]'}`}
          style={{ background: 'oklch(0.50 0.12 150)', color: 'white' }}
        >
          <Check className={bs ? 'w-2 h-2' : 'w-3 h-3'} />Done
        </div>
      )}
      {/* rank bubble */}
      {rank != null && (
        <div
          className="absolute top-1.5 right-1.5 rounded-full flex items-center justify-center font-bold"
          style={{
            width: bs ? '20px' : '26px',
            height: bs ? '20px' : '26px',
            fontSize: bs ? '9px' : '11px',
            background: rank === 1 ? 'oklch(0.78 0.115 78)' : 'rgba(255,255,255,0.18)',
            color: rank === 1 ? '#1a1200' : s.text,
            backdropFilter: 'blur(4px)',
          }}
        >
          {rank}
        </div>
      )}
    </>
  );
}

/* ─── Fixed-size cover ───────────────────────────────────── */
export type CoverSize = 'sm' | 'md' | 'lg' | 'xl';

const SIZE_MAP: Record<CoverSize, { w: string; h: string; pattern: string; title: string; author: string }> = {
  sm: { w: '80px', h: '112px', pattern: '40px', title: 'text-[9px]', author: 'text-[7px]' },
  md: { w: '108px', h: '152px', pattern: '52px', title: 'text-[10px]', author: 'text-[8px]' },
  lg: { w: '140px', h: '196px', pattern: '68px', title: 'text-xs', author: 'text-[9px]' },
  xl: { w: '160px', h: '224px', pattern: '80px', title: 'text-sm', author: 'text-[10px]' },
};

interface CoverProps {
  genre: Genre; title: string; author: string;
  badge?: 'hot' | 'complete'; rank?: number;
  size?: CoverSize; className?: string;
}

export function Cover({ genre, title, author, badge, rank, size = 'md', className = '' }: CoverProps) {
  const s = GENRE_STYLES[genre];
  const m = SIZE_MAP[size];
  return (
    <div
      className={`relative rounded-[13px] overflow-hidden flex-shrink-0 select-none ${className}`}
      style={{ width: m.w, height: m.h, background: s.bg }}
    >
      <CoverInner
        genre={genre} title={title} author={author} badge={badge} rank={rank}
        patternSize={m.pattern} titleSize={m.title} authorSize={m.author}
        badgeSize={size === 'sm' ? 'sm' : 'md'}
      />
    </div>
  );
}

/* ─── Fluid cover (fills parent width, 5:7 aspect ratio) ── */
interface FluidCoverProps {
  genre: Genre; title: string; author: string;
  badge?: 'hot' | 'complete'; rank?: number; className?: string;
}

export function FluidCover({ genre, title, author, badge, rank, className = '' }: FluidCoverProps) {
  const s = GENRE_STYLES[genre];
  return (
    <div
      className={`relative rounded-[13px] overflow-hidden w-full select-none ${className}`}
      style={{ background: s.bg, aspectRatio: '5 / 7' }}
    >
      <CoverInner
        genre={genre} title={title} author={author} badge={badge} rank={rank}
        patternSize="60%" titleSize="text-xs" authorSize="text-[9px]"
        badgeSize="md"
      />
    </div>
  );
}

/* ─── Hero cover (large, for Book Detail) ────────────────── */
export function HeroCover({ genre, title, author, badge }: {
  genre: Genre; title: string; author: string; badge?: 'hot' | 'complete';
}) {
  const s = GENRE_STYLES[genre];
  return (
    <div
      className="w-[148px] h-[210px] rounded-[18px] overflow-hidden flex-shrink-0 relative"
      style={{ background: s.bg, boxShadow: `0 16px 40px ${s.shimmer}44` }}
    >
      <CoverInner
        genre={genre} title={title} author={author} badge={badge}
        patternSize="90px" titleSize="text-sm" authorSize="text-[10px]"
        badgeSize="md"
      />
    </div>
  );
}
