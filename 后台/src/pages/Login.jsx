import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../auth.jsx';
import { Button, Input } from '../components/ui.jsx';

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function onSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(username, password);
      navigate('/', { replace: true });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="grid h-full place-items-center px-4">
      <div className="w-full max-w-sm">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 grid h-14 w-14 place-items-center rounded-[16px] bg-primary text-on-primary">
            <span className="font-serif text-2xl font-bold">L</span>
          </div>
          <h1 className="font-serif text-2xl font-bold text-ink">likenovel 管理后台</h1>
          <p className="mt-1 text-sm text-muted">登录以管理书库、用户与变现</p>
        </div>

        <form
          onSubmit={onSubmit}
          className="space-y-4 rounded-[18px] border border-line bg-surface p-6 shadow-sm"
        >
          <Input
            label="用户名"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            placeholder="admin"
            autoFocus
          />
          <Input
            label="密码"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
          />
          {error && (
            <p className="rounded-[13px] bg-danger/10 px-3 py-2 text-sm text-danger">{error}</p>
          )}
          <Button type="submit" size="lg" className="w-full" disabled={loading}>
            {loading ? '登录中…' : '登 录'}
          </Button>
          <p className="text-center text-xs text-faint">默认账号 admin / admin123</p>
        </form>
      </div>
    </div>
  );
}
