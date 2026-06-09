import * as React from "react";
import { useState } from 'react';
import { ChevronLeft, Star, Coins, ChevronRight, Check } from './icons';
import { HeartFill, Heart } from './icons';
import { HeroCover } from './cover';
import type { Book } from '../data';
import { getChapters } from '../data';

interface BookDetailProps {
  book: Book;
  onBack: () => void;
  onRead: (book: Book, chapterId?: number) => void;
  coins: number;
}

const GENRE_HERO_BG: Record<string, string> = {
  werewolf: 'linear-gradient(180deg, #0c1425 0%, #1b2d50 60%, oklch(0.975 0.008 60) 100%)',
  ceo: 'linear-gradient(180deg, #141414 0%, #282828 60%, oklch(0.975 0.008 60) 100%)',
  reborn: 'linear-gradient(180deg, oklch(0.28 0.12 16) 0%, oklch(0.42 0.16 18) 60%, oklch(0.975 0.008 60) 100%)',
  vampire: 'linear-gradient(180deg, #07000a 0%, #160010 60%, oklch(0.975 0.008 60) 100%)',
  romantasy: 'linear-gradient(180deg, #170826 0%, #2b1252 60%, oklch(0.975 0.008 60) 100%)',
  modern: 'linear-gradient(180deg, #250c15 0%, #3c1525 60%, oklch(0.975 0.008 60) 100%)',
};

export function BookDetail({ book, onBack, onRead, coins }: BookDetailProps) {
  const [liked, setLiked] = useState(false);
  const [showAll, setShowAll] = useState(false);
  const chapters = getChapters(book.id);
  const displayChapters = showAll ? chapters : chapters.slice(0, 8);

  return (
    <div
      className="flex flex-col h-full overflow-hidden relative"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      {/* floating back button */}
      <button
        onClick={onBack}
        className="absolute top-12 left-4 z-20 w-10 h-10 rounded-full flex items-center justify-center shadow-md"
        style={{ background: 'rgba(255,255,255,0.88)', backdropFilter: 'blur(10px)', border: '1px solid rgba(255,255,255,0.5)' }}
      >
        <ChevronLeft className="w-5 h-5" style={{ color: '#1a0a0a' } as React.CSSProperties} />
      </button>

      <div className="flex-1 overflow-y-auto" style={{ scrollbarWidth: 'none' }}>
        {/* hero */}
        <div
          className="pt-16 pb-10 flex flex-col items-center relative"
          style={{ background: GENRE_HERO_BG[book.genre] ?? GENRE_HERO_BG.modern, minHeight: '260px' }}
        >
          <HeroCover genre={book.genre} title={book.title} author={book.author} badge={book.badge} />
        </div>

        {/* meta */}
        <div className="px-5 pt-5 pb-32">
          <h1 className="text-[22px] font-semibold mb-1 leading-tight" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
            {book.title}
          </h1>
          <p className="text-[13px] mb-4" style={{ color: 'var(--el-muted)' }}>{book.author}</p>

          {/* stats row */}
          <div className="flex items-center gap-1 flex-wrap mb-4">
            <div className="flex items-center gap-1 px-2.5 py-1 rounded-full" style={{ background: 'var(--el-surface-2)' }}>
              <Star className="w-3.5 h-3.5 fill-current" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />
              <span className="text-[12px] font-semibold" style={{ color: 'var(--el-ink)' }}>{book.rating.toFixed(1)}</span>
            </div>
            <div className="flex items-center px-2.5 py-1 rounded-full" style={{ background: 'var(--el-surface-2)' }}>
              <span className="text-[12px]" style={{ color: 'var(--el-muted)' }}>{book.reads} reads</span>
            </div>
            <div className="flex items-center px-2.5 py-1 rounded-full" style={{ background: 'var(--el-surface-2)' }}>
              <span className="text-[12px]" style={{ color: 'var(--el-muted)' }}>{book.chapters} chapters</span>
            </div>
            <div
              className="flex items-center px-2.5 py-1 rounded-full"
              style={{
                background: book.status === 'complete' ? 'oklch(0.88 0.06 150)' : 'var(--el-primary-soft)',
                color: book.status === 'complete' ? 'oklch(0.32 0.12 150)' : 'var(--el-primary-ink)',
              }}
            >
              {book.status === 'complete' && <Check className="w-3 h-3 mr-1" />}
              <span className="text-[11px] font-semibold">{book.status === 'complete' ? 'Complete' : 'Ongoing'}</span>
            </div>
          </div>

          {/* tropes */}
          <div className="flex flex-wrap gap-1.5 mb-5">
            {book.tropes.map(t => (
              <span
                key={t}
                className="text-[11px] px-3 py-1 rounded-full font-medium"
                style={{ background: 'var(--el-surface-2)', color: 'var(--el-ink)' }}
              >
                {t}
              </span>
            ))}
          </div>

          {/* blurb */}
          <p className="text-[14px] leading-relaxed mb-6" style={{ color: 'var(--el-ink)', fontFamily: 'Newsreader, serif' }}>
            {book.blurb}
          </p>

          {/* chapter divider */}
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[15px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Chapters</h2>
            <span className="text-[12px]" style={{ color: 'var(--el-muted)' }}>{book.chapters} total</span>
          </div>

          <div className="flex flex-col gap-1.5">
            {displayChapters.map(ch => (
              <button
                key={ch.id}
                onClick={() => onRead(book, ch.id)}
                className="flex items-center justify-between py-3 px-3.5 rounded-[13px] text-left transition-all active:scale-[0.99]"
                style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)' }}
              >
                <div className="flex-1 min-w-0">
                  <p className="text-[10px] font-semibold uppercase tracking-wider mb-0.5" style={{ color: 'var(--el-faint)' }}>
                    Ch. {ch.id}
                  </p>
                  <p className="text-[13px] font-medium truncate" style={{ color: 'var(--el-ink)' }}>{ch.title}</p>
                </div>
                {ch.free ? (
                  <span className="text-[11px] font-bold px-2.5 py-1 rounded-full flex-shrink-0 ml-3" style={{ background: 'oklch(0.88 0.06 150)', color: 'oklch(0.32 0.12 150)' }}>
                    Free
                  </span>
                ) : (
                  <span className="flex items-center gap-1 text-[11px] font-semibold flex-shrink-0 ml-3" style={{ color: 'var(--el-gold)' }}>
                    <Coins className="w-3 h-3" />{ch.coins}
                  </span>
                )}
              </button>
            ))}
          </div>

          {chapters.length > 8 && (
            <button
              onClick={() => setShowAll(s => !s)}
              className="w-full flex items-center justify-center gap-1.5 py-3 mt-2 rounded-[13px] text-[13px] font-semibold transition-all active:opacity-80"
              style={{ background: 'var(--el-surface-2)', color: 'var(--el-primary-ink)' }}
            >
              {showAll ? 'Show less' : `All ${chapters.length} chapters`}
              <ChevronRight className={`w-4 h-4 transition-transform duration-200 ${showAll ? 'rotate-90' : ''}`} />
            </button>
          )}
        </div>
      </div>

      {/* sticky bottom */}
      <div
        className="absolute bottom-0 left-0 right-0 px-5 pb-6 pt-4"
        style={{ background: 'linear-gradient(to top, var(--el-bg) 75%, transparent)' }}
      >
        <div className="flex items-center gap-3">
          <button
            onClick={() => setLiked(l => !l)}
            className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 transition-all active:scale-90 border"
            style={{
              background: liked ? 'var(--el-primary-soft)' : 'var(--el-surface)',
              borderColor: liked ? 'oklch(0.85 0.04 18)' : 'var(--el-line)',
            }}
          >
            {liked
              ? <HeartFill className="w-5 h-5" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />
              : <Heart className="w-5 h-5" style={{ color: 'var(--el-muted)' } as React.CSSProperties} />
            }
          </button>
          <button
            onClick={() => onRead(book, 1)}
            className="flex-1 rounded-[13px] py-3.5 font-semibold text-[15px] transition-all active:scale-[0.98]"
            style={{
              background: 'var(--el-primary)',
              color: 'var(--el-on-primary)',
              boxShadow: '0 4px 16px oklch(0.52 0.158 16 / 0.32)',
            }}
          >
            Read chapter 1 free
          </button>
        </div>
      </div>
    </div>
  );
}
