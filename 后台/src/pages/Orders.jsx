import { useEffect, useState } from 'react';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import {
  Button, Card, Badge, Modal, Spinner, EmptyState, Pagination,
} from '../components/ui.jsx';
import { useToast } from '../components/Toast.jsx';
import { ORDER_STATUS } from '../constants.js';

const fmtDate = (s) => new Date(s).toLocaleString('zh-CN', { dateStyle: 'short', timeStyle: 'short' });

export default function Orders() {
  const toast = useToast();
  const [data, setData] = useState(null);
  const [filters, setFilters] = useState({ q: '', type: '', status: '', page: 1, pageSize: 15 });
  const [confirmRefund, setConfirmRefund] = useState(null);

  async function load() {
    setData(null);
    try {
      setData(await api.orders(filters));
    } catch (e) {
      toast.error(e.message);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filters]);

  const setFilter = (patch) => setFilters((f) => ({ ...f, ...patch, page: patch.page ?? 1 }));

  async function doRefund() {
    try {
      await api.refundOrder(confirmRefund.id);
      toast.success('已退款');
      setConfirmRefund(null);
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  const paidRevenue = data?.items
    ? data.items.filter((o) => o.status === 'paid').reduce((s, o) => s + o.amount, 0)
    : 0;

  return (
    <>
      <PageHeader title="订单流水" subtitle="充值与会员订阅的交易记录" />

      <Card className="mb-4 flex flex-wrap items-center gap-3 p-4">
        <input
          value={filters.q}
          onChange={(e) => setFilter({ q: e.target.value })}
          placeholder="搜索订单号 / 用户…"
          className="min-w-52 flex-1 rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm focus:border-primary focus:bg-surface focus:outline-none"
        />
        <select value={filters.type} onChange={(e) => setFilter({ type: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none">
          <option value="">全部类型</option>
          <option value="recharge">金币充值</option>
          <option value="membership">会员订阅</option>
        </select>
        <select value={filters.status} onChange={(e) => setFilter({ status: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none">
          <option value="">全部状态</option>
          {Object.entries(ORDER_STATUS).map(([v, s]) => (
            <option key={v} value={v}>{s.label}</option>
          ))}
        </select>
        {data && (
          <Badge tone="primary">本页已支付 ${paidRevenue.toFixed(2)}</Badge>
        )}
      </Card>

      <Card className="overflow-hidden">
        {!data ? (
          <Spinner />
        ) : data.items.length === 0 ? (
          <EmptyState icon="🧾" title="没有符合条件的订单" />
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">订单号</th>
                <th className="px-5 py-3 font-semibold">用户</th>
                <th className="px-5 py-3 font-semibold">类型</th>
                <th className="px-5 py-3 font-semibold">内容</th>
                <th className="px-5 py-3 font-semibold">金额</th>
                <th className="px-5 py-3 font-semibold">时间</th>
                <th className="px-5 py-3 font-semibold">状态</th>
                <th className="px-5 py-3 text-right font-semibold">操作</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((o) => (
                <tr key={o.id} className="border-t border-line/70 hover:bg-surface-2/50">
                  <td className="px-5 py-3 font-mono text-xs text-muted">{o.id}</td>
                  <td className="px-5 py-3 text-ink">{o.userName}</td>
                  <td className="px-5 py-3 text-muted">{o.type === 'recharge' ? '充值' : '会员'}</td>
                  <td className="px-5 py-3 text-muted">{o.itemLabel}</td>
                  <td className="px-5 py-3 font-semibold text-ink">${o.amount}</td>
                  <td className="px-5 py-3 text-xs text-muted">{fmtDate(o.createdAt)}</td>
                  <td className="px-5 py-3">
                    <Badge tone={ORDER_STATUS[o.status]?.tone}>{ORDER_STATUS[o.status]?.label}</Badge>
                  </td>
                  <td className="px-5 py-3 text-right">
                    {o.status === 'paid' ? (
                      <Button variant="danger-ghost" size="sm" onClick={() => setConfirmRefund(o)}>
                        退款
                      </Button>
                    ) : (
                      <span className="text-faint">—</span>
                    )}
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

      <Modal
        open={!!confirmRefund}
        title="确认退款"
        onClose={() => setConfirmRefund(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmRefund(null)}>取消</Button>
            <Button variant="danger" onClick={doRefund}>确认退款</Button>
          </>
        }
      >
        <p className="text-sm text-muted">
          确定为订单 <span className="font-mono text-ink">{confirmRefund?.id}</span>（${confirmRefund?.amount}）办理退款吗？
        </p>
      </Modal>
    </>
  );
}
