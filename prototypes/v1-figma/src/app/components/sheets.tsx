import * as React from "react";
import { useState } from 'react';
import { Lock, Play, Clock, Coins, X, Check } from './icons';
import type { Book } from '../data';
import { RECHARGE_PACKAGES } from '../data';

/* ─── Shared sheet chrome ────────────────────────────────── */
function SheetChrome({ onClose, children }: { onClose: () => void; children: React.ReactNode }) {
  return (
    <div className="w-full rounded-t-[26px] pb-safe" style={{ background: 'var(--el-surface)' }}>
      {/* grab handle */}
      <div className="flex justify-center pt-3 pb-1">
        <div className="w-10 h-1 rounded-full" style={{ background: 'var(--el-line)' }} />
      </div>
      {children}
    </div>
  );
}

/* ─── Paywall Sheet ─────────────────────────────────────── */
interface PaywallProps {
  book: Book;
  chapterId?: number;
  coins: number;
  onClose: () => void;
  onUnlock: () => void;
  onTopUp: () => void;
}

export function PaywallSheet({ book, chapterId = 4, coins, onClose, onUnlock, onTopUp }: PaywallProps) {
  const COST = 38;
  const canAfford = coins >= COST;
  const [adLoading, setAdLoading] = useState(false);

  function handleAd() {
    setAdLoading(true);
    setTimeout(() => { setAdLoading(false); onUnlock(); }, 2000);
  }

  return (
    <SheetChrome onClose={onClose}>
      <div className="px-5 pt-2 pb-10">
        <div className="flex items-start justify-between mb-1">
          <div>
            <p className="text-[10px] font-semibold uppercase tracking-[0.1em] mb-0.5" style={{ color: 'var(--el-muted)' }}>Locked</p>
            <h2 className="text-[20px] font-semibold leading-tight" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
              Unlock Chapter {chapterId}
            </h2>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full flex items-center justify-center mt-0.5 flex-shrink-0"
            style={{ background: 'var(--el-surface-2)' }}
          >
            <X className="w-4 h-4" style={{ color: 'var(--el-muted)' } as React.CSSProperties} />
          </button>
        </div>
        <p className="text-[13px] mb-5" style={{ color: 'var(--el-muted)' }}>
          How would you like to continue <span className="font-medium" style={{ color: 'var(--el-ink)' }}>{book.title}</span>?
        </p>

        <div className="flex flex-col gap-2.5 mb-5">
          {/* Coins option */}
          <button
            onClick={() => canAfford && onUnlock()}
            className="flex items-center gap-4 p-4 rounded-[18px] border-2 text-left transition-all active:scale-[0.99]"
            style={{
              background: canAfford ? 'var(--el-primary-soft)' : 'var(--el-surface-2)',
              borderColor: canAfford ? 'var(--el-primary)' : 'transparent',
              boxShadow: canAfford ? '0 0 0 1px oklch(0.85 0.04 18)' : 'none',
            }}
          >
            <div className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 shadow-sm" style={{ background: 'var(--el-primary)' }}>
              <Coins className="w-6 h-6" style={{ color: 'var(--el-on-primary)' } as React.CSSProperties} />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-[14px]" style={{ color: 'var(--el-ink)' }}>Unlock with {COST} coins</p>
              <p className="text-[12px] mt-0.5 font-medium" style={{ color: canAfford ? 'var(--el-success)' : 'var(--el-primary)' }}>
                {canAfford ? `✓ You have ${coins} coins` : `Need ${COST - coins} more coins`}
              </p>
            </div>
            {canAfford && (
              <div className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0" style={{ background: 'var(--el-primary)' }}>
                <Check className="w-3.5 h-3.5" style={{ color: 'var(--el-on-primary)' } as React.CSSProperties} />
              </div>
            )}
          </button>

          {/* Ad option */}
          <button
            onClick={handleAd}
            disabled={adLoading}
            className="flex items-center gap-4 p-4 rounded-[18px] border text-left transition-all active:scale-[0.99] disabled:opacity-70"
            style={{ background: 'var(--el-surface)', borderColor: 'var(--el-line)' }}
          >
            <div className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0" style={{ background: 'var(--el-surface-2)' }}>
              <Play className="w-6 h-6" style={{ color: adLoading ? 'var(--el-muted)' : 'var(--el-ink)' } as React.CSSProperties} />
            </div>
            <div>
              <p className="font-semibold text-[14px]" style={{ color: 'var(--el-ink)' }}>
                {adLoading ? 'Loading ad…' : 'Watch a short ad'}
              </p>
              <p className="text-[12px] mt-0.5" style={{ color: 'var(--el-muted)' }}>About 30 seconds, free</p>
            </div>
          </button>

          {/* Wait option */}
          <button
            className="flex items-center gap-4 p-4 rounded-[18px] border text-left transition-all active:scale-[0.99]"
            style={{ background: 'var(--el-surface)', borderColor: 'var(--el-line)' }}
          >
            <div className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0" style={{ background: 'var(--el-surface-2)' }}>
              <Clock className="w-6 h-6" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
            </div>
            <div>
              <p className="font-semibold text-[14px]" style={{ color: 'var(--el-ink)' }}>Wait to unlock</p>
              <p className="text-[12px] mt-0.5 font-mono tracking-tight" style={{ color: 'var(--el-muted)' }}>Free in 03:58:21</p>
            </div>
          </button>
        </div>

        {!canAfford && (
          <button
            onClick={onTopUp}
            className="w-full text-center text-[13px] font-medium py-1"
            style={{ color: 'var(--el-primary-ink)' }}
          >
            Need more coins?{' '}
            <span className="underline font-semibold">Top up →</span>
          </button>
        )}
      </div>
    </SheetChrome>
  );
}

/* ─── Recharge Sheet ─────────────────────────────────────── */
interface RechargeProps {
  coins: number;
  onClose: () => void;
  onPurchase: (added: number) => void;
}

export function RechargeSheet({ coins, onClose, onPurchase }: RechargeProps) {
  const [selected, setSelected] = useState('p3');
  const pkg = RECHARGE_PACKAGES.find(p => p.id === selected)!;

  return (
    <SheetChrome onClose={onClose}>
      <div className="px-5 pt-2 pb-10">
        <div className="flex items-start justify-between mb-1">
          <div>
            <h2 className="text-[20px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
              Top up coins
            </h2>
            <p className="text-[11px] mt-0.5 flex items-center gap-1" style={{ color: 'var(--el-muted)' }}>
              🔒 Secure checkout via Google Play
            </p>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-full flex items-center justify-center mt-0.5" style={{ background: 'var(--el-surface-2)' }}>
            <X className="w-4 h-4" style={{ color: 'var(--el-muted)' } as React.CSSProperties} />
          </button>
        </div>

        {/* balance pill */}
        <div className="flex items-center gap-2 my-3 px-3 py-2 rounded-[10px] w-fit" style={{ background: 'var(--el-surface-2)' }}>
          <Coins className="w-4 h-4" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />
          <span className="text-[12px]" style={{ color: 'var(--el-muted)' }}>Balance:</span>
          <span className="text-[12px] font-semibold tabular-nums" style={{ color: 'var(--el-ink)' }}>{coins.toLocaleString()} coins</span>
        </div>

        <div className="flex flex-col gap-2 mb-5">
          {RECHARGE_PACKAGES.map(p => {
            const isSel = selected === p.id;
            const isBest = p.tag === 'Best value';
            return (
              <button
                key={p.id}
                onClick={() => setSelected(p.id)}
                className="flex items-center justify-between p-4 rounded-[18px] border-2 text-left transition-all active:scale-[0.99] relative"
                style={{
                  background: isSel ? 'var(--el-primary-soft)' : 'var(--el-surface)',
                  borderColor: isSel ? 'var(--el-primary)' : 'var(--el-line)',
                }}
              >
                {isBest && (
                  <span className="absolute -top-2.5 right-4 text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)' }}>
                    Best value
                  </span>
                )}
                <div>
                  <p className="font-semibold text-[14px]" style={{ color: 'var(--el-ink)' }}>
                    {p.coins.toLocaleString()} coins
                  </p>
                  <p className="text-[11px] mt-0.5 font-medium" style={{ color: p.bonus > 0 ? 'var(--el-success)' : 'var(--el-muted)' }}>
                    {p.bonusLabel}
                  </p>
                </div>
                <div className="text-right">
                  <p className="font-bold text-[16px]" style={{ color: isSel ? 'var(--el-primary)' : 'var(--el-ink)' }}>{p.price}</p>
                  {p.tag && p.tag !== 'Best value' && (
                    <p className="text-[10px]" style={{ color: 'var(--el-muted)' }}>{p.tag}</p>
                  )}
                </div>
              </button>
            );
          })}
        </div>

        <button
          onClick={() => { onPurchase(pkg.coins + pkg.bonus); onClose(); }}
          className="w-full rounded-[13px] py-3.5 font-semibold text-[15px] transition-all active:scale-[0.98] active:opacity-90"
          style={{
            background: 'var(--el-primary)',
            color: 'var(--el-on-primary)',
            boxShadow: '0 4px 16px oklch(0.52 0.158 16 / 0.3)',
          }}
        >
          Pay with Google Play · {pkg.price}
        </button>

        <p className="text-center text-[11px] mt-3 leading-relaxed" style={{ color: 'var(--el-faint)' }}>
          Prices localized by region. Bonus coins are non-refundable.
        </p>
      </div>
    </SheetChrome>
  );
}
