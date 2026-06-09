import * as React from "react";
import { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronLeft, List, SlidersHorizontal, Lock, Coins } from './icons';
import type { Book } from '../data';
import { CHAPTER_SAMPLE_TEXT } from '../data';

type Theme = 'paper' | 'sepia' | 'dark' | 'black';

const THEMES: Record<Theme, { bg: string; text: string; muted: string; border: string; label: string; chip: string }> = {
  paper: { bg: 'oklch(0.972 0.006 85)', text: 'oklch(0.27 0.012 60)', muted: 'oklch(0.52 0.010 60)', border: 'rgba(0,0,0,0.07)', label: 'Paper', chip: '#f7f1e6' },
  sepia: { bg: 'oklch(0.91 0.035 75)', text: 'oklch(0.33 0.025 55)', muted: 'oklch(0.54 0.018 55)', border: 'rgba(0,0,0,0.08)', label: 'Sepia', chip: '#c8a87a' },
  dark: { bg: 'oklch(0.21 0.012 300)', text: 'oklch(0.88 0.01 80)', muted: 'oklch(0.62 0.008 80)', border: 'rgba(255,255,255,0.07)', label: 'Dark', chip: '#3a3548' },
  black: { bg: 'oklch(0.05 0 0)', text: 'oklch(0.80 0 0)', muted: 'oklch(0.55 0 0)', border: 'rgba(255,255,255,0.05)', label: 'Black', chip: '#111' },
};

const FONT_SIZES = [14, 16, 18];

interface ReaderProps {
  book: Book;
  chapterId?: number;
  onBack: () => void;
  onPaywall: (book: Book) => void;
  coins: number;
}

export function Reader({ book, chapterId = 1, onBack, onPaywall, coins }: ReaderProps) {
  const [theme, setTheme] = useState<Theme>('paper');
  const [fontSizeIdx, setFontSizeIdx] = useState(1);
  const [showChrome, setShowChrome] = useState(true);
  const [showSettings, setShowSettings] = useState(false);
  const touchStart = useRef<number | null>(null);

  const t = THEMES[theme];
  const fontSize = FONT_SIZES[fontSizeIdx];
  const isDark = theme === 'dark' || theme === 'black';
  const progress = Math.min(Math.round(((chapterId - 1) / book.chapters) * 100), 100);

  function handleContentClick() {
    if (!showSettings) setShowChrome(c => !c);
  }

  function handleSettingsBtn(e: React.MouseEvent) {
    e.stopPropagation();
    setShowSettings(s => !s);
    setShowChrome(true);
  }

  return (
    <div
      className="flex flex-col h-full relative overflow-hidden"
      style={{ background: t.bg, fontFamily: 'Inter, sans-serif' }}
    >
      {/* ── Top bar ── */}
      <AnimatePresence>
        {showChrome && (
          <motion.div
            initial={{ opacity: 0, y: -12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.18 }}
            className="flex items-center justify-between px-4 pt-12 pb-3 flex-shrink-0 z-10"
            style={{ borderBottom: `1px solid ${t.border}` }}
          >
            <button
              onClick={onBack}
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ background: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }}
            >
              <ChevronLeft className="w-5 h-5" style={{ color: t.text } as React.CSSProperties} />
            </button>

            <p className="text-[13px] font-semibold truncate max-w-[180px]" style={{ color: t.text, fontFamily: 'Newsreader, serif' }}>
              {book.title}
            </p>

            <div className="flex items-center gap-1.5">
              <button
                className="w-9 h-9 rounded-full flex items-center justify-center"
                style={{ background: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }}
              >
                <List className="w-[18px] h-[18px]" style={{ color: t.text } as React.CSSProperties} />
              </button>
              <button
                onClick={handleSettingsBtn}
                className="w-9 h-9 rounded-full flex items-center justify-center"
                style={{ background: showSettings ? (isDark ? 'rgba(255,255,255,0.14)' : 'rgba(0,0,0,0.1)') : (isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)') }}
              >
                <SlidersHorizontal className="w-[18px] h-[18px]" style={{ color: t.text } as React.CSSProperties} />
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Body ── */}
      <div
        className="flex-1 overflow-y-auto"
        style={{ scrollbarWidth: 'none' }}
        onClick={handleContentClick}
      >
        <div className="px-6 pt-8 pb-4">
          <p
            className="text-[10px] font-semibold uppercase tracking-[0.14em] mb-3"
            style={{ color: t.muted, fontFamily: 'Inter, sans-serif' }}
          >
            Chapter {chapterId}
          </p>
          <h2 className="text-[22px] font-semibold mb-7 leading-tight" style={{ color: t.text, fontFamily: 'Newsreader, serif' }}>
            {chapterId === 1 ? 'A Fateful Encounter' : chapterId === 2 ? "The Alpha's Mark" : `Chapter ${chapterId}`}
          </h2>

          <div style={{ fontSize: `${fontSize}px`, lineHeight: 1.85, color: t.text, fontFamily: 'Newsreader, serif' }}>
            {[...CHAPTER_SAMPLE_TEXT.split('\n\n'), ...CHAPTER_SAMPLE_TEXT.split('\n\n')].map((para, i) => (
              <p key={i} className="mb-[1.4em]">{para}</p>
            ))}
          </div>
        </div>

        {/* inline paywall */}
        <div
          className="mx-5 mb-8 rounded-[18px] p-5 flex flex-col items-center text-center"
          style={{
            background: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.04)',
            border: `1px solid ${t.border}`,
          }}
          onClick={e => e.stopPropagation()}
        >
          <div
            className="w-12 h-12 rounded-full flex items-center justify-center mb-3"
            style={{ background: 'var(--el-primary-soft)' }}
          >
            <Lock className="w-6 h-6" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />
          </div>
          <p className="font-semibold text-[15px] mb-1" style={{ color: t.text, fontFamily: 'Newsreader, serif' }}>
            Continue Chapter {chapterId + 1}
          </p>
          <p className="text-[12px] mb-4" style={{ color: t.muted }}>
            Unlock to keep reading
          </p>
          <button
            onClick={() => onPaywall(book)}
            className="px-6 py-2.5 rounded-full font-semibold text-[13px] transition-all active:scale-[0.97]"
            style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)', boxShadow: '0 4px 12px oklch(0.52 0.158 16 / 0.3)' }}
          >
            Unlock chapter
          </button>
        </div>
      </div>

      {/* ── Bottom bar ── */}
      <AnimatePresence>
        {showChrome && (
          <motion.div
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 14 }}
            transition={{ duration: 0.18 }}
            className="flex-shrink-0 px-5 pb-6 pt-3"
            style={{ borderTop: `1px solid ${t.border}` }}
          >
            {/* progress */}
            <div className="flex items-center gap-3 mb-3">
              <span className="text-[11px] w-8 text-right tabular-nums" style={{ color: t.muted }}>{progress}%</span>
              <div className="flex-1 h-1 rounded-full overflow-hidden" style={{ background: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.08)' }}>
                <div className="h-full rounded-full transition-all duration-300" style={{ width: `${progress}%`, background: 'var(--el-primary)' }} />
              </div>
              <span className="text-[11px] w-8 tabular-nums" style={{ color: t.muted }}>{book.chapters}ch</span>
            </div>

            <button
              onClick={() => onPaywall(book)}
              className="w-full rounded-[13px] py-3 font-semibold text-[14px] transition-all active:scale-[0.98] flex items-center justify-center gap-2"
              style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)', boxShadow: '0 4px 14px oklch(0.52 0.158 16 / 0.28)' }}
            >
              <Coins className="w-4 h-4" />
              Unlock chapter {chapterId + 1} · 38 coins
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Settings sheet ── */}
      <AnimatePresence>
        {showSettings && (
          <motion.div
            className="absolute inset-0 z-30 flex items-end"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            style={{ background: 'rgba(0,0,0,0.35)' }}
            onClick={() => setShowSettings(false)}
          >
            <motion.div
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ duration: 0.24, ease: [0.32, 0.72, 0, 1] }}
              className="w-full rounded-t-[26px] pt-3 px-6 pb-10"
              style={{ background: 'var(--el-surface)' }}
              onClick={e => e.stopPropagation()}
            >
              <div className="w-10 h-1 rounded-full mx-auto mb-5" style={{ background: 'var(--el-line)' }} />
              <p className="text-[15px] font-semibold mb-5" style={{ color: 'var(--el-ink)' }}>Reading settings</p>

              {/* font size stepper */}
              <div className="flex items-center justify-between mb-6">
                <p className="text-[13px]" style={{ color: 'var(--el-muted)' }}>Font size</p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setFontSizeIdx(i => Math.max(0, i - 1))}
                    disabled={fontSizeIdx === 0}
                    className="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm border transition-all active:scale-90 disabled:opacity-30"
                    style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)', background: 'var(--el-surface-2)' }}
                  >
                    A<sup>−</sup>
                  </button>
                  <span className="text-[13px] font-semibold w-10 text-center tabular-nums" style={{ color: 'var(--el-ink)' }}>{fontSize}px</span>
                  <button
                    onClick={() => setFontSizeIdx(i => Math.min(FONT_SIZES.length - 1, i + 1))}
                    disabled={fontSizeIdx === FONT_SIZES.length - 1}
                    className="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm border transition-all active:scale-90 disabled:opacity-30"
                    style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)', background: 'var(--el-surface-2)' }}
                  >
                    A<sup>+</sup>
                  </button>
                </div>
              </div>

              {/* theme swatches */}
              <div className="flex items-center justify-between">
                <p className="text-[13px]" style={{ color: 'var(--el-muted)' }}>Theme</p>
                <div className="flex items-center gap-2.5">
                  {(Object.keys(THEMES) as Theme[]).map(th => (
                    <button
                      key={th}
                      onClick={() => setTheme(th)}
                      title={THEMES[th].label}
                      className="w-11 h-11 rounded-full border-[2.5px] transition-all active:scale-90"
                      style={{
                        background: THEMES[th].chip,
                        borderColor: theme === th ? 'var(--el-primary)' : 'transparent',
                        outline: theme === th ? '2px solid var(--el-bg)' : 'none',
                        outlineOffset: '2px',
                        boxShadow: '0 1px 4px rgba(0,0,0,0.12)',
                      }}
                    />
                  ))}
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
