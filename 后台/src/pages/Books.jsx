import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import {
  Button, Card, Badge, Input, Select, Textarea, Modal, Spinner, EmptyState, Pagination,
} from '../components/ui.jsx';
import { useToast } from '../components/Toast.jsx';
import { GENRE_LABELS, STATUS_LABELS } from '../constants.js';

const emptyForm = {
  title: '', author: '', genre: 'werewolf', status: 'ongoing',
  rating: 4.5, reads: '0', chapters: 0, tropes: '', blurb: '', badge: '', rank: '',
  coinPrice: 38, freeChapters: 5,
};

export default function Books() {
  const toast = useToast();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [filters, setFilters] = useState({ q: '', genre: '', status: '', page: 1, pageSize: 10 });
  const [modal, setModal] = useState(null); // {mode, form}
  const [saving, setSaving] = useState(false);
  const [confirmDel, setConfirmDel] = useState(null);

  async function load() {
    setData(null);
    try {
      setData(await api.books(filters));
    } catch (e) {
      toast.error(e.message);
    }
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filters]);

  const setFilter = (patch) => setFilters((f) => ({ ...f, ...patch, page: patch.page ?? 1 }));

  function openCreate() {
    setModal({ mode: 'create', form: { ...emptyForm } });
  }
  function openEdit(book) {
    setModal({
      mode: 'edit',
      id: book.id,
      form: {
        ...book,
        tropes: (book.tropes || []).join(', '),
        badge: book.badge || '',
        rank: book.rank ?? '',
        coinPrice: book.coinPrice ?? 38,
        freeChapters: book.freeChapters ?? 5,
      },
    });
  }

  async function save() {
    const f = modal.form;
    if (!f.title || !f.author) return toast.error('标题和作者必填');
    if (!(Number(f.coinPrice) > 0)) {
      return toast.error('单章解锁金币必须大于 0');
    }
    setSaving(true);
    try {
      const payload = {
        ...f,
        rating: Number(f.rating),
        chapters: Number(f.chapters),
        rank: f.rank === '' ? null : Number(f.rank),
        badge: f.badge || null,
        tropes: f.tropes.split(',').map((s) => s.trim()).filter(Boolean),
        coinPrice: Number(f.coinPrice),
        freeChapters: Math.max(0, Number(f.freeChapters) || 0),
      };
      if (modal.mode === 'create') {
        await api.createBook(payload);
        toast.success('书籍已创建');
      } else {
        await api.updateBook(modal.id, payload);
        toast.success('书籍已更新');
      }
      setModal(null);
      load();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setSaving(false);
    }
  }

  async function doDelete() {
    try {
      await api.deleteBook(confirmDel.id);
      toast.success('书籍已删除');
      setConfirmDel(null);
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  return (
    <>
      <PageHeader
        title="书籍管理"
        subtitle="维护书库、题材、连载状态与章节"
        actions={<Button onClick={openCreate}>＋ 新建书籍</Button>}
      />

      <Card className="mb-4 flex flex-wrap items-center gap-3 p-4">
        <input
          value={filters.q}
          onChange={(e) => setFilter({ q: e.target.value })}
          placeholder="搜索书名 / 作者…"
          className="min-w-52 flex-1 rounded-[13px] border border-line bg-surface-2 px-3.5 py-2.5 text-sm focus:border-primary focus:bg-surface focus:outline-none"
        />
        <select
          value={filters.genre}
          onChange={(e) => setFilter({ genre: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none"
        >
          <option value="">全部题材</option>
          {Object.entries(GENRE_LABELS).map(([v, l]) => (
            <option key={v} value={v}>{l}</option>
          ))}
        </select>
        <select
          value={filters.status}
          onChange={(e) => setFilter({ status: e.target.value })}
          className="rounded-[13px] border border-line bg-surface-2 px-3 py-2.5 text-sm focus:outline-none"
        >
          <option value="">全部状态</option>
          {Object.entries(STATUS_LABELS).map(([v, l]) => (
            <option key={v} value={v}>{l}</option>
          ))}
        </select>
      </Card>

      <Card className="overflow-hidden">
        {!data ? (
          <Spinner />
        ) : data.items.length === 0 ? (
          <EmptyState title="没有符合条件的书籍" hint="试试调整筛选或新建一本" />
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">书名 / 作者</th>
                <th className="px-5 py-3 font-semibold">题材</th>
                <th className="px-5 py-3 font-semibold">状态</th>
                <th className="px-5 py-3 font-semibold">付费方式</th>
                <th className="px-5 py-3 font-semibold">章节</th>
                <th className="px-5 py-3 font-semibold">评分</th>
                <th className="px-5 py-3 font-semibold">阅读量</th>
                <th className="px-5 py-3 text-right font-semibold">操作</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((b) => (
                <tr key={b.id} className="border-t border-line/70 hover:bg-surface-2/50">
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-ink">{b.title}</span>
                      {b.badge && <Badge tone="gold">{b.badge}</Badge>}
                    </div>
                    <div className="text-xs text-muted">{b.author}</div>
                  </td>
                  <td className="px-5 py-3 text-muted">{GENRE_LABELS[b.genre] || b.genre}</td>
                  <td className="px-5 py-3">
                    <Badge tone={b.status === 'complete' ? 'primary' : 'neutral'}>
                      {STATUS_LABELS[b.status]}
                    </Badge>
                  </td>
                  <td className="px-5 py-3">
                    <Badge tone="primary">VIP 全书解锁 / 非会员 {b.coinPrice} 币·章</Badge>
                    <div className="mt-1 text-xs text-faint">
                      免费前 {b.freeChapters ?? 0} 章 · 前台按钮 Pay {b.coinPrice} coins
                    </div>
                  </td>
                  <td className="px-5 py-3 text-muted">{b.chapters}</td>
                  <td className="px-5 py-3 font-semibold text-ink">★ {b.rating}</td>
                  <td className="px-5 py-3 text-muted">{b.reads}</td>
                  <td className="px-5 py-3">
                    <div className="flex justify-end gap-1">
                      <Button variant="ghost" size="sm" onClick={() => navigate(`/books/${b.id}`)}>
                        章节
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => openEdit(b)}>
                        编辑
                      </Button>
                      <Button variant="danger-ghost" size="sm" onClick={() => setConfirmDel(b)}>
                        删除
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
            <Pagination
              page={data.page}
              pageSize={data.pageSize}
              total={data.total}
              onPage={(p) => setFilter({ page: p })}
            />
          </div>
        )}
      </Card>

      {/* 新建 / 编辑弹窗 */}
      <Modal
        open={!!modal}
        wide
        title={modal?.mode === 'create' ? '新建书籍' : '编辑书籍'}
        onClose={() => setModal(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setModal(null)}>取消</Button>
            <Button onClick={save} disabled={saving}>{saving ? '保存中…' : '保存'}</Button>
          </>
        }
      >
        {modal && (
          <div className="grid grid-cols-2 gap-4">
            <Input label="书名" value={modal.form.title}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, title: e.target.value } })} />
            <Input label="作者" value={modal.form.author}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, author: e.target.value } })} />
            <Select label="题材" value={modal.form.genre}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, genre: e.target.value } })}
              options={Object.entries(GENRE_LABELS).map(([value, label]) => ({ value, label }))} />
            <Select label="状态" value={modal.form.status}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, status: e.target.value } })}
              options={Object.entries(STATUS_LABELS).map(([value, label]) => ({ value, label }))} />
            <Input label="评分" type="number" step="0.1" min="0" max="5" value={modal.form.rating}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, rating: e.target.value } })} />
            <Input label="章节总数" type="number" min="0" value={modal.form.chapters}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, chapters: e.target.value } })} />
            <Input label="阅读量 (如 8.2M)" value={modal.form.reads}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, reads: e.target.value } })} />
            <Input label="榜单排名 (可空)" type="number" value={modal.form.rank}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, rank: e.target.value } })} />
            <Input label="角标 badge (如 hot，可空)" value={modal.form.badge}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, badge: e.target.value } })} />
            <Input label="标签 tropes (逗号分隔)" value={modal.form.tropes}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, tropes: e.target.value } })} />
            {/* 付费配置：会员全场畅读，金币仅用于非会员按章购买。 */}
            <div className="col-span-2 rounded-[13px] border border-line bg-surface-2/60 p-4">
              <div className="mb-3 text-xs font-semibold uppercase tracking-wide text-faint">付费配置</div>
              <div className="grid grid-cols-2 gap-4">
                <Input label="单章解锁金币" type="number" min="1" value={modal.form.coinPrice}
                  onChange={(e) => setModal({ ...modal, form: { ...modal.form, coinPrice: e.target.value } })} />
                <Input label="免费章节数" type="number" min="0" value={modal.form.freeChapters}
                  onChange={(e) => setModal({ ...modal, form: { ...modal.form, freeChapters: e.target.value } })} />
              </div>
              <p className="mt-2 text-xs text-muted">
                前台规则：VIP 用户触发解锁时提示 "You're already VIP. Full book unlocked."，后续章节直接阅读并显示 VIP 小标。
                非会员余额足够时显示 "Pay {modal.form.coinPrice} coins"，余额不足时显示 "Top up to unlock" 并进入充值页。
              </p>
            </div>
            <div className="col-span-2">
              <Textarea label="简介" rows={3} value={modal.form.blurb}
                onChange={(e) => setModal({ ...modal, form: { ...modal.form, blurb: e.target.value } })} />
            </div>
          </div>
        )}
      </Modal>

      {/* 删除确认 */}
      <Modal
        open={!!confirmDel}
        title="删除书籍"
        onClose={() => setConfirmDel(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmDel(null)}>取消</Button>
            <Button variant="danger" onClick={doDelete}>确认删除</Button>
          </>
        }
      >
        <p className="text-sm text-muted">
          确定要删除《<span className="font-semibold text-ink">{confirmDel?.title}</span>》吗？此操作将同时移除其所有章节，且不可恢复。
        </p>
      </Modal>
    </>
  );
}
