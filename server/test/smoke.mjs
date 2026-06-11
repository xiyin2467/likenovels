// 冒烟测试：启动服务、跑通核心接口闭环。运行: npm test
import { spawn } from 'node:child_process';
import { setTimeout as sleep } from 'node:timers/promises';

const PORT = 4123;
const base = `http://localhost:${PORT}`;
const proc = spawn(process.execPath, ['src/index.js'], {
  env: { ...process.env, PORT: String(PORT) },
  stdio: 'inherit',
});

let token = '';
let failures = 0;

function assert(cond, msg) {
  if (cond) {
    console.log(`  ✓ ${msg}`);
  } else {
    failures++;
    console.error(`  ✗ ${msg}`);
  }
}

async function api(path, opts = {}) {
  const res = await fetch(base + path, {
    ...opts,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(opts.headers || {}),
    },
  });
  const body = await res.json().catch(() => ({}));
  return { status: res.status, body };
}

try {
  await sleep(800);

  // 登录
  let r = await api('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username: 'admin', password: 'admin123' }),
  });
  assert(r.status === 200 && r.body.token, '登录成功并返回 token');
  token = r.body.token;

  // 鉴权拦截
  const noAuth = await fetch(base + '/api/stats').then((x) => x.status);
  assert(noAuth === 401, '未带 token 访问被拦截 (401)');

  // 看板
  r = await api('/api/stats');
  assert(r.status === 200 && r.body.cards && Array.isArray(r.body.trend), '看板统计返回正常');

  // 书籍 CRUD
  r = await api('/api/books');
  assert(r.status === 200 && r.body.total >= 8, `书籍列表返回 (${r.body.total})`);

  r = await api('/api/books', {
    method: 'POST',
    body: JSON.stringify({
      title: 'Test Book',
      author: 'QA',
      genre: 'modern',
      coinPrice: 25,
      freeChapters: 5,
    }),
  });
  assert(r.status === 201 && r.body.id, '新建书籍成功');
  const bookId = r.body.id;

  r = await api(`/api/books/${bookId}`, {
    method: 'PUT',
    body: JSON.stringify({ rating: 4.9 }),
  });
  assert(r.status === 200 && r.body.rating === 4.9, '更新书籍成功');

  // 章节
  r = await api(`/api/books/${bookId}/chapters`, {
    method: 'POST',
    body: JSON.stringify({ title: 'Ch1', free: true }),
  });
  assert(r.status === 201 && r.body.id === 1, '新建章节成功');

  r = await api(`/api/books/${bookId}`, { method: 'DELETE' });
  assert(r.status === 200, '删除书籍成功');

  // 用户
  r = await api('/api/users?page=1&pageSize=10');
  assert(r.status === 200 && r.body.items.length === 10, '用户分页返回 10 条');
  const userId = r.body.items[0].id;

  r = await api(`/api/users/${userId}/coins`, {
    method: 'POST',
    body: JSON.stringify({ delta: 100 }),
  });
  assert(r.status === 200, '调整用户金币成功');

  // 订单
  r = await api('/api/orders?status=paid');
  assert(r.status === 200 && r.body.items.every((o) => o.status === 'paid'), '订单按状态过滤');

  // 变现配置
  r = await api('/api/packages');
  assert(r.status === 200 && r.body.items.length >= 4, '充值套餐列表返回');
  r = await api('/api/plans');
  assert(r.status === 200 && r.body.items.length >= 3, '会员套餐列表返回');

  console.log(failures === 0 ? '\n全部通过 ✓' : `\n失败 ${failures} 项 ✗`);
} catch (err) {
  console.error(err);
  failures++;
} finally {
  proc.kill();
  await new Promise((resolve) => proc.once('exit', resolve));
  process.exitCode = failures === 0 ? 0 : 1;
}
