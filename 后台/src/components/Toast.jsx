import { createContext, useContext, useState, useCallback } from 'react';

const ToastContext = createContext(null);

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);

  const push = useCallback((message, type = 'success') => {
    const id = Math.random().toString(36).slice(2);
    setToasts((t) => [...t, { id, message, type }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 2800);
  }, []);

  const toast = {
    success: (m) => push(m, 'success'),
    error: (m) => push(m, 'error'),
    info: (m) => push(m, 'info'),
  };

  return (
    <ToastContext.Provider value={toast}>
      {children}
      <div className="fixed top-4 right-4 z-[100] flex flex-col gap-2">
        {toasts.map((t) => (
          <div
            key={t.id}
            className="flex items-center gap-2 rounded-xl px-4 py-3 text-sm font-medium shadow-lg ring-1 animate-[slidein_.2s_ease-out]"
            style={{
              background: 'var(--color-surface)',
              color: 'var(--color-ink)',
              borderColor: 'var(--color-line)',
              boxShadow: '0 8px 24px rgba(46,31,46,.12)',
            }}
          >
            <span
              className="h-2 w-2 rounded-full"
              style={{
                background:
                  t.type === 'error'
                    ? 'var(--color-danger)'
                    : t.type === 'info'
                      ? 'var(--color-gold)'
                      : 'var(--color-success)',
              }}
            />
            {t.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export const useToast = () => useContext(ToastContext);
