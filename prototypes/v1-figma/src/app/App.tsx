import * as React from "react";
/* MARKER-MAKE-KIT-INVOKED */
import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Home, BookOpen, Coins, User } from './components/icons';
import { Onboarding } from './components/onboarding';
import { Guide } from './components/guide';
import { Discover } from './components/discover';
import { BookDetail } from './components/book-detail';
import { Reader } from './components/reader';
import { Library } from './components/library';
import { Wallet } from './components/wallet';
import { Profile } from './components/profile';
import { PaywallSheet, RechargeSheet } from './components/sheets';
import { SubPage } from './components/subpages';
import type { Book } from './data';

type Screen =
  | 'onboarding'
  | 'guide'
  | 'discover'
  | 'book-detail'
  | 'reader'
  | 'library'
  | 'wallet'
  | 'me'
  | 'subpage';

type Tab = 'discover' | 'library' | 'wallet' | 'me';
type TransitionDir = 'push' | 'pop' | 'tab';

interface NavState {
  screen: Screen;
  tab: Tab;
  book?: Book;
  chapterId?: number;
  subpageKey?: string;
  stack: { screen: Screen; tab: Tab; book?: Book; chapterId?: number; subpageKey?: string }[];
}

const TAB_SCREENS: Record<Tab, Screen> = {
  discover: 'discover',
  library: 'library',
  wallet: 'wallet',
  me: 'me',
};

const HIDE_TABBAR: Screen[] = ['onboarding', 'guide', 'reader', 'book-detail', 'subpage'];

const TRANSITION = { duration: 0.22, ease: [0.25, 0.46, 0.45, 0.94] as const };
const FADE_TRANSITION = { duration: 0.12, ease: 'easeOut' as const };

function getVariants(dir: TransitionDir) {
  if (dir === 'push') {
    return {
      initial: { x: '100%', opacity: 0.6 },
      animate: { x: 0, opacity: 1 },
      exit: { x: '-24%', opacity: 0 },
    };
  }
  if (dir === 'pop') {
    return {
      initial: { x: '-24%', opacity: 0 },
      animate: { x: 0, opacity: 1 },
      exit: { x: '100%', opacity: 0.6 },
    };
  }
  // tab
  return {
    initial: { opacity: 0, scale: 0.98 },
    animate: { opacity: 1, scale: 1 },
    exit: { opacity: 0, scale: 0.98 },
  };
}

export default function App() {
  const [coins, setCoins] = useState(640);
  const [showPaywall, setShowPaywall] = useState(false);
  const [showRecharge, setShowRecharge] = useState(false);
  const [paywallBook, setPaywallBook] = useState<Book | null>(null);
  const [paywallChapter, setPaywallChapter] = useState(4);
  const [toastMsg, setToastMsg] = useState('');
  const [toastVisible, setToastVisible] = useState(false);
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [transitionDir, setTransitionDir] = useState<TransitionDir>('push');

  const [nav, setNav] = useState<NavState>({
    screen: 'onboarding',
    tab: 'discover',
    stack: [],
  });

  function showToast(msg: string) {
    if (toastTimer.current) clearTimeout(toastTimer.current);
    setToastMsg(msg);
    setToastVisible(true);
    toastTimer.current = setTimeout(() => setToastVisible(false), 2200);
  }

  function push(screen: Screen, opts?: { book?: Book; chapterId?: number; subpageKey?: string }) {
    setTransitionDir('push');
    setNav(n => ({
      ...n,
      screen,
      ...(opts ?? {}),
      stack: [...n.stack, { screen: n.screen, tab: n.tab, book: n.book, chapterId: n.chapterId, subpageKey: n.subpageKey }],
    }));
  }

  function goBack() {
    setTransitionDir('pop');
    setNav(n => {
      if (n.stack.length === 0) return n;
      const prev = n.stack[n.stack.length - 1];
      return { ...n, ...prev, stack: n.stack.slice(0, -1) };
    });
  }

  function switchTab(tab: Tab) {
    setTransitionDir('tab');
    setNav(n => ({
      ...n,
      tab,
      screen: TAB_SCREENS[tab],
      stack: [],
    }));
  }

  function openPaywall(book: Book, chapterId = 4) {
    setPaywallBook(book);
    setPaywallChapter(chapterId);
    setShowPaywall(true);
  }

  function handleUnlock() {
    if (coins >= 38) {
      setCoins(c => c - 38);
      setShowPaywall(false);
      showToast('Chapter unlocked! ✓');
    }
  }

  function handleRecharge(added: number) {
    setCoins(c => c + added);
    showToast(`+${added} coins added!`);
  }

  const { screen, tab, book, chapterId, subpageKey } = nav;
  const showTabBar = !HIDE_TABBAR.includes(screen);
  const vars = getVariants(transitionDir);

  return (
    <div
      className="flex items-center justify-center min-h-screen bg-[oklch(0.86_0.012_56)]"
      style={{ fontFamily: 'Inter, sans-serif' }}
    >
      {/* phone frame — responsive: full-screen on small viewports, framed on larger */}
      <div
        className="relative flex flex-col overflow-hidden
          w-full h-dvh
          sm:w-[412px] sm:h-[892px] sm:max-h-[892px] sm:rounded-[40px]"
        style={{
          background: 'var(--el-bg)',
          boxShadow: '0 40px 100px rgba(80,20,10,0.22)',
          border: '1px solid oklch(0.80 0.015 56)',
        }}
      >
        {/* status bar */}
        <div
          className="flex items-center justify-between px-7 flex-shrink-0 z-10 pointer-events-none"
          style={{ height: '28px', background: screen === 'reader' ? 'transparent' : 'var(--el-bg)' }}
        >
          <span className="text-[11px] font-semibold tabular-nums" style={{ color: 'var(--el-ink)' }}>9:41</span>
          <div className="flex items-center gap-1.5">
            {/* signal dots */}
            {[1,2,3].map(i => (
              <div key={i} className="w-1 rounded-full" style={{ height: `${4 + i * 2}px`, background: 'var(--el-ink)', opacity: i < 3 ? 0.4 + i * 0.2 : 1 }} />
            ))}
            {/* battery */}
            <div className="w-5 h-2.5 rounded-sm border flex items-center px-0.5 ml-0.5" style={{ borderColor: 'var(--el-ink)' }}>
              <div className="h-1.5 rounded-[1px] flex-1" style={{ background: 'var(--el-ink)', width: '75%' }} />
            </div>
          </div>
        </div>

        {/* main animated screen */}
        <div className="flex-1 overflow-hidden relative">
          <AnimatePresence mode="wait" initial={false}>
            <motion.div
              key={`${screen}-${subpageKey ?? ''}-${book?.id ?? ''}`}
              initial={vars.initial}
              animate={vars.animate}
              exit={vars.exit}
              transition={transitionDir === 'tab' ? FADE_TRANSITION : TRANSITION}
              className="absolute inset-0"
              style={{ willChange: 'transform, opacity' }}
            >
              {screen === 'onboarding' && (
                <Onboarding onContinue={() => push('guide')} />
              )}
              {screen === 'guide' && (
                <Guide
                  onBack={goBack}
                  onContinue={() => {
                    setTransitionDir('push');
                    setNav(n => ({ ...n, screen: 'discover', tab: 'discover', stack: [] }));
                  }}
                />
              )}
              {screen === 'discover' && (
                <Discover
                  onBook={b => push('book-detail', { book: b })}
                  onWallet={() => switchTab('wallet')}
                  onMessages={() => push('subpage', { subpageKey: 'messages' })}
                  onSearch={() => push('subpage', { subpageKey: 'search' })}
                  coins={coins}
                  unreadMessages={3}
                />
              )}
              {screen === 'book-detail' && book && (
                <BookDetail
                  book={book}
                  onBack={goBack}
                  onRead={(b, ch) => push('reader', { book: b, chapterId: ch ?? 1 })}
                  coins={coins}
                />
              )}
              {screen === 'reader' && book && (
                <Reader
                  book={book}
                  chapterId={chapterId ?? 1}
                  onBack={goBack}
                  onPaywall={b => openPaywall(b, (chapterId ?? 1) + 1)}
                  coins={coins}
                />
              )}
              {screen === 'library' && (
                <Library
                  onBook={b => push('book-detail', { book: b })}
                  onRead={b => push('reader', { book: b })}
                />
              )}
              {screen === 'wallet' && (
                <Wallet
                  coins={coins}
                  onTopUp={() => setShowRecharge(true)}
                  onCheckin={() => push('subpage', { subpageKey: 'daily-checkin' })}
                />
              )}
              {screen === 'me' && (
                <Profile
                  coins={coins}
                  onNav={key => push('subpage', { subpageKey: key })}
                  onSettings={() => push('subpage', { subpageKey: 'settings' })}
                />
              )}
              {screen === 'subpage' && subpageKey && (
                <SubPage
                  pageKey={subpageKey}
                  onBack={goBack}
                  onBook={b => push('book-detail', { book: b })}
                  onTopUp={() => setShowRecharge(true)}
                  coins={coins}
                />
              )}
            </motion.div>
          </AnimatePresence>

          {/* Paywall Sheet (animated from bottom) */}
          <AnimatePresence>
            {showPaywall && paywallBook && (
              <motion.div
                className="absolute inset-0 z-50 flex items-end"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.18 }}
                style={{ background: 'rgba(0,0,0,0.45)' }}
                onClick={() => setShowPaywall(false)}
              >
                <motion.div
                  className="w-full"
                  initial={{ y: '100%' }}
                  animate={{ y: 0 }}
                  exit={{ y: '100%' }}
                  transition={{ duration: 0.26, ease: [0.32, 0.72, 0, 1] }}
                  onClick={e => e.stopPropagation()}
                >
                  <PaywallSheet
                    book={paywallBook}
                    chapterId={paywallChapter}
                    coins={coins}
                    onClose={() => setShowPaywall(false)}
                    onUnlock={handleUnlock}
                    onTopUp={() => { setShowPaywall(false); setShowRecharge(true); }}
                  />
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Recharge Sheet */}
          <AnimatePresence>
            {showRecharge && (
              <motion.div
                className="absolute inset-0 z-50 flex items-end"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.18 }}
                style={{ background: 'rgba(0,0,0,0.45)' }}
                onClick={() => setShowRecharge(false)}
              >
                <motion.div
                  className="w-full"
                  initial={{ y: '100%' }}
                  animate={{ y: 0 }}
                  exit={{ y: '100%' }}
                  transition={{ duration: 0.26, ease: [0.32, 0.72, 0, 1] }}
                  onClick={e => e.stopPropagation()}
                >
                  <RechargeSheet
                    coins={coins}
                    onClose={() => setShowRecharge(false)}
                    onPurchase={handleRecharge}
                  />
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Toast */}
          <AnimatePresence>
            {toastVisible && (
              <motion.div
                className="absolute bottom-6 left-0 right-0 flex justify-center z-50 pointer-events-none"
                initial={{ opacity: 0, y: 12, scale: 0.92 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 8, scale: 0.94 }}
                transition={{ duration: 0.2 }}
              >
                <div
                  className="px-5 py-3 rounded-full text-sm font-medium shadow-xl"
                  style={{ background: 'var(--el-ink)', color: 'oklch(0.99 0.01 80)', backdropFilter: 'blur(8px)' }}
                >
                  {toastMsg}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* bottom tab bar */}
        <AnimatePresence>
          {showTabBar && (
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 16 }}
              transition={FADE_TRANSITION}
              className="flex-shrink-0"
            >
              <div
                className="flex items-center px-3 pt-1 pb-1"
                style={{
                  borderTop: '1px solid var(--el-line)',
                  background: 'var(--el-surface)',
                  height: '58px',
                }}
              >
                {([
                  { key: 'discover', Icon: Home, label: 'Discover' },
                  { key: 'library', Icon: BookOpen, label: 'Library' },
                  { key: 'wallet', Icon: Coins, label: 'Wallet' },
                  { key: 'me', Icon: User, label: 'Me' },
                ] as const).map(({ key, Icon, label }) => {
                  const active = tab === key;
                  return (
                    <button
                      key={key}
                      onClick={() => switchTab(key)}
                      className="flex-1 flex flex-col items-center justify-center gap-0.5 h-full rounded-[10px] transition-colors active:opacity-70"
                      style={{ background: active ? 'var(--el-primary-soft)' : 'transparent' }}
                    >
                      <Icon
                        className="w-[22px] h-[22px]"
                        style={{ color: active ? 'var(--el-primary)' : 'var(--el-faint)' } as React.CSSProperties}
                      />
                      <span
                        className="text-[10px] font-semibold leading-none"
                        style={{ color: active ? 'var(--el-primary-ink)' : 'var(--el-faint)' }}
                      >
                        {label}
                      </span>
                    </button>
                  );
                })}
              </div>

              {/* home indicator */}
              <div className="flex justify-center py-2" style={{ background: 'var(--el-surface)' }}>
                <div className="w-28 h-1 rounded-full" style={{ background: 'var(--el-line)' }} />
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* home indicator when no tab bar (reader, etc.) */}
        {!showTabBar && screen !== 'onboarding' && (
          <div className="flex justify-center py-2 flex-shrink-0" style={{ background: 'transparent' }}>
            <div className="w-28 h-1 rounded-full" style={{ background: 'rgba(120,80,60,0.2)' }} />
          </div>
        )}
      </div>
    </div>
  );
}
