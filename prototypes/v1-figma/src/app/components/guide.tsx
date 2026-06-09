import * as React from "react";
import { useState } from 'react';
import { ChevronLeft } from './icons';
import { TASTE_TAGS } from '../data';

interface GuideProps {
  onBack: () => void;
  onContinue: () => void;
}

export function Guide({ onBack, onContinue }: GuideProps) {
  const [selected, setSelected] = useState<Set<string>>(new Set());

  function toggle(tag: string) {
    setSelected(prev => {
      const next = new Set(prev);
      next.has(tag) ? next.delete(tag) : next.add(tag);
      return next;
    });
  }

  const count = selected.size;

  return (
    <div
      className="flex flex-col h-full"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      {/* top bar */}
      <div className="flex items-center gap-3 px-4 pt-12 pb-2 flex-shrink-0">
        <button
          onClick={onBack}
          className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 transition-all active:scale-90"
          style={{ background: 'var(--el-surface-2)' }}
        >
          <ChevronLeft className="w-5 h-5" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
        </button>
        {/* progress */}
        <div className="flex-1 h-1 rounded-full overflow-hidden" style={{ background: 'var(--el-surface-3)' }}>
          <div
            className="h-full rounded-full transition-all duration-500"
            style={{ width: count === 0 ? '8%' : `${Math.min(8 + (count / TASTE_TAGS.length) * 92, 100)}%`, background: 'var(--el-primary)' }}
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pt-4" style={{ scrollbarWidth: 'none' }}>
        <h1 className="text-[26px] font-semibold mb-1 leading-tight" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
          What do you love?
        </h1>
        <p className="text-[13px] mb-6 leading-relaxed" style={{ color: 'var(--el-muted)' }}>
          Pick your favorites — we'll fill your feed with stories made for you.
        </p>

        <div className="flex flex-wrap gap-2.5">
          {TASTE_TAGS.map(tag => {
            const isSel = selected.has(tag);
            return (
              <button
                key={tag}
                onClick={() => toggle(tag)}
                className="px-4 py-2.5 rounded-full text-[13px] font-semibold border transition-all active:scale-95"
                style={{
                  background: isSel ? 'var(--el-primary)' : 'var(--el-surface)',
                  color: isSel ? 'var(--el-on-primary)' : 'var(--el-ink)',
                  borderColor: isSel ? 'var(--el-primary)' : 'var(--el-line)',
                  boxShadow: isSel ? '0 4px 12px oklch(0.52 0.158 16 / 0.25)' : 'none',
                }}
              >
                {tag}
              </button>
            );
          })}
        </div>

        <div className="h-32" />
      </div>

      {/* sticky CTA */}
      <div
        className="px-5 pb-10 pt-6 flex-shrink-0"
        style={{ background: 'linear-gradient(to top, var(--el-bg) 80%, transparent)' }}
      >
        <button
          onClick={onContinue}
          className="w-full rounded-[13px] py-3.5 font-semibold text-[15px] transition-all active:scale-[0.98]"
          style={{
            background: count > 0 ? 'var(--el-primary)' : 'var(--el-surface-3)',
            color: count > 0 ? 'var(--el-on-primary)' : 'var(--el-muted)',
            boxShadow: count > 0 ? '0 4px 16px oklch(0.52 0.158 16 / 0.3)' : 'none',
          }}
        >
          {count > 0 ? `Continue (${count} selected)` : 'Skip for now'}
        </button>
      </div>
    </div>
  );
}
