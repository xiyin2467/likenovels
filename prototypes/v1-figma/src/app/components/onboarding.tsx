import * as React from "react";
import { useState, useEffect } from 'react';
// motion available if needed for future animations
import { GoogleIcon, FacebookIcon, SparkIcon } from './icons';
import { Cover } from './cover';
import { BOOKS } from '../data';

interface OnboardingProps {
  onContinue: () => void;
}

const HERO = [BOOKS[0], BOOKS[3], BOOKS[4], BOOKS[1]];

export function Onboarding({ onContinue }: OnboardingProps) {
  const [active, setActive] = useState(1);

  /* auto-rotate */
  useEffect(() => {
    const t = setInterval(() => setActive(a => (a + 1) % HERO.length), 3000);
    return () => clearInterval(t);
  }, []);

  return (
    <div
      className="flex flex-col h-full overflow-hidden relative"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      {/* book carousel */}
      <div className="flex-1 relative overflow-hidden">
        {/* bg glow from active book */}
        <div
          className="absolute inset-0 pointer-events-none transition-opacity duration-700"
          style={{
            background: `radial-gradient(ellipse 80% 60% at 50% 20%, ${
              active === 0 ? 'rgba(30,60,120,0.18)' :
              active === 1 ? 'rgba(140,20,60,0.15)' :
              active === 2 ? 'rgba(100,40,200,0.15)' :
              'rgba(40,40,40,0.18)'
            } 0%, transparent 70%)`,
          }}
        />
        {/* fade at bottom */}
        <div
          className="absolute bottom-0 left-0 right-0 h-32 z-10 pointer-events-none"
          style={{ background: 'linear-gradient(to bottom, transparent, var(--el-bg))' }}
        />

        {/* 3-book fan */}
        <div className="absolute inset-0 flex items-center justify-center" style={{ top: '32px' }}>
          {HERO.map((book, i) => {
            const diff = i - active;
            const isCenter = diff === 0;
            const isLeft = diff === -1 || (active === 0 && i === HERO.length - 1);
            const isRight = diff === 1 || (active === HERO.length - 1 && i === 0);
            const visible = isCenter || isLeft || isRight;

            return (
              <div
                key={book.id}
                className="absolute transition-all duration-500"
                style={{
                  transform: isCenter
                    ? 'translateX(0) scale(1.08) rotate(0deg)'
                    : isLeft
                    ? 'translateX(-120px) scale(0.82) rotate(-6deg)'
                    : isRight
                    ? 'translateX(120px) scale(0.82) rotate(6deg)'
                    : 'translateX(0) scale(0.7)',
                  opacity: isCenter ? 1 : visible ? 0.55 : 0,
                  zIndex: isCenter ? 3 : 1,
                  pointerEvents: visible ? 'auto' : 'none',
                }}
                onClick={() => setActive(i)}
              >
                <Cover genre={book.genre} title={book.title} author={book.author} badge={book.badge} size="xl" />
              </div>
            );
          })}
        </div>

        {/* dots */}
        <div className="absolute bottom-8 left-0 right-0 flex justify-center gap-1.5 z-20">
          {HERO.map((_, i) => (
            <button
              key={i}
              onClick={() => setActive(i)}
              className="rounded-full transition-all duration-300"
              style={{
                width: i === active ? '20px' : '6px',
                height: '6px',
                background: i === active ? 'var(--el-primary)' : 'var(--el-line)',
              }}
            />
          ))}
        </div>
      </div>

      {/* brand + cta */}
      <div className="px-6 pb-8 pt-2 z-20 relative flex-shrink-0">
        <div className="flex items-center gap-2 mb-1.5">
          <SparkIcon className="w-5 h-5" style={{ color: 'var(--el-primary)' } as React.CSSProperties} />
          <h1 className="text-[28px] font-semibold tracking-tight leading-none" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
            likenovel
          </h1>
        </div>
        <p className="text-[17px] font-medium mb-1" style={{ color: 'var(--el-ink)', fontFamily: 'Newsreader, serif', fontStyle: 'italic' }}>
          Romance you won't put down.
        </p>
        <p className="text-[13px] mb-5 leading-relaxed" style={{ color: 'var(--el-muted)' }}>
          First 3 chapters free on every story. Unlock more with coins.
        </p>

        <div className="flex flex-col gap-2.5">
          <button
            onClick={onContinue}
            className="w-full flex items-center justify-center gap-3 rounded-[13px] py-3.5 font-semibold text-[15px] transition-all active:scale-[0.98] active:opacity-90 shadow-sm"
            style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)', boxShadow: '0 4px 16px oklch(0.52 0.158 16 / 0.35)' }}
          >
            <GoogleIcon className="w-5 h-5" />
            Continue with Google
          </button>

          <button
            onClick={onContinue}
            className="w-full flex items-center justify-center gap-3 rounded-[13px] py-3.5 font-semibold text-[15px] border transition-all active:scale-[0.98]"
            style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)', background: 'var(--el-surface)' }}
          >
            <FacebookIcon className="w-5 h-5" />
            Continue with Facebook
          </button>

          <button
            onClick={onContinue}
            className="w-full flex items-center justify-center rounded-[13px] py-3.5 font-semibold text-[15px] border transition-all active:scale-[0.98]"
            style={{ borderColor: 'var(--el-line)', color: 'var(--el-ink)', background: 'var(--el-surface)' }}
          >
            Continue with email
          </button>

          <button
            onClick={onContinue}
            className="w-full text-center py-2 text-[13px] font-medium transition-opacity active:opacity-60"
            style={{ color: 'var(--el-primary-ink)' }}
          >
            Browse as guest
          </button>
        </div>

        <p className="text-center text-[11px] mt-3 leading-relaxed" style={{ color: 'var(--el-faint)' }}>
          By continuing you agree to our{' '}
          <button className="underline" style={{ color: 'var(--el-primary-ink)' }}>Terms</button>{' '}
          and{' '}
          <button className="underline" style={{ color: 'var(--el-primary-ink)' }}>Privacy Policy</button>
        </p>
      </div>
    </div>
  );
}
