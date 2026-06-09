import { useEffect, useState } from 'react';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import {
  Button, Card, Badge, Input, Switch, Modal, Spinner,
} from '../components/ui.jsx';
import { useToast } from '../components/Toast.jsx';

export default function Monetization() {
  const toast = useToast();
  const [tab, setTab] = useState('packages');
  const [packages, setPackages] = useState(null);
  const [plans, setPlans] = useState(null);
  const [modal, setModal] = useState(null); // {kind, mode, id, form}
  const [confirmDel, setConfirmDel] = useState(null);
  const [saving, setSaving] = useState(false);

  async function load() {
    try {
      const [p, m] = await Promise.all([api.packages(), api.plans()]);
      setPackages(p.items);
      setPlans(m.items);
    } catch (e) {
      toast.error(e.message);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ── 充值套餐表单 ──
  function newPackage() {
    setModal({ kind: 'package', mode: 'create', form: { coins: 600, bonus: 0, bonusLabel: '', price: '$4.99', tag: '', active: true } });
  }
  function editPackage(p) {
    setModal({ kind: 'package', mode: 'edit', id: p.id, form: { ...p, tag: p.tag || '' } });
  }
  // ── 会员套餐表单 ──
  function newPlan() {
    setModal({ kind: 'plan', mode: 'create', form: { name: '', period: '/month', price: '$9.99', originalPrice: '', tag: '', dailyCoins: 50, active: true } });
  }
  function editPlan(p) {
    setModal({ kind: 'plan', mode: 'edit', id: p.id, form: { ...p, tag: p.tag || '', originalPrice: p.originalPrice || '' } });
  }

  async function save() {
    const { kind, mode, id, form } = modal;
    setSaving(true);
    try {
      if (kind === 'package') {
        const payload = {
          ...form,
          coins: Number(form.coins),
          bonus: Number(form.bonus),
          pricevalue: Number(String(form.price).replace(/[^0-9.]/g, '')) || 0,
          tag: form.tag || null,
        };
        mode === 'create' ? await api.createPackage(payload) : await api.updatePackage(id, payload);
      } else {
        const payload = {
          ...form,
          dailyCoins: Number(form.dailyCoins),
          tag: form.tag || null,
          originalPrice: form.originalPrice || null,
        };
        mode === 'create' ? await api.createPlan(payload) : await api.updatePlan(id, payload);
      }
      toast.success('已保存');
      setModal(null);
      load();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setSaving(false);
    }
  }

  async function toggleActive(kind, item) {
    try {
      if (kind === 'package') await api.updatePackage(item.id, { active: !item.active });
      else await api.updatePlan(item.id, { active: !item.active });
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  async function doDelete() {
    const { kind, item } = confirmDel;
    try {
      if (kind === 'package') await api.deletePackage(item.id);
      else await api.deletePlan(item.id);
      toast.success('已删除');
      setConfirmDel(null);
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  if (!packages || !plans) return <Spinner />;

  return (
    <>
      <PageHeader
        title="变现配置"
        subtitle="管理金币充值套餐与会员订阅方案（同步前台付费墙）"
        actions={
          tab === 'packages'
            ? <Button onClick={newPackage}>＋ 新建充值套餐</Button>
            : <Button onClick={newPlan}>＋ 新建会员套餐</Button>
        }
      />

      <div className="mb-5 inline-flex rounded-[13px] border border-line bg-surface-2 p-1">
        {[['packages', '金币充值'], ['plans', '会员订阅']].map(([k, l]) => (
          <button
            key={k}
            onClick={() => setTab(k)}
            className={`rounded-[10px] px-4 py-2 text-sm font-semibold transition-colors ${
              tab === k ? 'bg-surface text-primary-ink shadow-sm' : 'text-muted hover:text-ink'
            }`}
          >
            {l}
          </button>
        ))}
      </div>

      {tab === 'packages' ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {packages.map((p) => (
            <Card key={p.id} className={`p-5 ${!p.active ? 'opacity-60' : ''}`}>
              <div className="flex items-start justify-between">
                <div>
                  <div className="font-serif text-2xl font-bold text-ink">{p.coins.toLocaleString()}</div>
                  <div className="text-xs text-muted">金币 {p.bonus > 0 && `+ ${p.bonus} 赠送`}</div>
                </div>
                {p.tag && <Badge tone="gold">{p.tag}</Badge>}
              </div>
              <div className="mt-4 flex items-end justify-between">
                <span className="font-serif text-xl font-bold text-primary">{p.price}</span>
                <Switch checked={p.active} onChange={() => toggleActive('package', p)} />
              </div>
              <div className="mt-4 flex gap-1 border-t border-line pt-3">
                <Button variant="ghost" size="sm" onClick={() => editPackage(p)}>编辑</Button>
                <Button variant="danger-ghost" size="sm" onClick={() => setConfirmDel({ kind: 'package', item: p })}>
                  删除
                </Button>
              </div>
            </Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {plans.map((p) => (
            <Card key={p.id} className={`p-5 ${!p.active ? 'opacity-60' : ''}`}>
              <div className="flex items-start justify-between">
                <div className="font-serif text-lg font-bold text-ink">{p.name}</div>
                {p.tag && <Badge tone="gold">{p.tag}</Badge>}
              </div>
              <div className="mt-3 flex items-baseline gap-2">
                <span className="font-serif text-2xl font-bold text-primary">{p.price}</span>
                <span className="text-xs text-muted">{p.period}</span>
              </div>
              {p.originalPrice && (
                <div className="text-xs text-faint line-through">{p.originalPrice}</div>
              )}
              <div className="mt-2 text-sm text-success">每日 +{p.dailyCoins} 金币</div>
              <div className="mt-4 flex items-center justify-between border-t border-line pt-3">
                <div className="flex gap-1">
                  <Button variant="ghost" size="sm" onClick={() => editPlan(p)}>编辑</Button>
                  <Button variant="danger-ghost" size="sm" onClick={() => setConfirmDel({ kind: 'plan', item: p })}>
                    删除
                  </Button>
                </div>
                <Switch checked={p.active} onChange={() => toggleActive('plan', p)} />
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* 编辑弹窗 */}
      <Modal
        open={!!modal}
        title={
          modal
            ? `${modal.mode === 'create' ? '新建' : '编辑'}${modal.kind === 'package' ? '充值套餐' : '会员套餐'}`
            : ''
        }
        onClose={() => setModal(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setModal(null)}>取消</Button>
            <Button onClick={save} disabled={saving}>{saving ? '保存中…' : '保存'}</Button>
          </>
        }
      >
        {modal?.kind === 'package' && (
          <div className="grid grid-cols-2 gap-4">
            <Input label="金币数" type="number" value={modal.form.coins}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, coins: e.target.value } })} />
            <Input label="赠送金币" type="number" value={modal.form.bonus}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, bonus: e.target.value } })} />
            <Input label="价格 (如 $4.99)" value={modal.form.price}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, price: e.target.value } })} />
            <Input label="角标 (可空)" value={modal.form.tag}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, tag: e.target.value } })} />
            <div className="col-span-2">
              <Input label="赠送说明 (如 +60 bonus)" value={modal.form.bonusLabel}
                onChange={(e) => setModal({ ...modal, form: { ...modal.form, bonusLabel: e.target.value } })} />
            </div>
            <div className="col-span-2 flex items-center justify-between rounded-[13px] bg-surface-2 px-4 py-3">
              <span className="text-sm text-ink">上架启用</span>
              <Switch checked={modal.form.active}
                onChange={(v) => setModal({ ...modal, form: { ...modal.form, active: v } })} />
            </div>
          </div>
        )}
        {modal?.kind === 'plan' && (
          <div className="grid grid-cols-2 gap-4">
            <Input label="名称" value={modal.form.name}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, name: e.target.value } })} />
            <Input label="计费周期 (如 /month)" value={modal.form.period}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, period: e.target.value } })} />
            <Input label="价格 (如 $9.99)" value={modal.form.price}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, price: e.target.value } })} />
            <Input label="原价 (可空)" value={modal.form.originalPrice}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, originalPrice: e.target.value } })} />
            <Input label="每日赠币" type="number" value={modal.form.dailyCoins}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, dailyCoins: e.target.value } })} />
            <Input label="角标 (可空)" value={modal.form.tag}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, tag: e.target.value } })} />
            <div className="col-span-2 flex items-center justify-between rounded-[13px] bg-surface-2 px-4 py-3">
              <span className="text-sm text-ink">上架启用</span>
              <Switch checked={modal.form.active}
                onChange={(v) => setModal({ ...modal, form: { ...modal.form, active: v } })} />
            </div>
          </div>
        )}
      </Modal>

      {/* 删除确认 */}
      <Modal
        open={!!confirmDel}
        title="删除确认"
        onClose={() => setConfirmDel(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmDel(null)}>取消</Button>
            <Button variant="danger" onClick={doDelete}>确认删除</Button>
          </>
        }
      >
        <p className="text-sm text-muted">确定删除该{confirmDel?.kind === 'package' ? '充值套餐' : '会员套餐'}吗？</p>
      </Modal>
    </>
  );
}
