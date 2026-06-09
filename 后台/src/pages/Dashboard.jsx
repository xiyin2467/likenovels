import { useEffect, useState } from 'react';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import { Card, Badge, Spinner } from '../components/ui.jsx';
import { GENRE_LABELS, ORDER_STATUS } from '../constants.js';

const fmtMoney = (n) => '$' + Number(n).toLocaleString('en-US', { minimumFractionDigits: 2 });
const fmtNum = (n) => Number(n).toLocaleString('en-US');

function StatCard({ label, value, sub, tone = 'primary' }) {
  const ring = {
    primary: 'before:bg-primary',
    gold: 'before:bg-gold',
    success: 'before:bg-success',
    ink: 'before:bg-ink',
  }[tone];
  return (
    <Card
      className={`relative overflow-hidden p-5 before:absolute before:left-0 before:top-0 before:h-full before:w-1 ${ring}`}
    >
      <div className="text-xs font-semibold uppercase tracking-wide text-faint">{label}</div>
      <div className="mt-2 font-serif text-3xl font-bold text-ink">{value}</div>
      {sub && <div className="mt-1 text-xs text-muted">{sub}</div>}
    </Card>
  );
}

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    api.stats().then(setData).catch((e) => setError(e.message));
  }, []);

  if (error) return <p className="text-danger">{error}</p>;
  if (!data) return <Spinner />;

  const { cards, trend, byGenre, recentOrders } = data;
  const maxRev = Math.max(...trend.map((d) => d.revenue), 1);
  const maxGenre = Math.max(...byGenre.map((g) => g.count), 1);

  return (
    <>
      <PageHeader title="数据看板" subtitle="核心经营指标总览（演示数据，进程重启复位）" />

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <StatCard label="累计营收" value={fmtMoney(cards.revenue)} sub={`${cards.paidOrders} 笔已支付`} tone="primary" />
        <StatCard label="注册用户" value={fmtNum(cards.users)} sub={`${cards.vipUsers} 位 VIP 会员`} tone="gold" />
        <StatCard label="在库书籍" value={fmtNum(cards.books)} sub="含连载与完结" tone="ink" />
        <StatCard label="金币流通量" value={fmtNum(cards.coinBalance)} sub="用户余额合计" tone="success" />
      </div>

      <div className="mt-5 grid grid-cols-1 gap-5 lg:grid-cols-3">
        {/* 营收趋势 */}
        <Card className="p-5 lg:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="font-serif text-lg font-semibold text-ink">近 7 天营收</h3>
            <Badge tone="primary">日活 / 营收</Badge>
          </div>
          <div className="flex h-52 items-end gap-3">
            {trend.map((d) => (
              <div key={d.date} className="group flex flex-1 flex-col items-center gap-2">
                <div className="relative flex w-full flex-1 items-end">
                  <div
                    className="w-full rounded-t-md bg-primary/85 transition-all group-hover:bg-primary"
                    style={{ height: `${(d.revenue / maxRev) * 100}%`, minHeight: '4px' }}
                    title={fmtMoney(d.revenue)}
                  />
                  <span className="absolute -top-5 left-1/2 -translate-x-1/2 whitespace-nowrap text-[10px] font-semibold text-muted opacity-0 transition-opacity group-hover:opacity-100">
                    {fmtMoney(d.revenue)}
                  </span>
                </div>
                <span className="text-[11px] text-faint">{d.label}</span>
              </div>
            ))}
          </div>
        </Card>

        {/* 题材分布 */}
        <Card className="p-5">
          <h3 className="mb-4 font-serif text-lg font-semibold text-ink">题材分布</h3>
          <div className="space-y-3">
            {byGenre.map((g) => (
              <div key={g.genre}>
                <div className="mb-1 flex justify-between text-xs">
                  <span className="font-medium text-ink">{GENRE_LABELS[g.genre] || g.genre}</span>
                  <span className="text-muted">{g.count}</span>
                </div>
                <div className="h-2 w-full overflow-hidden rounded-full bg-surface-3">
                  <div
                    className="h-full rounded-full bg-gold"
                    style={{ width: `${(g.count / maxGenre) * 100}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* 最近订单 */}
      <Card className="mt-5 overflow-hidden">
        <div className="border-b border-line px-5 py-4">
          <h3 className="font-serif text-lg font-semibold text-ink">最近订单</h3>
        </div>
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs uppercase tracking-wide text-faint">
              <th className="px-5 py-3 font-semibold">订单号</th>
              <th className="px-5 py-3 font-semibold">用户</th>
              <th className="px-5 py-3 font-semibold">类型</th>
              <th className="px-5 py-3 font-semibold">金额</th>
              <th className="px-5 py-3 font-semibold">状态</th>
            </tr>
          </thead>
          <tbody>
            {recentOrders.map((o) => (
              <tr key={o.id} className="border-t border-line/70">
                <td className="px-5 py-3 font-mono text-xs text-muted">{o.id}</td>
                <td className="px-5 py-3 text-ink">{o.userName}</td>
                <td className="px-5 py-3 text-muted">{o.type === 'recharge' ? '充值' : '会员'}</td>
                <td className="px-5 py-3 font-semibold text-ink">{fmtMoney(o.amount)}</td>
                <td className="px-5 py-3">
                  <Badge tone={ORDER_STATUS[o.status]?.tone}>{ORDER_STATUS[o.status]?.label}</Badge>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </>
  );
}
