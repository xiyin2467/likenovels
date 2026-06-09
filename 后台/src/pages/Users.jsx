import { useEffect, useState } from 'react';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import {
  Button, Card, Badge, Input, Modal, Spinner, EmptyState, Pagination,
} from '../components/ui.jsx';
import { useToast } from '../components/Toast.jsx';
import { USER_STATUS } from '../constants.js';

const fmtDate = (s) => new Date(s).toLocaleString('zh-CN', { dateStyle: 'short', timeStyle: 'short' });

export default function Users() {
  const toast = useToast();
  const [data, setData] = useState(null);
  const [filters, setFilters] = useState({ q: '', status: '', membership: '', page: 1, pageSize: 12 });
  const [detail, setDetail] = useState(null);
  const [coinModal, setCoinModal] = useState(null);
  const [delta, setDelta] = useState(100);

  async function load() {
    setData(null);
    try {
      setData(await api.users(filters));
    } catch (e) {
      toast.error(e.message);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filters]);

  const setFilter = (patch) => setFilters((f) => ({ ...f, ...patch, page: patch.page ?? 1 }));

  async function openDetail(u) {
    setDetail({ loading: true });
    try {
      setDetail(await api.user(u.id));
    } catch (e) {
      toast.error(e.message);
      setDetail(null);
    }
  }

  async function toggleBan(u) {
    try {
      await api.updateUser(u.id, { status: u.status === 'banned' ? 'active' : 'banned' });
      toast.success(u.status === 'banned' ? '已解封' : '已封禁');
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  async function applyCoins() {
    try {
      await api.adjustCoins(coinModal.id, Number(delta));
      toast.success('金币已调整');
      setCoinModal(null);
      setDelta(100);
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  return (
    <>
      <PageHeader title="用户管理" subtitle="查看用户、调整金币、管理会员与封禁状态" />

      <Card className="mb-4 flex flex-wrap items-center gap-3 p-4">
        <input
          value={filters.q}
          onChange={(e) => setFilter({ q: e.target.value })}
          placeholder="搜索昵称 / 邮箱…"
          className="min-w-52 flex-1 rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm focus:border-primary focus:bg-surface focus:outline-none"
        />
        <select value={filters.membership} onChange={(e) => setFilter({ membership: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none">
          <option value="">全部用户</option>
          <option value="vip">VIP 会员</option>
          <option value="free">免费用户</option>
        </select>
        <select value={filters.status} onChange={(e) => setFilter({ status: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none">
          <option value="">全部状态</option>
          <option value="active">正常</option>
          <option value="banned">已封禁</option>
        </select>
      </Card>

      <Card className="overflow-hidden">
        {!data ? (
          <Spinner />
        ) : data.items.length === 0 ? (
          <EmptyState icon="🙋" title="没有符合条件的用户" />
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">用户</th>
                <th className="px-5 py-3 font-semibold">金币</th>
                <th className="px-5 py-3 font-semibold">会员</th>
                <th className="px-5 py-3 font-semibold">已读章节</th>
                <th className="px-5 py-3 font-semibold">最近活跃</th>
                <th className="px-5 py-3 font-semibold">状态</th>
                <th className="px-5 py-3 text-right font-semibold">操作</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((u) => (
                <tr key={u.id} className="border-t border-line/70 hover:bg-surface-2/50">
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-2.5">
                      <div className="grid h-8 w-8 place-items-center rounded-full bg-primary-soft text-xs font-bold text-primary-ink">
                        {u.name[0]}
                      </div>
                      <div>
                        <div className="font-medium text-ink">{u.name}</div>
                        <div className="text-xs text-muted">{u.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-5 py-3 font-semibold text-ink">{u.coins.toLocaleString()}</td>
                  <td className="px-5 py-3">
                    {u.membership ? <Badge tone="gold">VIP</Badge> : <span className="text-faint">—</span>}
                  </td>
                  <td className="px-5 py-3 text-muted">{u.chaptersRead}</td>
                  <td className="px-5 py-3 text-xs text-muted">{fmtDate(u.lastActive)}</td>
                  <td className="px-5 py-3">
                    <Badge tone={USER_STATUS[u.status]?.tone}>{USER_STATUS[u.status]?.label}</Badge>
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex justify-end gap-1">
                      <Button variant="ghost" size="sm" onClick={() => openDetail(u)}>详情</Button>
                      <Button variant="ghost" size="sm" onClick={() => setCoinModal(u)}>金币</Button>
                      <Button
                        variant={u.status === 'banned' ? 'ghost' : 'danger-ghost'}
                        size="sm"
                        onClick={() => toggleBan(u)}
                      >
                        {u.status === 'banned' ? '解封' : '封禁'}
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {data && (
          <div className="px-4 pb-3">
            <Pagination page={data.page} pageSize={data.pageSize} total={data.total}
              onPage={(p) => setFilter({ page: p })} />
          </div>
        )}
      </Card>

      {/* 用户详情 */}
      <Modal open={!!detail} title="用户详情" onClose={() => setDetail(null)} wide>
        {detail?.loading ? (
          <Spinner />
        ) : detail ? (
          <div className="space-y-5">
            <div className="flex items-center gap-3">
              <div className="grid h-12 w-12 place-items-center rounded-full bg-primary-soft text-lg font-bold text-primary-ink">
                {detail.name[0]}
              </div>
              <div>
                <div className="font-serif text-lg font-semibold text-ink">{detail.name}</div>
                <div className="text-sm text-muted">{detail.email}</div>
              </div>
              <div className="ml-auto flex gap-2">
                {detail.membership && <Badge tone="gold">VIP</Badge>}
                <Badge tone={USER_STATUS[detail.status]?.tone}>{USER_STATUS[detail.status]?.label}</Badge>
              </div>
            </div>
            <div className="grid grid-cols-3 gap-3">
              <Card className="p-3"><div className="text-xs text-faint">金币余额</div>
                <div className="font-serif text-xl font-bold text-ink">{detail.coins.toLocaleString()}</div></Card>
              <Card className="p-3"><div className="text-xs text-faint">已读章节</div>
                <div className="font-serif text-xl font-bold text-ink">{detail.chaptersRead}</div></Card>
              <Card className="p-3"><div className="text-xs text-faint">注册时间</div>
                <div className="pt-1 text-sm font-medium text-ink">{fmtDate(detail.createdAt)}</div></Card>
            </div>
            <div>
              <h4 className="mb-2 text-sm font-semibold text-ink">消费记录（{detail.orders.length}）</h4>
              <div className="max-h-56 overflow-y-auto rounded-[13px] border border-line">
                {detail.orders.length === 0 ? (
                  <p className="px-4 py-6 text-center text-sm text-muted">暂无消费记录</p>
                ) : (
                  <table className="w-full text-sm">
                    <tbody>
                      {detail.orders.map((o) => (
                        <tr key={o.id} className="border-b border-line/60 last:border-0">
                          <td className="px-4 py-2.5 font-mono text-xs text-muted">{o.id}</td>
                          <td className="px-4 py-2.5 text-muted">{o.type === 'recharge' ? '充值' : '会员'}</td>
                          <td className="px-4 py-2.5 text-ink">{o.itemLabel}</td>
                          <td className="px-4 py-2.5 text-right font-semibold text-ink">${o.amount}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            </div>
          </div>
        ) : null}
      </Modal>

      {/* 调整金币 */}
      <Modal
        open={!!coinModal}
        title="调整金币"
        onClose={() => setCoinModal(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setCoinModal(null)}>取消</Button>
            <Button onClick={applyCoins}>确认</Button>
          </>
        }
      >
        {coinModal && (
          <div className="space-y-4">
            <p className="text-sm text-muted">
              为 <span className="font-semibold text-ink">{coinModal.name}</span>（当前 {coinModal.coins} 金币）调整余额。正数为赠送，负数为扣减。
            </p>
            <Input label="变动数量" type="number" value={delta}
              onChange={(e) => setDelta(e.target.value)} />
            <div className="flex gap-2">
              {[100, 500, 1000, -100].map((v) => (
                <Button key={v} variant="outline" size="sm" onClick={() => setDelta(v)}>
                  {v > 0 ? `+${v}` : v}
                </Button>
              ))}
            </div>
          </div>
        )}
      </Modal>
    </>
  );
}
