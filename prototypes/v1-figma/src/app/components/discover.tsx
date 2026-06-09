import * as React from "react";
import { useState, useEffect } from 'react';
import { Bell, Search, Star, ChevronRight, Coins } from './icons';
import { Cover, FluidCover, HeroCover } from './cover';
import { BOOKS, GENRE_TABS, type Book } from '../data';

interface DiscoverProps {
  onBook: (book: Book) => void;
  onWallet: () => void;
  onMessages: () => void;
  onSearch: () => void;
  coins: number;
  unreadMessages: number;
}

function RatingBadge({ rating, small = false }: { rating: number; small?: boolean }) {
  return (
    <span className={`flex items-center gap-0.5 font-semibold ${small ? 'text-[10px]' : 'text-xs'}`} style={{ color: 'var(--el-gold)' }}>
      <Star className={small ? 'w-2.5 h-2.5 fill-current' : 'w-3 h-3 fill-current'} />
      {rating.toFixed(1)}
    </span>
  );
}

function Skeleton({ className }: { className?: string }) {
  return (
    <div
      className={`rounded-[13px] overflow-hidden ${className}`}
      style={{
        background: 'linear-gradient(90deg, var(--el-surface-2) 25%, var(--el-surface-3) 50%, var(--el-surface-2) 75%)',
        backgroundSize: '200% 100%',
        animation: 'shimmer 1.4s infinite',
      }}
    />
  );
}

/* shimmer keyframes injected once */
const SHIMMER_STYLE = `
  @keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
  }
`;

export function Discover({ onBook, onWallet, onMessages, onSearch, coins, unreadMessages }: DiscoverProps) {
  const [activeGenre, setActiveGenre] = useState('For you');
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setLoaded(true), 900);
    return () => clearTimeout(t);
  }, []);

  const heroBooks = BOOKS.slice(0, 4);
  const topCharts = BOOKS.slice(0, 5);
  const newRising = BOOKS.slice(2, 7);
  const forYou = BOOKS;

  return (
    <div
      className="flex flex-col h-full overflow-hidden"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      <style>{SHIMMER_STYLE}</style>

      {/* top bar */}
      <div className="px-4 pt-12 pb-3 flex-shrink-0">
        <div className="flex items-start justify-between mb-3">
          <div>
            <p className="text-[10px] font-semibold uppercase tracking-[0.12em] mb-0.5" style={{ color: 'var(--el-muted)' }}>Discover</p>
            <h1 className="text-[26px] font-semibold tracking-tight leading-none" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
              likenovel
            </h1>
          </div>
          <div className="flex items-center gap-2 pt-1">
            <button
              onClick={onWallet}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full border transition-all active:scale-95"
              style={{ background: 'var(--el-surface)', borderColor: 'var(--el-line)' }}
            >
              <Coins className="w-3.5 h-3.5" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />
              <span className="text-xs font-semibold tabular-nums" style={{ color: 'var(--el-ink)' }}>{coins.toLocaleString()}</span>
            </button>
            <button
              onClick={onMessages}
              className="relative w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90"
              style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)' }}
            >
              <Bell className="w-[18px] h-[18px]" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
              {unreadMessages > 0 && (
                <span className="absolute top-1 right-1 w-2 h-2 rounded-full border-2" style={{ background: 'var(--el-primary)', borderColor: 'var(--el-surface)' }} />
              )}
            </button>
          </div>
        </div>

        {/* search bar */}
        <button
          onClick={onSearch}
          className="w-full flex items-center gap-2.5 px-4 py-3 rounded-[13px] text-sm text-left transition-all active:scale-[0.99]"
          style={{ background: 'var(--el-surface-2)', color: 'var(--el-muted)' }}
        >
          <Search className="w-4 h-4 flex-shrink-0 opacity-60" />
          Search titles, authors, tropes
        </button>
      </div>

      {/* genre chip row */}
      <div className="flex-shrink-0 overflow-x-auto px-4 pb-2" style={{ scrollbarWidth: 'none' }}>
        <div className="flex gap-2 w-max">
          {GENRE_TABS.map(g => {
            const active = g === activeGenre;
            return (
              <button
                key={g}
                onClick={() => setActiveGenre(g)}
                className="px-4 py-1.5 rounded-full text-[13px] font-semibold flex-shrink-0 transition-all active:scale-95"
                style={{
                  background: active ? 'var(--el-primary-soft)' : 'var(--el-surface)',
                  color: active ? 'var(--el-primary-ink)' : 'var(--el-muted)',
                  border: active ? '1.5px solid oklch(0.85 0.04 18)' : '1.5px solid var(--el-line)',
                }}
              >
                {g}
              </button>
            );
          })}
        </div>
      </div>

      {/* content */}
      <div className="flex-1 overflow-y-auto" style={{ scrollbarWidth: 'none' }}>

        {/* ── Hero carousel ── */}
        <div className="mb-5">
          <div className="overflow-x-auto px-4" style={{ scrollbarWidth: 'none' }}>
            <div className="flex gap-3 w-max pb-1">
              {heroBooks.map(book => (
                <button
                  key={book.id}
                  onClick={() => onBook(book)}
                  className="flex-shrink-0 w-[288px] rounded-[18px] overflow-hidden text-left transition-all active:scale-[0.98]"
                  style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)', boxShadow: '0 2px 12px rgba(80,20,10,0.06)' }}
                >
                  <div className="flex p-3 gap-3 items-start">
                    <HeroCover genre={book.genre} title={book.title} author={book.author} badge={book.badge} />
                    <div className="flex flex-col justify-between flex-1 min-w-0 h-[210px]">
                      <div>
                        <div className="flex flex-wrap gap-1 mb-2">
                          {book.tropes.slice(0, 2).map(t => (
                            <span
                              key={t}
                              className="text-[9px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full"
                              style={{ background: 'var(--el-primary-soft)', color: 'var(--el-primary-ink)' }}
                            >
                              {t}
                            </span>
                          ))}
                        </div>
                        <p className="text-sm font-semibold leading-tight mb-2" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
                          {book.title}
                        </p>
                        <p className="text-xs leading-relaxed" style={{ color: 'var(--el-muted)', display: '-webkit-box', WebkitLineClamp: 4, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                          {book.blurb}
                        </p>
                      </div>
                      <div className="flex items-center gap-3 mt-2">
                        <RatingBadge rating={book.rating} />
                        <span className="text-[10px]" style={{ color: 'var(--el-faint)' }}>{book.reads}</span>
                        <span className="text-[10px]" style={{ color: 'var(--el-faint)' }}>{book.chapters}ch</span>
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* ── Top charts ── */}
        <section className="mb-5">
          <div className="flex items-center justify-between px-4 mb-3">
            <h2 className="text-[15px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Top charts</h2>
            <button className="flex items-center gap-0.5 text-xs font-medium" style={{ color: 'var(--el-primary-ink)' }}>
              More <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
          <div className="overflow-x-auto px-4" style={{ scrollbarWidth: 'none' }}>
            <div className="flex gap-3 w-max pb-1">
              {loaded
                ? topCharts.map((book, i) => (
                    <button key={book.id} onClick={() => onBook(book)} className="flex-shrink-0 w-[120px] text-left transition-all active:scale-[0.97]">
                      <div className="relative">
                        <Cover genre={book.genre} title={book.title} author={book.author} size="lg" />
                        <div
                          className="absolute -bottom-2 -left-1 w-7 h-7 rounded-full flex items-center justify-center text-[10px] font-bold border-2"
                          style={{
                            background: i === 0 ? 'var(--el-gold)' : 'var(--el-surface)',
                            color: i === 0 ? '#1a1200' : 'var(--el-ink)',
                            borderColor: 'var(--el-bg)',
                            boxShadow: '0 2px 6px rgba(0,0,0,0.12)',
                          }}
                        >
                          {i + 1}
                        </div>
                      </div>
                      <div className="mt-4 px-0.5">
                        <p className="text-[11px] font-semibold leading-tight mb-1" style={{ color: 'var(--el-ink)', fontFamily: 'Newsreader, serif' }}>
                          {book.title}
                        </p>
                        <RatingBadge rating={book.rating} small />
                      </div>
                    </button>
                  ))
                : Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="flex-shrink-0 w-[120px]">
                      <Skeleton className="w-[140px] h-[196px]" />
                      <Skeleton className="mt-4 h-3 w-20" />
                    </div>
                  ))
              }
            </div>
          </div>
        </section>

        {/* ── New & rising ── */}
        <section className="mb-5">
          <div className="flex items-center justify-between px-4 mb-3">
            <h2 className="text-[15px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>New & rising</h2>
            <button className="flex items-center gap-0.5 text-xs font-medium" style={{ color: 'var(--el-primary-ink)' }}>
              More <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
          <div className="overflow-x-auto px-4" style={{ scrollbarWidth: 'none' }}>
            <div className="flex gap-3 w-max pb-1">
              {loaded
                ? BOOKS.slice(2, 7).map(book => (
                    <button key={book.id} onClick={() => onBook(book)} className="flex-shrink-0 text-left transition-all active:scale-[0.97]">
                      <Cover genre={book.genre} title={book.title} author={book.author} badge={book.badge} size="md" />
                      <p className="text-[11px] font-semibold mt-2 leading-tight" style={{ color: 'var(--el-ink)', fontFamily: 'Newsreader, serif', maxWidth: '108px' }}>
                        {book.title}
                      </p>
                      <RatingBadge rating={book.rating} small />
                    </button>
                  ))
                : Array.from({ length: 5 }).map((_, i) => (
                    <div key={i} className="flex-shrink-0">
                      <Skeleton className="w-[108px] h-[152px]" />
                      <Skeleton className="mt-2 h-3 w-20" />
                    </div>
                  ))
              }
            </div>
          </div>
        </section>

        {/* ── For you grid ── */}
        <section className="mb-6">
          <div className="flex items-center justify-between px-4 mb-3">
            <h2 className="text-[15px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>For you</h2>
            <button className="flex items-center gap-0.5 text-xs font-medium" style={{ color: 'var(--el-primary-ink)' }}>
              More <ChevronRight className="w-3.5 h-3.5" />
            </button>
          </div>
          <div className="grid grid-cols-2 gap-x-3 gap-y-4 px-4">
            {loaded
              ? forYou.map(book => (
                  <button key={book.id} onClick={() => onBook(book)} className="text-left transition-all active:scale-[0.97]">
                    <FluidCover genre={book.genre} title={book.title} author={book.author} badge={book.badge} />
                    <p className="text-[12px] font-semibold mt-2 leading-tight" style={{ color: 'var(--el-ink)', fontFamily: 'Newsreader, serif' }}>
                      {book.title}
                    </p>
                    <p className="text-[10px] mt-0.5" style={{ color: 'var(--el-faint)' }}>{book.author}</p>
                    <RatingBadge rating={book.rating} small />
                  </button>
                ))
              : Array.from({ length: 6 }).map((_, i) => (
                  <div key={i}>
                    <div className="w-full rounded-[13px] overflow-hidden" style={{ aspectRatio: '5/7' }}>
                      <Skeleton className="w-full h-full" />
                    </div>
                    <Skeleton className="mt-2 h-3 w-20" />
                    <Skeleton className="mt-1 h-2 w-14" />
                  </div>
                ))
            }
          </div>
        </section>

        <div className="h-4" />
      </div>
    </div>
  );
}
