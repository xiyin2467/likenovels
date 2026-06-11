// ---------------------------------------------------------------------------
// likenovel 管理后台 API —— 零依赖 Node HTTP 服务
// 模块化单体：内存数据 + REST 路由，覆盖书籍/章节/用户/订单/变现配置/看板统计。
// 启动: npm start   开发: npm run dev
// ---------------------------------------------------------------------------

import http from 'node:http';
import { db, nextId, GENRES, BOOK_STATUS, syncChaptersPaywall } from './db.js';

const PORT = process.env.PORT || 4000;
const ADMIN_USER = process.env.ADMIN_USER || 'admin';
const ADMIN_PASS = process.env.ADMIN_PASS || 'admin123';
const TOKEN = 'likenovel-admin-token'; // demo：固定令牌，生产应签发 JWT

// ── 工具 ────────────────────────────────────────────────────────────────────
function send(res, status, body) {
  const payload = body === undefined ? '' : JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  });
  res.end(payload);
}

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (c) => (data += c));
    req.on('end', () => {
      if (!data) return resolve({});
      try {
        resolve(JSON.parse(data));
      } catch {
        resolve({});
      }
    });
  });
}

function authed(req) {
  const h = req.headers['authorization'] || '';
  return h === `Bearer ${TOKEN}`;
}

function paginate(list, query) {
  const page = Math.max(1, parseInt(query.page || '1', 10));
  const pageSize = Math.min(100, Math.max(1, parseInt(query.pageSize || '20', 10)));
  const start = (page - 1) * pageSize;
  return {
    items: list.slice(start, start + pageSize),
    total: list.length,
    page,
    pageSize,
  };
}

function matchText(value, q) {
  return String(value || '').toLowerCase().includes(q.toLowerCase());
}

// ── 路由表 ──────────────────────────────────────────────────────────────────
const routes = [];
const route = (method, pattern, handler) => {
  const keys = [];
  const regex = new RegExp(
    '^' +
      pattern.replace(/:[^/]+/g, (m) => {
        keys.push(m.slice(1));
        return '([^/]+)';
      }) +
      '$'
  );
  routes.push({ method, regex, keys, handler });
};

// ===========================================================================
// 认证
// ===========================================================================
route('POST', '/api/auth/login', async (req, res) => {
  const body = await readBody(req);
  if (body.username === ADMIN_USER && body.password === ADMIN_PASS) {
    return send(res, 200, {
      token: TOKEN,
      user: { name: 'Admin', role: 'superadmin' },
    });
  }
  return send(res, 401, { error: '用户名或密码错误' });
});

route('GET', '/api/auth/me', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  return send(res, 200, { user: { name: 'Admin', role: 'superadmin' } });
});

// ===========================================================================
// 看板统计
// ===========================================================================
route('GET', '/api/stats', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });

  const paidOrders = db.orders.filter((o) => o.status === 'paid');
  const revenue = paidOrders.reduce((s, o) => s + o.amount, 0);
  const vipCount = db.users.filter((u) => u.membership).length;
  const coinBalance = db.users.reduce((s, u) => s + u.coins, 0);

  // 近 7 天营收趋势
  const days = [];
  const now = new Date();
  for (let i = 6; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    const key = d.toISOString().slice(0, 10);
    const dayRevenue = paidOrders
      .filter((o) => o.createdAt.slice(0, 10) === key)
      .reduce((s, o) => s + o.amount, 0);
    days.push({
      date: key,
      label: d.toLocaleDateString('en-US', { weekday: 'short' }),
      revenue: Number(dayRevenue.toFixed(2)),
      // 用确定性伪随机制造 DAU 曲线，便于演示
      dau: 1800 + ((d.getDate() * 137) % 900),
    });
  }

  // 题材分布
  const byGenre = GENRES.map((g) => ({
    genre: g,
    count: db.books.filter((b) => b.genre === g).length,
  })).filter((x) => x.count > 0);

  return send(res, 200, {
    cards: {
      revenue: Number(revenue.toFixed(2)),
      orders: db.orders.length,
      paidOrders: paidOrders.length,
      users: db.users.length,
      vipUsers: vipCount,
      books: db.books.length,
      coinBalance,
    },
    trend: days,
    byGenre,
    recentOrders: [...db.orders]
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
      .slice(0, 6),
  });
});

// ===========================================================================
// 书籍
// ===========================================================================
route('GET', '/api/books', async (req, res, _params, query) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  let list = [...db.books];
  if (query.q) list = list.filter((b) => matchText(b.title, query.q) || matchText(b.author, query.q));
  if (query.genre) list = list.filter((b) => b.genre === query.genre);
  if (query.status) list = list.filter((b) => b.status === query.status);
  list.sort((a, b) => (a.rank ?? 999) - (b.rank ?? 999));
  return send(res, 200, paginate(list, query));
});

route('GET', '/api/books/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const book = db.books.find((b) => b.id === params.id);
  if (!book) return send(res, 404, { error: 'not found' });
  return send(res, 200, { ...book, chaptersList: db.chapters[book.id] || [] });
});

route('POST', '/api/books', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const body = await readBody(req);
  if (!body.title || !body.author) return send(res, 400, { error: '标题和作者必填' });
  const coinPrice = Number(body.coinPrice) || 0;
  if (coinPrice <= 0) {
    return send(res, 400, { error: '单章解锁金币必须大于 0' });
  }
  const id = nextId('b');
  const book = {
    id,
    title: body.title,
    author: body.author,
    genre: GENRES.includes(body.genre) ? body.genre : 'modern',
    rating: Number(body.rating) || 4.5,
    reads: body.reads || '0',
    chapters: Number(body.chapters) || 0,
    status: BOOK_STATUS.includes(body.status) ? body.status : 'ongoing',
    tropes: Array.isArray(body.tropes) ? body.tropes : [],
    blurb: body.blurb || '',
    badge: body.badge || null,
    rank: body.rank ?? null,
    coinPrice,
    freeChapters: Math.max(0, Number(body.freeChapters) || 5),
  };
  db.books.push(book);
  db.chapters[id] = [];
  return send(res, 201, book);
});

route('PUT', '/api/books/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const book = db.books.find((b) => b.id === params.id);
  if (!book) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  const fields = ['title', 'author', 'genre', 'rating', 'reads', 'chapters', 'status', 'tropes', 'blurb', 'badge', 'rank'];
  for (const f of fields) {
    if (body[f] !== undefined) {
      if (f === 'rating' || f === 'chapters') book[f] = Number(body[f]);
      else book[f] = body[f];
    }
  }
  // 付费配置：会员全场畅读；金币价格仅用于非会员按章购买。
  let paywallChanged = false;
  if (body.coinPrice !== undefined) {
    book.coinPrice = Number(body.coinPrice) || 0;
    paywallChanged = true;
  }
  if (body.freeChapters !== undefined) {
    book.freeChapters = Math.max(0, Number(body.freeChapters) || 0);
    paywallChanged = true;
  }
  if (!(book.coinPrice > 0)) {
    return send(res, 400, { error: '单章解锁金币必须大于 0' });
  }
  if (paywallChanged) syncChaptersPaywall(book, db.chapters[book.id]);
  return send(res, 200, book);
});

route('DELETE', '/api/books/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const idx = db.books.findIndex((b) => b.id === params.id);
  if (idx === -1) return send(res, 404, { error: 'not found' });
  db.books.splice(idx, 1);
  delete db.chapters[params.id];
  return send(res, 200, { ok: true });
});

// ===========================================================================
// 章节
// ===========================================================================
route('GET', '/api/books/:id/chapters', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  return send(res, 200, { items: db.chapters[params.id] || [] });
});

route('POST', '/api/books/:id/chapters', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const book = db.books.find((b) => b.id === params.id);
  if (!book) return send(res, 404, { error: 'book not found' });
  const body = await readBody(req);
  const list = db.chapters[params.id] || (db.chapters[params.id] = []);
  const nextNum = list.length ? Math.max(...list.map((c) => c.id)) + 1 : 1;
  // 免费/金币由书籍付费配置派生，章节不单独配置
  const chapter = {
    id: nextNum,
    bookId: params.id,
    title: body.title || `Chapter ${nextNum}`,
    free: list.length < (book.freeChapters ?? 0),
    coins: book.coinPrice ?? 0,
    wordCount: Number(body.wordCount) || 2200,
    published: body.published !== false,
  };
  list.push(chapter);
  book.chapters = Math.max(book.chapters, list.length);
  return send(res, 201, chapter);
});

route('PUT', '/api/books/:id/chapters/:cid', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const list = db.chapters[params.id] || [];
  const ch = list.find((c) => String(c.id) === params.cid);
  if (!ch) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  // free/coins 由书籍付费配置统一管理，章节级仅可改标题/字数/发布状态
  for (const f of ['title', 'wordCount', 'published']) {
    if (body[f] !== undefined) {
      if (f === 'wordCount') ch[f] = Number(body[f]);
      else ch[f] = body[f];
    }
  }
  return send(res, 200, ch);
});

route('DELETE', '/api/books/:id/chapters/:cid', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const list = db.chapters[params.id] || [];
  const idx = list.findIndex((c) => String(c.id) === params.cid);
  if (idx === -1) return send(res, 404, { error: 'not found' });
  list.splice(idx, 1);
  return send(res, 200, { ok: true });
});

// ===========================================================================
// 用户
// ===========================================================================
route('GET', '/api/users', async (req, res, _params, query) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  let list = [...db.users];
  if (query.q) list = list.filter((u) => matchText(u.name, query.q) || matchText(u.email, query.q));
  if (query.status) list = list.filter((u) => u.status === query.status);
  if (query.membership === 'vip') list = list.filter((u) => u.membership);
  if (query.membership === 'free') list = list.filter((u) => !u.membership);
  list.sort((a, b) => b.lastActive.localeCompare(a.lastActive));
  return send(res, 200, paginate(list, query));
});

route('GET', '/api/users/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const user = db.users.find((u) => u.id === params.id);
  if (!user) return send(res, 404, { error: 'not found' });
  const orders = db.orders.filter((o) => o.userId === user.id);
  return send(res, 200, { ...user, orders });
});

route('PUT', '/api/users/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const user = db.users.find((u) => u.id === params.id);
  if (!user) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  for (const f of ['name', 'email', 'coins', 'membership', 'status']) {
    if (body[f] !== undefined) user[f] = f === 'coins' ? Number(body[f]) : body[f];
  }
  return send(res, 200, user);
});

// 调整金币 (赠送/扣减)
route('POST', '/api/users/:id/coins', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const user = db.users.find((u) => u.id === params.id);
  if (!user) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  const delta = Number(body.delta) || 0;
  user.coins = Math.max(0, user.coins + delta);
  return send(res, 200, user);
});

// ===========================================================================
// 订单
// ===========================================================================
route('GET', '/api/orders', async (req, res, _params, query) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  let list = [...db.orders];
  if (query.q) list = list.filter((o) => matchText(o.userName, query.q) || matchText(o.id, query.q));
  if (query.type) list = list.filter((o) => o.type === query.type);
  if (query.status) list = list.filter((o) => o.status === query.status);
  list.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  return send(res, 200, paginate(list, query));
});

route('POST', '/api/orders/:id/refund', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const order = db.orders.find((o) => o.id === params.id);
  if (!order) return send(res, 404, { error: 'not found' });
  if (order.status !== 'paid') return send(res, 400, { error: '仅已支付订单可退款' });
  order.status = 'refunded';
  return send(res, 200, order);
});

// ===========================================================================
// 变现配置：充值套餐
// ===========================================================================
route('GET', '/api/packages', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  return send(res, 200, { items: db.packages });
});

route('POST', '/api/packages', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const body = await readBody(req);
  const pkg = {
    id: nextId('p'),
    coins: Number(body.coins) || 0,
    bonus: Number(body.bonus) || 0,
    bonusLabel: body.bonusLabel || '',
    price: body.price || '$0.00',
    pricevalue: Number(body.pricevalue) || Number(String(body.price || '').replace('$', '')) || 0,
    tag: body.tag || null,
    active: body.active !== false,
  };
  db.packages.push(pkg);
  return send(res, 201, pkg);
});

route('PUT', '/api/packages/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const pkg = db.packages.find((p) => p.id === params.id);
  if (!pkg) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  for (const f of ['coins', 'bonus', 'bonusLabel', 'price', 'pricevalue', 'tag', 'active']) {
    if (body[f] !== undefined) pkg[f] = ['coins', 'bonus', 'pricevalue'].includes(f) ? Number(body[f]) : body[f];
  }
  return send(res, 200, pkg);
});

route('DELETE', '/api/packages/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const idx = db.packages.findIndex((p) => p.id === params.id);
  if (idx === -1) return send(res, 404, { error: 'not found' });
  db.packages.splice(idx, 1);
  return send(res, 200, { ok: true });
});

// ===========================================================================
// 变现配置：会员套餐
// ===========================================================================
route('GET', '/api/plans', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  return send(res, 200, { items: db.plans });
});

route('POST', '/api/plans', async (req, res) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const body = await readBody(req);
  const plan = {
    id: nextId('m'),
    name: body.name || 'New plan',
    period: body.period || '/month',
    price: body.price || '$0.00',
    originalPrice: body.originalPrice || null,
    introOffer: body.introOffer || null,
    tag: body.tag || null,
    active: body.active !== false,
  };
  db.plans.push(plan);
  return send(res, 201, plan);
});

route('PUT', '/api/plans/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const plan = db.plans.find((p) => p.id === params.id);
  if (!plan) return send(res, 404, { error: 'not found' });
  const body = await readBody(req);
  for (const f of ['name', 'period', 'price', 'originalPrice', 'introOffer', 'tag', 'active']) {
    if (body[f] !== undefined) plan[f] = body[f];
  }
  return send(res, 200, plan);
});

route('DELETE', '/api/plans/:id', async (req, res, params) => {
  if (!authed(req)) return send(res, 401, { error: 'unauthorized' });
  const idx = db.plans.findIndex((p) => p.id === params.id);
  if (idx === -1) return send(res, 404, { error: 'not found' });
  db.plans.splice(idx, 1);
  return send(res, 200, { ok: true });
});

// 元数据 (题材/状态枚举，供下拉框使用)
route('GET', '/api/meta', async (req, res) => {
  return send(res, 200, { genres: GENRES, bookStatus: BOOK_STATUS });
});

// ===========================================================================
// 服务器
// ===========================================================================
const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') return send(res, 204);

  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname.replace(/\/$/, '') || '/';
  const query = Object.fromEntries(url.searchParams.entries());

  if (pathname === '/' || pathname === '/health') {
    return send(res, 200, { name: 'likenovel-admin-api', status: 'ok' });
  }

  for (const r of routes) {
    if (r.method !== req.method) continue;
    const m = r.regex.exec(pathname);
    if (!m) continue;
    const params = {};
    r.keys.forEach((k, i) => (params[k] = decodeURIComponent(m[i + 1])));
    try {
      return await r.handler(req, res, params, query);
    } catch (err) {
      console.error(err);
      return send(res, 500, { error: 'internal error' });
    }
  }

  return send(res, 404, { error: 'route not found' });
});

server.listen(PORT, () => {
  console.log(`✓ likenovel admin API → http://localhost:${PORT}`);
  console.log(`  默认账号: ${ADMIN_USER} / ${ADMIN_PASS}`);
});
