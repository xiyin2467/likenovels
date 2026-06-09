import * as React from "react";
import { Coins, Gift, Play, ChevronRight } from './icons';
import { RECHARGE_PACKAGES } from '../data';

interface WalletProps {
  coins: number;
  onTopUp: () => void;
  onCheckin: () => void;
}

export function Wallet({ coins, onTopUp, onCheckin }: WalletProps) {
  const isLow = coins < 100;

  return (
    <div
      className="flex flex-col h-full overflow-hidden"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      <div className="px-5 pt-12 pb-4 flex-shrink-0">
        <p className="text-[10px] font-semibold uppercase tracking-[0.12em] mb-0.5" style={{ color: 'var(--el-muted)' }}>Wallet</p>
        <h1 className="text-[26px] font-semibold leading-none" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
          Coins & rewards
        </h1>
      </div>

      <div className="flex-1 overflow-y-auto px-5" style={{ scrollbarWidth: 'none' }}>
        {/* balance card */}
        <div
          className="rounded-[22px] p-5 mb-5 relative overflow-hidden"
          style={{
            background: 'linear-gradient(135deg, oklch(0.50 0.160 16) 0%, oklch(0.42 0.145 22) 100%)',
            boxShadow: '0 12px 36px oklch(0.52 0.158 16 / 0.32)',
          }}
        >
          {/* glow orbs */}
          <div className="absolute -top-8 -right-8 w-44 h-44 rounded-full pointer-events-none" style={{ background: 'oklch(0.78 0.115 78 / 0.18)', filter: 'blur(28px)' }} />
          <div className="absolute -bottom-8 -left-8 w-32 h-32 rounded-full pointer-events-none" style={{ background: 'oklch(0.52 0.158 16 / 0.3)', filter: 'blur(24px)' }} />

          <p className="text-[11px] font-semibold uppercase tracking-[0.12em] mb-1.5 relative" style={{ color: 'oklch(0.99 0.01 80 / 0.6)' }}>
            Available balance
          </p>
          <div className="flex items-end gap-2 mb-1 relative">
            <Coins className="w-8 h-8 mb-0.5" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />
            <span className="text-[42px] font-bold leading-none tabular-nums" style={{ color: 'var(--el-on-primary)', fontFamily: 'Newsreader, serif' }}>
              {coins.toLocaleString()}
            </span>
          </div>
          <p className="text-[12px] mb-5 relative" style={{ color: 'oklch(0.99 0.01 80 / 0.65)' }}>
            About {Math.floor(coins / 38)} standard chapters
          </p>

          <button
            onClick={onTopUp}
            className="px-5 py-2.5 rounded-full font-semibold text-[13px] transition-all active:scale-[0.97] relative"
            style={{
              background: 'oklch(0.99 0.01 80)',
              color: 'var(--el-primary)',
              boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
            }}
          >
            {isLow ? '⚡ Top up now' : 'Top up coins'}
          </button>
        </div>

        {/* rewards */}
        <h2 className="text-[15px] font-semibold mb-3" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Daily rewards</h2>
        <div className="grid grid-cols-2 gap-3 mb-6">
          <RewardCard
            icon={<Gift className="w-6 h-6" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />}
            iconBg="var(--el-primary-soft)"
            title="Daily check-in"
            cta="+20 coins"
            ctaColor="var(--el-primary-ink)"
            onClick={onCheckin}
          />
          <RewardCard
            icon={<Play className="w-6 h-6" style={{ color: 'var(--el-gold)' } as React.CSSProperties} />}
            iconBg="oklch(0.95 0.04 80)"
            title="Watch & earn"
            cta="+12 coins"
            ctaColor="oklch(0.60 0.100 78)"
            onClick={() => {}}
          />
        </div>

        {/* packages */}
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-[15px] font-semibold" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>Recharge packages</h2>
          <button className="flex items-center gap-0.5 text-[12px] font-medium" style={{ color: 'var(--el-primary-ink)' }}>
            More <ChevronRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="flex flex-col gap-2 mb-8">
          {RECHARGE_PACKAGES.slice(1, 3).map(p => (
            <button
              key={p.id}
              onClick={onTopUp}
              className="flex items-center justify-between p-4 rounded-[18px] border text-left transition-all active:scale-[0.99] relative"
              style={{
                background: 'var(--el-surface)',
                borderColor: p.tag === 'Best value' ? 'var(--el-primary)' : 'var(--el-line)',
              }}
            >
              {p.tag === 'Best value' && (
                <span className="absolute -top-2.5 right-4 text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)' }}>
                  Best value
                </span>
              )}
              <div>
                <p className="font-semibold text-[14px]" style={{ color: 'var(--el-ink)' }}>{p.coins.toLocaleString()} coins</p>
                <p className="text-[11px] mt-0.5 font-medium" style={{ color: p.bonus > 0 ? 'var(--el-success)' : 'var(--el-muted)' }}>{p.bonusLabel}</p>
              </div>
              <p className="font-bold text-[16px]" style={{ color: 'var(--el-ink)' }}>{p.price}</p>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

function RewardCard({ icon, iconBg, title, cta, ctaColor, onClick }: {
  icon: React.ReactNode; iconBg: string; title: string; cta: string; ctaColor: string; onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="flex flex-col items-start p-4 rounded-[18px] border text-left transition-all active:scale-[0.97]"
      style={{ background: 'var(--el-surface)', borderColor: 'var(--el-line)' }}
    >
      <div className="w-11 h-11 rounded-full flex items-center justify-center mb-3" style={{ background: iconBg }}>
        {icon}
      </div>
      <p className="text-[13px] font-semibold mb-1" style={{ color: 'var(--el-ink)' }}>{title}</p>
      <p className="text-[12px] font-bold" style={{ color: ctaColor }}>{cta}</p>
    </button>
  );
}
