import * as React from "react";
import { useState } from 'react';
import { RefreshCw, BookOpen, ChevronRight } from './icons';
import { Cover } from './cover';
import { LIBRARY_BOOKS, type Book } from '../data';

interface LibraryProps {
  onBook: (book: Book) => void;
  onRead: (book: Book) => void;
}

const TABS = ['Reading', 'Unlocked', 'Finished'] as const;
type TabLabel = typeof TABS[number];

export function Library({ onBook, onRead }: LibraryProps) {
  const [tab, setTab] = useState<TabLabel>('Reading');

  const readingBooks = LIBRARY_BOOKS.filter(b => b.progress > 0 && b.progress < 100);
  const finishedBooks = LIBRARY_BOOKS.filter(b => b.progress === 100);
  const continueBook = readingBooks[0];

  return (
    <div
      className="flex flex-col h-full overflow-hidden"
      style={{ background: 'var(--el-bg)', fontFamily: 'Inter, sans-serif' }}
    >
      {/* header */}
      <div className="px-5 pt-12 pb-4 flex-shrink-0">
        <p className="text-[10px] font-semibold uppercase tracking-[0.12em] mb-0.5" style={{ color: 'var(--el-muted)' }}>Library</p>
        <div className="flex items-center justify-between">
          <h1 className="text-[26px] font-semibold leading-none" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
            My books
          </h1>
          <div
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full"
            style={{ background: 'oklch(0.88 0.06 150)' }}
          >
            <RefreshCw className="w-3 h-3" style={{ color: 'oklch(0.30 0.12 150)' } as React.CSSProperties} />
            <span className="text-[11px] font-semibold" style={{ color: 'oklch(0.30 0.12 150)' }}>Synced</span>
          </div>
        </div>
      </div>

      {/* continue reading */}
      {continueBook && tab === 'Reading' && (
        <div className="px-5 mb-3 flex-shrink-0">
          <button
            onClick={() => onRead(continueBook)}
            className="w-full flex items-center gap-3.5 p-4 rounded-[18px] text-left transition-all active:scale-[0.99]"
            style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)', boxShadow: '0 2px 12px rgba(80,20,10,0.06)' }}
          >
            <Cover genre={continueBook.genre} title={continueBook.title} author={continueBook.author} size="md" />
            <div className="flex-1 min-w-0">
              <p className="text-[10px] font-semibold uppercase tracking-wider mb-1" style={{ color: 'var(--el-muted)' }}>Continue reading</p>
              <p className="text-[14px] font-semibold leading-tight mb-1" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
                {continueBook.title}
              </p>
              <p className="text-[12px] mb-2.5" style={{ color: 'var(--el-muted)' }}>Ch. {continueBook.currentChapter}</p>
              <div className="flex items-center gap-2">
                <div className="flex-1 h-1.5 rounded-full overflow-hidden" style={{ background: 'var(--el-surface-3)' }}>
                  <div className="h-full rounded-full" style={{ width: `${continueBook.progress}%`, background: 'var(--el-primary)' }} />
                </div>
                <span className="text-[11px] font-semibold" style={{ color: 'var(--el-primary-ink)' }}>{continueBook.progress}%</span>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 flex-shrink-0 opacity-30" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
          </button>
        </div>
      )}

      {/* tabs */}
      <div
        className="flex gap-1 px-5 mb-1 flex-shrink-0"
        style={{ borderBottom: '1px solid var(--el-line)' }}
      >
        {TABS.map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className="pb-3 pt-1 px-1 text-[13px] font-semibold transition-all mr-4 relative"
            style={{ color: tab === t ? 'var(--el-primary)' : 'var(--el-faint)' }}
          >
            {t}
            {tab === t && (
              <span
                className="absolute bottom-0 left-0 right-0 h-[2px] rounded-full"
                style={{ background: 'var(--el-primary)' }}
              />
            )}
          </button>
        ))}
      </div>

      {/* list */}
      <div className="flex-1 overflow-y-auto px-5 pt-2" style={{ scrollbarWidth: 'none' }}>
        {tab === 'Reading' && (
          <div className="flex flex-col gap-2 pb-6">
            {readingBooks.map(book => (
              <BookRow key={book.id} book={book} onBook={onBook} onRead={onRead} showProgress />
            ))}
          </div>
        )}
        {tab === 'Unlocked' && (
          <div className="flex flex-col gap-2 pb-6">
            {LIBRARY_BOOKS.map(book => (
              <BookRow key={book.id} book={book} onBook={onBook} onRead={onRead} showProgress />
            ))}
          </div>
        )}
        {tab === 'Finished' && (
          finishedBooks.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <div className="w-16 h-16 rounded-full flex items-center justify-center mb-4" style={{ background: 'var(--el-surface-2)' }}>
                <BookOpen className="w-8 h-8 opacity-30" style={{ color: 'var(--el-ink)' } as React.CSSProperties} />
              </div>
              <p className="text-[15px] font-semibold mb-1" style={{ color: 'var(--el-ink)' }}>Nothing finished yet</p>
              <p className="text-[13px] leading-relaxed" style={{ color: 'var(--el-muted)' }}>Books you've completed will appear here.</p>
            </div>
          ) : (
            <div className="flex flex-col gap-2 pb-6">
              {finishedBooks.map(book => (
                <BookRow key={book.id} book={book} onBook={onBook} onRead={onRead} />
              ))}
            </div>
          )
        )}
      </div>
    </div>
  );
}

function BookRow({ book, onBook, onRead, showProgress = false }: {
  book: typeof LIBRARY_BOOKS[0];
  onBook: (b: Book) => void;
  onRead: (b: Book) => void;
  showProgress?: boolean;
}) {
  return (
    <div
      className="flex items-center gap-3 p-3 rounded-[18px] transition-all"
      style={{ background: 'var(--el-surface)', border: '1px solid var(--el-line)' }}
    >
      <button onClick={() => onBook(book)} className="flex-shrink-0">
        <Cover genre={book.genre} title={book.title} author={book.author} size="sm" />
      </button>
      <div className="flex-1 min-w-0">
        <p className="text-[13px] font-semibold leading-tight mb-0.5" style={{ fontFamily: 'Newsreader, serif', color: 'var(--el-ink)' }}>
          {book.title}
        </p>
        <p className="text-[11px] mb-2" style={{ color: 'var(--el-muted)' }}>{book.author}</p>
        {showProgress && (
          <div className="flex items-center gap-2">
            <div className="flex-1 h-1 rounded-full overflow-hidden" style={{ background: 'var(--el-surface-3)' }}>
              <div className="h-full rounded-full transition-all" style={{ width: `${book.progress}%`, background: 'var(--el-primary)' }} />
            </div>
            <span className="text-[10px] font-medium" style={{ color: 'var(--el-muted)' }}>{book.progress}%</span>
          </div>
        )}
      </div>
      <button
        onClick={() => onRead(book)}
        className="flex-shrink-0 px-3.5 py-1.5 rounded-full text-[12px] font-semibold transition-all active:scale-90"
        style={{ background: 'var(--el-primary)', color: 'var(--el-on-primary)', boxShadow: '0 2px 8px oklch(0.52 0.158 16 / 0.25)' }}
      >
        Read
      </button>
    </div>
  );
}
