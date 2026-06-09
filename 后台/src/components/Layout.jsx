import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth.jsx';

const NAV = [
  { to: '/', label: '数据看板', icon: '◧', end: true },
  { to: '/books', label: '书籍管理', icon: '❡' },
  { to: '/users', label: '用户管理', icon: '☻' },
  { to: '/orders', label: '订单流水', icon: '₵' },
  { to: '/monetization', label: '变现配置', icon: '✦' },
];

export default function Layout({ children }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  return (
    <div className="flex h-full">
      {/* 侧边栏 */}
      <aside className="flex w-60 shrink-0 flex-col border-r border-line bg-surface">
        <div className="flex items-center gap-2.5 px-5 py-5">
          <div className="grid h-9 w-9 place-items-center rounded-[11px] bg-primary text-on-primary">
            <span className="font-serif text-lg font-bold">L</span>
          </div>
          <div className="leading-tight">
            <div className="font-serif text-base font-bold text-ink">likenovel</div>
            <div className="text-[11px] font-medium tracking-wide text-faint">管理后台</div>
          </div>
        </div>

        <nav className="flex-1 space-y-1 px-3 py-2">
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-[13px] px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-primary-soft text-primary-ink'
                    : 'text-muted hover:bg-surface-2 hover:text-ink'
                }`
              }
            >
              <span className="w-4 text-center text-base">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="border-t border-line p-3">
          <div className="flex items-center gap-2.5 rounded-[13px] px-2 py-2">
            <div className="grid h-8 w-8 place-items-center rounded-full bg-gold-soft text-sm font-bold text-gold">
              {(user?.name || 'A')[0]}
            </div>
            <div className="flex-1 leading-tight">
              <div className="text-sm font-semibold text-ink">{user?.name || 'Admin'}</div>
              <div className="text-[11px] text-faint">{user?.role || 'admin'}</div>
            </div>
            <button
              onClick={() => {
                logout();
                navigate('/login');
              }}
              title="退出登录"
              className="grid h-8 w-8 place-items-center rounded-full text-muted hover:bg-surface-2 hover:text-danger"
            >
              ⏻
            </button>
          </div>
        </div>
      </aside>

      {/* 主区域 */}
      <main className="flex-1 overflow-y-auto">
        <div className="mx-auto max-w-6xl px-8 py-7">{children}</div>
      </main>
    </div>
  );
}

export function PageHeader({ title, subtitle, actions }) {
  return (
    <div className="mb-6 flex items-end justify-between gap-4">
      <div>
        <h1 className="font-serif text-2xl font-bold text-ink">{title}</h1>
        {subtitle && <p className="mt-1 text-sm text-muted">{subtitle}</p>}
      </div>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
    </div>
  );
}
