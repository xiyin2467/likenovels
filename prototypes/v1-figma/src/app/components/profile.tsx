import * as React from "react";
import {
  Settings, Wallet, Lock, Bell, Shield, Trash2, Mail,
  ChevronRight, Languages, Coins, SlidersHorizontal,
} from './icons';

interface ProfileProps {
  coins: number;
  onNav: (key: string) => void;
  onSettings: () => void;
}

const MENU = [
  { icon: Wallet, key: 'purchase-history', label: 'Wallet & purchases', value: '1,240', danger: false },
  { icon: Lock, key: 'transactions', label: 'Transactions', value: '', danger: false },
  { icon: Bell, key: 'messages', label: 'Messages', value: '3', unread: true, danger: false },
  { icon: SlidersHorizontal, key: 'notifications', label: 'Notifications', value: 'On', danger: false },
  { icon: Languages, key: 'language', label: 'Language', value: 'English', danger: false },
  { icon: Shield, key: 'push-management', label: 'Push management', value: '', danger: false },
  { icon: Lock, key: 'privacy', label: 'Privacy & data', value: '', danger: false },
  { icon: Trash2, key: 'delete-account', label: 'Delete account', value: '', danger: true },
];

export function Profile({ coins, onNav, onSettings }: ProfileProps) {
  return (
    <div
      className="flex flex-col h-full overflow-hidden"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      <div className="px-5 pt-12 pb-4 flex items-start justify-between flex-shrink-0">
        <div>
          <p className="text-[10px] font-semibold uppercase tracking-[0.12em] mb-0.5" style={{ color: 'var(--el-muted)' }}>Account</p>
          <h1 className="text-[26px] font-semibold leading-none" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Me</h1>
        </div>
        <button
          onClick={onSettings}
          className="w-10 h-10 rounded-full flex items-center justify-center mt-1.5 transition-all active:scale-90"
          style={{ background: 'var(--el-surface-2)', border: '1px solid var(--el-line)' }}
        >
          <Settings className="w-5 h-5" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto px-5" style={{ scrollbarWidth: 'none' }}>
        {/* profile card */}
        <div
          className="rounded-[22px] p-4 mb-4 flex items-center gap-4"
          style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)' }}
        >
          <div
            className="w-14 h-14 rounded-full flex items-center justify-center text-[22px] font-semibold flex-shrink-0"
            style={{ background: 'var(--el-primary-soft)', color: 'var(--el-primary)', fontFamily: 'Newsreader, serif' }}
          >
            A
          </div>
          <div className="flex-1">
            <p className="font-semibold text-[15px]" style={{ color: 'var(--el-ink)' }}>Amelia R.</p>
            <div className="flex items-center gap-2 mt-0.5">
              <span className="text-[11px] px-2 py-0.5 rounded-full font-medium" style={{ background: 'var(--el-primary-soft)', color: 'var(--el-primary-ink)' }}>Level 7</span>
              <span className="text-[11px]" style={{ color: 'var(--el-muted)' }}>🔥 14 day streak</span>
            </div>
          </div>
          <button
            className="text-[12px] font-semibold px-3 py-1.5 rounded-full border transition-all active:scale-90"
            style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)' }}
          >
            Edit
          </button>
        </div>

        {/* stats row */}
        <div className="grid grid-cols-3 gap-2 mb-5">
          {[
            { label: 'Books', value: '12' },
            { label: 'Chapters', value: '847' },
            { label: 'Streak', value: '14d' },
          ].map(s => (
            <div key={s.label} className="flex flex-col items-center py-3.5 rounded-[16px]" style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)' }}>
              <p className="text-[22px] font-bold leading-tight" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>{s.value}</p>
              <p className="text-[11px] mt-0.5" style={{ color: 'var(--el-muted)' }}>{s.label}</p>
            </div>
          ))}
        </div>

        {/* coin balance summary */}
        <button
          onClick={() => onNav('wallet')}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-[16px] mb-4 text-left transition-all active:scale-[0.99]"
          style={{ background: 'var(--el-primary-soft)', border: '1.5px solid oklch(0.88 0.035 18)' }}
        >
          <Coins className="w-5 h-5" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />
          <div className="flex-1">
            <p className="text-[12px]" style={{ color: 'var(--el-muted)' }}>Coin balance</p>
            <p className="text-[15px] font-bold tabular-nums" style={{ color: 'var(--el-ink)' }}>{coins.toLocaleString()} coins</p>
          </div>
          <ChevronRight className="w-4 h-4" style={{ color: 'var(--el-primary-ink)' } as React.CSSProperties} />
        </button>

        {/* menu */}
        <div className="rounded-[18px] overflow-hidden mb-8" style={{ border: '1px solid var(--el-line)' }}>
          {MENU.map((item, i) => {
            const Icon = item.icon;
            return (
              <button
                key={item.key}
                onClick={() => onNav(item.key)}
                className="w-full flex items-center gap-3 px-4 py-3.5 text-left transition-all active:opacity-70"
                style={{
                  background: 'var(--el-surface)',
                  borderBottom: i < MENU.length - 1 ? '1px solid var(--el-line)' : 'none',
                }}
              >
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ background: item.danger ? 'oklch(0.95 0.03 16)' : 'var(--el-surface-2)' }}
                >
                  <Icon className="w-4 h-4" style={{ color: item.danger ? 'var(--el-primary)' : 'var(--el-muted)' } as React.CSSProperties} />
                </div>

                <span className="flex-1 text-[13px] font-medium" style={{ color: item.danger ? 'var(--el-primary)' : 'var(--el-ink)' }}>
                  {item.label}
                </span>

                {item.value && !item.unread && (
                  <span className="text-[12px] mr-1" style={{ color: 'var(--el-muted)' }}>{item.value}</span>
                )}
                {item.unread && item.value && (
                  <span
                    className="text-[11px] font-bold px-1.5 py-0.5 rounded-full mr-1"
                    style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)', minWidth: '20px', textAlign: 'center' }}
                  >
                    {item.value}
                  </span>
                )}

                {!item.danger && (
                  <ChevronRight className="w-4 h-4 flex-shrink-0 opacity-30" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
