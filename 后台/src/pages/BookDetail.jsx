import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { api } from '../api.js';
import { PageHeader } from '../components/Layout.jsx';
import {
  Button, Card, Badge, Input, Switch, Modal, Spinner, EmptyState,
} from '../components/ui.jsx';
import { useToast } from '../components/Toast.jsx';
import { GENRE_LABELS, STATUS_LABELS } from '../constants.js';

export default function BookDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const toast = useToast();
  const [book, setBook] = useState(null);
  const [chapters, setChapters] = useState([]);
  const [modal, setModal] = useState(null);
  const [saving, setSaving] = useState(false);
  const [confirmDel, setConfirmDel] = useState(null);

  async function load() {
    try {
      const b = await api.book(id);
      setBook(b);
      setChapters(b.chaptersList || []);
    } catch (e) {
      toast.error(e.message);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  function openCreate() {
    // 免费/VIP/金币由书籍付费配置自动派生，章节级无需填写
    setModal({ mode: 'create', form: { title: '', wordCount: 2200, published: true } });
  }
  function openEdit(ch) {
    setModal({ mode: 'edit', cid: ch.id, form: { ...ch } });
  }

  async function save() {
    const f = modal.form;
    setSaving(true);
    try {
      if (modal.mode === 'create') {
        await api.createChapter(id, f);
        toast.success('章节已新增');
      } else {
        await api.updateChapter(id, modal.cid, f);
        toast.success('章节已更新');
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
      await api.deleteChapter(id, confirmDel.id);
      toast.success('章节已删除');
      setConfirmDel(null);
      load();
    } catch (e) {
      toast.error(e.message);
    }
  }

  if (!book) return <Spinner />;
  const isFreeBook = Number(book.coinPrice) === 0;

  return (
    <>
      <button onClick={() => navigate('/books')} className="mb-3 text-sm text-muted hover:text-ink">
        ← 返回书籍列表
      </button>
      <PageHeader
        title={book.title}
        subtitle={`${book.author} · ${GENRE_LABELS[book.genre]} · ${STATUS_LABELS[book.status]}`}
        actions={<Button onClick={openCreate}>＋ 新增章节</Button>}
      />

      <div className="mb-4 grid grid-cols-2 gap-4 sm:grid-cols-5">
        <Card className="p-4">
          <div className="text-xs text-faint">章节总数</div>
          <div className="mt-1 font-serif text-2xl font-bold text-ink">{book.chapters}</div>
        </Card>
        <Card className="p-4">
          <div className="text-xs text-faint">已录入</div>
          <div className="mt-1 font-serif text-2xl font-bold text-ink">{chapters.length}</div>
        </Card>
        <Card className="p-4">
          <div className="text-xs text-faint">付费方式</div>
          <div className="mt-1 font-serif text-2xl font-bold text-ink">
            {isFreeBook ? '全书免费' : `VIP / ${book.coinPrice} 币`}
          </div>
          <div className="mt-1 text-xs text-faint">
            {isFreeBook ? '前台显示 Free，所有章节直接阅读' : `Pay ${book.coinPrice} coins`}
          </div>
        </Card>
        <Card className="p-4">
          <div className="text-xs text-faint">免费章节</div>
          <div className="mt-1 font-serif text-2xl font-bold text-ink">
            {isFreeBook ? '全部' : `前 ${book.freeChapters ?? 0} 章`}
          </div>
        </Card>
        <Card className="p-4">
          <div className="text-xs text-faint">评分</div>
          <div className="mt-1 font-serif text-2xl font-bold text-ink">★ {book.rating}</div>
        </Card>
      </div>

      <Card className="overflow-hidden">
        {chapters.length === 0 ? (
          <EmptyState icon="📖" title="还没有录入章节" hint="点击右上角新增章节" />
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">#</th>
                <th className="px-5 py-3 font-semibold">标题</th>
                <th className="px-5 py-3 font-semibold">访问</th>
                <th className="px-5 py-3 font-semibold">解锁条件</th>
                <th className="px-5 py-3 font-semibold">字数</th>
                <th className="px-5 py-3 font-semibold">发布</th>
                <th className="px-5 py-3 text-right font-semibold">操作</th>
              </tr>
            </thead>
            <tbody>
              {chapters.map((c) => (
                <tr key={c.id} className="border-t border-line/70 hover:bg-surface-2/50">
                  <td className="px-5 py-3 font-mono text-xs text-muted">{c.id}</td>
                  <td className="px-5 py-3 font-medium text-ink">{c.title}</td>
                  <td className="px-5 py-3">
                    {c.free ? <Badge tone="success">免费</Badge> : <Badge tone="primary">VIP/金币</Badge>}
                  </td>
                  <td className="px-5 py-3 text-muted">
                    {c.free ? (isFreeBook ? '全书免费' : '—') : `VIP 全书解锁；非会员 Pay ${c.coins} coins`}
                  </td>
                  <td className="px-5 py-3 text-muted">{c.wordCount}</td>
                  <td className="px-5 py-3">
                    {c.published ? <Badge tone="neutral">已发布</Badge> : <Badge tone="warn">草稿</Badge>}
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex justify-end gap-1">
                      <Button variant="ghost" size="sm" onClick={() => openEdit(c)}>编辑</Button>
                      <Button variant="danger-ghost" size="sm" onClick={() => setConfirmDel(c)}>删除</Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>

      <Modal
        open={!!modal}
        title={modal?.mode === 'create' ? '新增章节' : '编辑章节'}
        onClose={() => setModal(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setModal(null)}>取消</Button>
            <Button onClick={save} disabled={saving}>{saving ? '保存中…' : '保存'}</Button>
          </>
        }
      >
        {modal && (
          <div className="space-y-4">
            <Input label="章节标题" value={modal.form.title}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, title: e.target.value } })} />
            <Input label="字数" type="number" min="0" value={modal.form.wordCount}
              onChange={(e) => setModal({ ...modal, form: { ...modal.form, wordCount: Number(e.target.value) } })} />
            <p className="rounded-[13px] bg-surface-2 px-4 py-3 text-xs text-muted">
              {isFreeBook
                ? '当前书籍为全书免费，新增章节会自动免费，前台不会出现 Unlock。'
                : `VIP 用户全书已解锁；非会员余额足够时前台显示 "Pay ${book.coinPrice} coins"，余额不足时显示 "Top up to unlock"。免费前 ${book.freeChapters ?? 0} 章。`}
              章节的免费/付费状态由书籍付费配置自动派生。
            </p>
            <div className="flex items-center justify-between rounded-[13px] bg-surface-2 px-4 py-3">
              <span className="text-sm text-ink">立即发布</span>
              <Switch checked={modal.form.published}
                onChange={(v) => setModal({ ...modal, form: { ...modal.form, published: v } })} />
            </div>
          </div>
        )}
      </Modal>

      <Modal
        open={!!confirmDel}
        title="删除章节"
        onClose={() => setConfirmDel(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmDel(null)}>取消</Button>
            <Button variant="danger" onClick={doDelete}>确认删除</Button>
          </>
        }
      >
        <p className="text-sm text-muted">
          确定删除章节「<span className="font-semibold text-ink">{confirmDel?.title}</span>」吗？
        </p>
      </Modal>
    </>
  );
}
