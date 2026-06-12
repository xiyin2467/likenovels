// 共享 UI 原子组件，统一品牌样式（酒红/琥珀金/暖米底）
import { useEffect } from 'react';

export function Button({ variant = 'primary', size = 'md', className = '', children, ...props }) {
  const base =
    'inline-flex items-center justify-center gap-2 font-semibold rounded-[13px] transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none';
  const sizes = {
    sm: 'text-xs px-3 py-1.5',
    md: 'text-sm px-4 py-2.5',
    lg: 'text-base px-6 py-3',
  };
  const variants = {
    primary: 'bg-primary text-on-primary hover:bg-primary-press',
    gold: 'bg-gold text-ink hover:brightness-95',
    ghost: 'text-ink hover:bg-surface-2',
    outline: 'border border-line text-ink hover:bg-surface-2 bg-surface',
    danger: 'bg-danger text-white hover:brightness-95',
    'danger-ghost': 'text-danger hover:bg-danger/10',
  };
  return (
    <button className={`${base} ${sizes[size]} ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
}

export function Card({ className = '', children, ...props }) {
  return (
    <div
      className={`bg-surface border border-line rounded-[18px] ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

export function Badge({ tone = 'neutral', children }) {
  const tones = {
    neutral: 'bg-surface-3 text-muted',
    primary: 'bg-primary-soft text-primary-ink',
    gold: 'bg-gold-soft text-[#8a6d1f]',
    success: 'bg-success/12 text-success',
    danger: 'bg-danger/10 text-danger',
    warn: 'bg-amber-100 text-amber-700',
  };
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold ${tones[tone]}`}
    >
      {children}
    </span>
  );
}

export function Input({ label, className = '', ...props }) {
  return (
    <label className="block">
      {label && <span className="mb-1.5 block text-xs font-semibold text-muted">{label}</span>}
      <input
        className={`w-full rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm text-ink placeholder:text-faint focus:border-primary focus:bg-surface focus:outline-none ${className}`}
        {...props}
      />
    </label>
  );
}

export function Textarea({ label, className = '', ...props }) {
  return (
    <label className="block">
      {label && <span className="mb-1.5 block text-xs font-semibold text-muted">{label}</span>}
      <textarea
        className={`w-full rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm text-ink placeholder:text-faint focus:border-primary focus:bg-surface focus:outline-none ${className}`}
        {...props}
      />
    </label>
  );
}

export function Select({ label, options = [], className = '', children, ...props }) {
  return (
    <label className="block">
      {label && <span className="mb-1.5 block text-xs font-semibold text-muted">{label}</span>}
      <select
        className={`w-full rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm text-ink focus:border-primary focus:bg-surface focus:outline-none ${className}`}
        {...props}
      >
        {children ||
          options.map((o) => (
            <option key={o.value ?? o} value={o.value ?? o}>
              {o.label ?? o}
            </option>
          ))}
      </select>
    </label>
  );
}

export function Switch({ checked, onChange }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 shrink-0 rounded-full border-0 p-0 align-middle transition-colors focus:outline-none focus:ring-2 focus:ring-primary/30 focus:ring-offset-2 focus:ring-offset-surface ${
        checked ? 'bg-primary' : 'bg-line-strong'
      }`}
    >
      <span
        className={`pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform ${
          checked ? 'translate-x-5' : 'translate-x-0'
        }`}
      />
    </button>
  );
}

export function Modal({ open, title, onClose, children, footer, wide = false }) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e) => e.key === 'Escape' && onClose?.();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-ink/35 backdrop-blur-sm" onClick={onClose} />
      <div
        className={`relative z-10 w-full ${wide ? 'max-w-3xl' : 'max-w-lg'} max-h-[90vh] overflow-y-auto rounded-[18px] bg-surface shadow-2xl`}
      >
        <div className="flex items-center justify-between border-b border-line px-6 py-4">
          <h3 className="font-serif text-lg font-semibold text-ink">{title}</h3>
          <button
            onClick={onClose}
            className="grid h-8 w-8 place-items-center rounded-full text-muted hover:bg-surface-2"
          >
            ✕
          </button>
        </div>
        <div className="px-6 py-5">{children}</div>
        {footer && (
          <div className="flex justify-end gap-3 border-t border-line px-6 py-4">{footer}</div>
        )}
      </div>
    </div>
  );
}

export function EmptyState({ icon = '📭', title, hint }) {
  return (
    <div className="flex flex-col items-center justify-center gap-2 py-16 text-center">
      <div className="text-4xl opacity-60">{icon}</div>
      <p className="font-medium text-ink">{title}</p>
      {hint && <p className="text-sm text-muted">{hint}</p>}
    </div>
  );
}

export function Spinner({ label = '加载中…' }) {
  return (
    <div className="flex items-center justify-center gap-3 py-16 text-muted">
      <span className="h-5 w-5 animate-spin rounded-full border-2 border-line border-t-primary" />
      <span className="text-sm">{label}</span>
    </div>
  );
}

export function Pagination({ page, pageSize, total, onPage }) {
  const pages = Math.max(1, Math.ceil(total / pageSize));
  if (total <= pageSize) return null;
  return (
    <div className="flex items-center justify-between px-1 pt-4 text-sm text-muted">
      <span>
        共 {total} 条 · 第 {page} / {pages} 页
      </span>
      <div className="flex gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          上一页
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pages}
          onClick={() => onPage(page + 1)}
        >
          下一页
        </Button>
      </div>
    </div>
  );
}
