// 统一 API 客户端：自动携带 token，开发环境经 Vite 代理转发到 server/
const TOKEN_KEY = 'likenovel_admin_token';

export const getToken = () => localStorage.getItem(TOKEN_KEY);
export const setToken = (t) => localStorage.setItem(TOKEN_KEY, t);
export const clearToken = () => localStorage.removeItem(TOKEN_KEY);

async function request(path, { method = 'GET', body, params } = {}) {
  let url = path;
  if (params) {
    const qs = new URLSearchParams(
      Object.entries(params).filter(([, v]) => v !== '' && v != null)
    ).toString();
    if (qs) url += `?${qs}`;
  }

  const res = await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(getToken() ? { Authorization: `Bearer ${getToken()}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401) {
    clearToken();
    if (!path.includes('/auth/login')) {
      window.dispatchEvent(new CustomEvent('auth:expired'));
    }
  }

  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || `请求失败 (${res.status})`);
  return data;
}

export const api = {
  // 认证
  login: (username, password) =>
    request('/api/auth/login', { method: 'POST', body: { username, password } }),
  me: () => request('/api/auth/me'),

  // 看板
  stats: () => request('/api/stats'),
  meta: () => request('/api/meta'),

  // 书籍
  books: (params) => request('/api/books', { params }),
  book: (id) => request(`/api/books/${id}`),
  createBook: (body) => request('/api/books', { method: 'POST', body }),
  updateBook: (id, body) => request(`/api/books/${id}`, { method: 'PUT', body }),
  deleteBook: (id) => request(`/api/books/${id}`, { method: 'DELETE' }),

  // 章节
  chapters: (bookId) => request(`/api/books/${bookId}/chapters`),
  createChapter: (bookId, body) =>
    request(`/api/books/${bookId}/chapters`, { method: 'POST', body }),
  updateChapter: (bookId, cid, body) =>
    request(`/api/books/${bookId}/chapters/${cid}`, { method: 'PUT', body }),
  deleteChapter: (bookId, cid) =>
    request(`/api/books/${bookId}/chapters/${cid}`, { method: 'DELETE' }),

  // 用户
  users: (params) => request('/api/users', { params }),
  user: (id) => request(`/api/users/${id}`),
  updateUser: (id, body) => request(`/api/users/${id}`, { method: 'PUT', body }),
  adjustCoins: (id, delta) =>
    request(`/api/users/${id}/coins`, { method: 'POST', body: { delta } }),

  // 订单
  orders: (params) => request('/api/orders', { params }),
  refundOrder: (id) => request(`/api/orders/${id}/refund`, { method: 'POST' }),

  // 充值套餐
  packages: () => request('/api/packages'),
  createPackage: (body) => request('/api/packages', { method: 'POST', body }),
  updatePackage: (id, body) => request(`/api/packages/${id}`, { method: 'PUT', body }),
  deletePackage: (id) => request(`/api/packages/${id}`, { method: 'DELETE' }),

  // 会员套餐
  plans: () => request('/api/plans'),
  createPlan: (body) => request('/api/plans', { method: 'POST', body }),
  updatePlan: (id, body) => request(`/api/plans/${id}`, { method: 'PUT', body }),
  deletePlan: (id) => request(`/api/plans/${id}`, { method: 'DELETE' }),
};
