import * as React from "react";
import { useState } from 'react';
import { ChevronLeft, ChevronRight, Check, Coins, Lock, Trash2, AlertCircle, Flame } from './icons';
import { Cover } from './cover';
import { BOOKS } from '../data';
import * as Switch from '@radix-ui/react-switch';

interface SubPageProps {
  pageKey: string;
  onBack: () => void;
  onBook?: (book: any) => void;
  onTopUp?: () => void;
  coins?: number;
}

/* ─── Shared sub-page shell ──────────────────────────────── */
function SubShell({ eyebrow, title, children, onBack }: { eyebrow: string; title: string; children: React.ReactNode; onBack: () => void }) {
  return (
    <div className="flex flex-col h-full" style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}>
      <div className="flex items-center gap-3 px-4 pt-12 pb-4 flex-shrink-0">
        <button
          onClick={onBack}
          className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
          style={{ background: 'var(--el-surface-2)' }}
        >
          <ChevronLeft className="w-5 h-5" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
        </button>
        <div>
          <p className="text-xs font-medium uppercase tracking-widest" style={{ color: 'var(--el-muted)' }}>{eyebrow}</p>
          <h1 className="text-xl font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>{title}</h1>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-8" style={{ scrollbarWidth: 'none' }}>
        {children}
      </div>
    </div>
  );
}

/* ─── Toggle row ─────────────────────────────────────────── */
function ToggleRow({ label, defaultOn = true }: { label: string; defaultOn?: boolean }) {
  const [on, setOn] = useState(defaultOn);
  return (
    <div className="flex items-center justify-between py-3.5 px-4 rounded-[13px] mb-2" style={{ background: 'var(--el-surface)' }}>
      <span className="text-sm" style={{ color: 'var(--el-ink)' }}>{label}</span>
      <Switch.Root
        checked={on}
        onCheckedChange={setOn}
        className="relative w-11 h-6 rounded-full transition-colors"
        style={{ background: on ? 'var(--el-primary)' : 'var(--el-surface-3)' }}
      >
        <Switch.Thumb
          className="block w-5 h-5 rounded-full shadow transition-transform"
          style={{
            background: 'white',
            transform: on ? 'translateX(22px)' : 'translateX(2px)',
            marginTop: '2px',
          }}
        />
      </Switch.Root>
    </div>
  );
}

/* ─── Radio row ──────────────────────────────────────────── */
function RadioRow({ label, selected, onSelect }: { label: string; selected: boolean; onSelect: () => void }) {
  return (
    <button
      onClick={onSelect}
      className="w-full flex items-center justify-between py-3.5 px-4 rounded-[13px] mb-2 transition-colors"
      style={{ background: 'var(--el-surface)' }}
    >
      <span className="text-sm" style={{ color: 'var(--el-ink)' }}>{label}</span>
      {selected && <Check className="w-5 h-5" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />}
    </button>
  );
}

/* ─── Transactions ───────────────────────────────────────── */
function Transactions({ onBack }: { onBack: () => void }) {
  const rows = [
    { label: 'Unlock · Chapter 11', sub: 'His Crimson Vow', date: 'Today, 2:14 PM', amount: -38, type: 'spend' },
    { label: 'Daily check-in', sub: 'Reward', date: 'Today, 9:00 AM', amount: +20, type: 'earn' },
    { label: 'Recharge · 1,400 coins', sub: 'Google Play', date: 'Jun 8, 6:45 PM', amount: +1640, type: 'earn' },
    { label: 'Unlock · Chapter 10', sub: 'His Crimson Vow', date: 'Jun 8, 6:20 PM', amount: -38, type: 'spend' },
    { label: 'Watch & earn', sub: 'Ad reward', date: 'Jun 7, 3:30 PM', amount: +12, type: 'earn' },
    { label: 'Unlock · Chapter 9', sub: 'His Crimson Vow', date: 'Jun 7, 1:10 PM', amount: -38, type: 'spend' },
    { label: 'Daily check-in', sub: 'Reward', date: 'Jun 7, 9:00 AM', amount: +20, type: 'earn' },
  ];
  return (
    <SubShell eyebrow="Wallet" title="Transactions" onBack={onBack}>
      <div className="flex flex-col gap-2 mt-2">
        {rows.map((r, i) => (
          <div key={i} className="flex items-center gap-3 px-4 py-3 rounded-[13px]" style={{ background: 'var(--el-surface)' }}>
            <div className="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0" style={{ background: r.type === 'earn' ? 'oklch(0.88 0.06 150)' : 'var(--el-primary-soft)' }}>
              <Coins className="w-4 h-4" style={{ color: r.type === 'earn' ? 'oklch(0.35 0.12 150)' : 'var(--el-primary)' } as React.CSSProperties} />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate" style={{ color: 'var(--el-ink)' }}>{r.label}</p>
              <p className="text-xs" style={{ color: 'var(--el-muted)' }}>{r.sub} · {r.date}</p>
            </div>
            <span className="text-sm font-semibold" style={{ color: r.type === 'earn' ? 'var(--el-success)' : 'var(--el-primary)' }}>
              {r.amount > 0 ? `+${r.amount}` : r.amount}
            </span>
          </div>
        ))}
      </div>
    </SubShell>
  );
}

/* ─── Daily check-in ─────────────────────────────────────── */
function DailyCheckin({ onBack }: { onBack: () => void }) {
  const [checked, setChecked] = useState(3);
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const rewards = [20, 20, 20, 30, 20, 20, 50];

  return (
    <SubShell eyebrow="Rewards" title="Daily check-in" onBack={onBack}>
      <p className="text-sm mb-5" style={{ color: 'var(--el-muted)' }}>Check in daily to earn bonus coins. Day 7 gives 50 coins!</p>
      <div className="grid grid-cols-7 gap-1.5 mb-6">
        {days.map((d, i) => {
          const done = i < checked;
          const today = i === checked;
          return (
            <button
              key={d}
              onClick={() => today && setChecked(c => c + 1)}
              className="flex flex-col items-center py-2.5 rounded-[13px] gap-1 transition-all"
              style={{
                background: done ? 'var(--el-primary)' : today ? 'var(--el-primary-soft)' : 'var(--el-surface)',
                border: today ? '2px solid var(--el-primary)' : '2px solid transparent',
              }}
            >
              <span className="text-[9px] font-medium" style={{ color: done ? 'var(--el-on-primary)' : today ? 'var(--el-primary-ink)' : 'var(--el-muted)' }}>{d}</span>
              {done ? (
                <Check className="w-4 h-4" style={{ color: 'var(--el-on-primary)' } as React.CSSProperties} />
              ) : (
                <Coins className="w-4 h-4" style={{ color: today ? 'var(--el-primary)' : 'var(--el-faint)' } as React.CSSProperties} />
              )}
              <span className="text-[9px] font-bold" style={{ color: done ? 'var(--el-on-primary)' : today ? 'var(--el-gold)' : 'var(--el-faint)' }}>+{rewards[i]}</span>
            </button>
          );
        })}
      </div>
      <button
        onClick={() => setChecked(c => Math.min(7, c + 1))}
        className="w-full rounded-[13px] py-3.5 font-medium transition-all active:opacity-80"
        style={{ background: checked < 7 ? 'var(--el-primary)' : 'var(--el-surface-3)', color: checked < 7 ? 'var(--el-on-primary)' : 'var(--el-muted)' }}
        disabled={checked >= 7}
      >
        {checked >= 7 ? 'Come back tomorrow' : `Check in · +${rewards[checked]} coins`}
      </button>
    </SubShell>
  );
}

/* ─── Messages ───────────────────────────────────────────── */
function Messages({ onBack }: { onBack: () => void }) {
  const msgs = [
    { title: 'Welcome to likenovel! 🎉', body: 'You\'ve earned 100 welcome coins. Start reading now!', time: 'Today', unread: true },
    { title: 'New chapters available', body: 'Claimed by the Moon has 5 new chapters. Don\'t miss out!', time: 'Yesterday', unread: true },
    { title: 'Daily reward reminder', body: 'You haven\'t checked in today. Claim your 20 coins!', time: 'Jun 7', unread: true },
    { title: 'Your coins are running low', body: 'Top up to keep reading without interruptions.', time: 'Jun 6', unread: false },
  ];
  return (
    <SubShell eyebrow="Inbox" title="Messages" onBack={onBack}>
      <div className="flex flex-col gap-2 mt-2">
        {msgs.map((m, i) => (
          <div key={i} className="px-4 py-3.5 rounded-[18px] relative" style={{ background: 'var(--el-surface)' }}>
            {m.unread && <div className="absolute top-4 left-3 w-2 h-2 rounded-full" style={{ background: 'var(--el-primary)' }} />}
            <p className="text-sm font-semibold" style={{ color: 'var(--el-ink)' }}>{m.title}</p>
            <p className="text-xs mt-1" style={{ color: 'var(--el-muted)' }}>{m.body}</p>
            <p className="text-xs mt-1.5" style={{ color: 'var(--el-faint)' }}>{m.time}</p>
          </div>
        ))}
      </div>
    </SubShell>
  );
}

/* ─── Settings ───────────────────────────────────────────── */
function SettingsPage({ onBack, onNav }: { onBack: () => void; onNav: (k: string) => void }) {
  const items = [
    { key: 'notifications', label: 'Notifications' },
    { key: 'language', label: 'Language' },
    { key: 'push-management', label: 'Push management' },
    { key: 'privacy', label: 'Privacy & data' },
  ];
  return (
    <SubShell eyebrow="Account" title="Settings" onBack={onBack}>
      <div className="rounded-[18px] overflow-hidden mt-2" style={{ border: '1px solid var(--el-line)' }}>
        {items.map((item, i) => (
          <button
            key={item.key}
            onClick={() => onNav(item.key)}
            className="w-full flex items-center justify-between px-4 py-3.5 text-left transition-colors active:opacity-70"
            style={{ background: 'var(--el-surface)', borderBottom: i < items.length - 1 ? '1px solid var(--el-line)' : 'none' }}
          >
            <span className="text-sm" style={{ color: 'var(--el-ink)' }}>{item.label}</span>
            <ChevronRight className="w-4 h-4" style={{ color: 'var(--el-line)' } as React.CSSProperties} />
          </button>
        ))}
      </div>
    </SubShell>
  );
}

/* ─── Notifications ──────────────────────────────────────── */
function Notifications({ onBack }: { onBack: () => void }) {
  return (
    <SubShell eyebrow="Settings" title="Notifications" onBack={onBack}>
      <div className="mt-2">
        <p className="text-xs uppercase tracking-widest font-medium mb-2 px-1" style={{ color: 'var(--el-muted)' }}>Reading</p>
        <ToggleRow label="New chapter alerts" defaultOn={true} />
        <ToggleRow label="Reading reminders" defaultOn={true} />
        <ToggleRow label="Unlock confirmations" defaultOn={false} />
        <p className="text-xs uppercase tracking-widest font-medium mb-2 mt-4 px-1" style={{ color: 'var(--el-muted)' }}>Promotions</p>
        <ToggleRow label="Coin deals & offers" defaultOn={true} />
        <ToggleRow label="New story recommendations" defaultOn={true} />
      </div>
    </SubShell>
  );
}

/* ─── Language ───────────────────────────────────────────── */
function Language({ onBack }: { onBack: () => void }) {
  const [lang, setLang] = useState('English');
  const langs = ['English', 'Spanish', 'French', 'German', 'Portuguese', 'Italian'];
  return (
    <SubShell eyebrow="Settings" title="Language" onBack={onBack}>
      <div className="mt-2">
        {langs.map(l => <RadioRow key={l} label={l} selected={lang === l} onSelect={() => setLang(l)} />)}
      </div>
    </SubShell>
  );
}

/* ─── Delete account ─────────────────────────────────────── */
function DeleteAccount({ onBack }: { onBack: () => void }) {
  return (
    <SubShell eyebrow="Account" title="Delete account" onBack={onBack}>
      <div className="flex flex-col items-center pt-6 text-center">
        <div className="w-16 h-16 rounded-full flex items-center justify-center mb-4" style={{ background: 'oklch(0.95 0.03 16)' }}>
          <Trash2 className="w-8 h-8" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />
        </div>
        <h2 className="text-xl font-semibold mb-2" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Delete your account?</h2>
        <p className="text-sm leading-relaxed mb-6" style={{ color: 'var(--el-muted)' }}>
          This will permanently delete your account, reading history, and any remaining coin balance. This action cannot be undone.
        </p>
        <div className="w-full flex flex-col gap-3">
          <button
            className="w-full py-3.5 rounded-[13px] font-medium transition-all active:opacity-80"
            style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)' }}
          >
            Yes, delete my account
          </button>
          <button
            onClick={onBack}
            className="w-full py-3.5 rounded-[13px] font-medium border transition-all active:opacity-80"
            style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)' }}
          >
            Cancel
          </button>
        </div>
      </div>
    </SubShell>
  );
}

/* ─── Generic list page ──────────────────────────────────── */
function GenericList({ eyebrow, title, onBack }: { eyebrow: string; title: string; onBack: () => void }) {
  return (
    <SubShell eyebrow={eyebrow} title={title} onBack={onBack}>
      <div className="flex flex-col items-center pt-10 text-center">
        <p className="text-sm" style={{ color: 'var(--el-muted)' }}>No items yet.</p>
      </div>
    </SubShell>
  );
}

/* ─── Search Results ─────────────────────────────────────── */
function SearchResults({ onBack, onBook }: { onBack: () => void; onBook: (b: any) => void }) {
  const [query, setQuery] = useState('');
  const results = query.length > 1
    ? BOOKS.filter(b => b.title.toLowerCase().includes(query.toLowerCase()) || b.author.toLowerCase().includes(query.toLowerCase()) || b.tropes.some(t => t.toLowerCase().includes(query.toLowerCase())))
    : BOOKS;

  return (
    <div className="flex flex-col h-full" style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}>
      <div className="px-4 pt-12 pb-3 flex-shrink-0">
        <div className="flex items-center gap-2">
          <button
            onClick={onBack}
            className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
            style={{ background: 'var(--el-surface-2)' }}
          >
            <ChevronLeft className="w-5 h-5" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
          </button>
          <input
            autoFocus
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Search titles, authors, tropes"
            className="flex-1 px-4 py-2.5 rounded-[13px] text-sm outline-none"
            style={{ background: 'var(--el-surface-2)', color: 'var(--el-ink)' }}
          />
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5" style={{ scrollbarWidth: 'none' }}>
        <p className="text-xs mb-3" style={{ color: 'var(--el-muted)' }}>{results.length} results</p>
        <div className="flex flex-col gap-2">
          {results.map(book => (
            <button
              key={book.id}
              onClick={() => onBook(book)}
              className="flex items-center gap-3 p-3 rounded-[18px] text-left active:opacity-80"
              style={{ background: 'var(--el-surface)' }}
            >
              <Cover genre={book.genre} title={book.title} author={book.author} size="sm" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold truncate" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>{book.title}</p>
                <p className="text-xs" style={{ color: 'var(--el-muted)' }}>{book.author}</p>
                <div className="flex flex-wrap gap-1 mt-1">
                  {book.tropes.slice(0, 2).map(t => (
                    <span key={t} className="text-[9px] px-1.5 py-0.5 rounded-full" style={{ background: 'var(--el-primary-soft)', color: 'var(--el-primary-ink)' }}>{t}</span>
                  ))}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ─── Main export ──────────────────────────────────────────── */
export function SubPage({ pageKey, onBack, onBook, onTopUp, coins }: SubPageProps) {
  const [nestedKey, setNestedKey] = useState<string | null>(null);

  if (nestedKey) {
    return <SubPage pageKey={nestedKey} onBack={() => setNestedKey(null)} onBook={onBook} onTopUp={onTopUp} coins={coins} />;
  }

  switch (pageKey) {
    case 'transactions':
    case 'wallet-history':
      return <Transactions onBack={onBack} />;
    case 'daily-checkin':
      return <DailyCheckin onBack={onBack} />;
    case 'messages':
    case 'message-center':
      return <Messages onBack={onBack} />;
    case 'settings':
      return <SettingsPage onBack={onBack} onNav={setNestedKey} />;
    case 'notifications':
      return <Notifications onBack={onBack} />;
    case 'language':
      return <Language onBack={onBack} />;
    case 'push-management':
      return <GenericList eyebrow="Compliance" title="Push management" onBack={onBack} />;
    case 'privacy':
      return <GenericList eyebrow="Settings" title="Privacy & data" onBack={onBack} />;
    case 'delete-account':
      return <DeleteAccount onBack={onBack} />;
    case 'search':
      return <SearchResults onBack={onBack} onBook={onBook!} />;
    case 'purchase-history':
      return <GenericList eyebrow="Wallet" title="Purchases" onBack={onBack} />;
    default:
      return <GenericList eyebrow="likenovel" title={pageKey} onBack={onBack} />;
  }
}
