"use strict";

const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));

/* ============================================================
   Icon system (inline SVG, currentColor)
   ============================================================ */
const S = (p, o = "") => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.85" stroke-linecap="round" stroke-linejoin="round" ${o}>${p}</svg>`;
const ICONS = {
  "chevron-left": S('<path d="M15 6l-6 6 6 6"/>'),
  "chevron-right": S('<path d="M9 6l6 6-6 6"/>'),
  search: S('<circle cx="11" cy="11" r="7"/><path d="M21 21l-3.6-3.6"/>'),
  home: S('<path d="M4 11l8-7 8 7"/><path d="M6 10v9a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1v-9"/>'),
  books: S('<path d="M5 4h6v16H5z"/><path d="M11 6l5-1 3 14-5 1"/>'),
  user: S('<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>'),
  bell: S('<path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6"/><path d="M10 20a2 2 0 0 0 4 0"/>'),
  coin: S('<path d="M12 3l8 6-8 12-8-12z" fill="currentColor" stroke="none"/><path d="M8.5 9h7" stroke="#fff" stroke-width="1.4" opacity=".7"/>'),
  spark: S('<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z" fill="currentColor" stroke="none"/>'),
  sliders: S('<path d="M4 7h10"/><path d="M18 7h2"/><circle cx="16" cy="7" r="2"/><path d="M4 17h2"/><path d="M10 17h10"/><circle cx="8" cy="17" r="2"/>'),
  play: S('<path d="M7 5l12 7-12 7z" fill="currentColor" stroke="none"/>'),
  heart: S('<path d="M12 20s-7-4.5-9.5-9C1 8 2.5 4.5 6 4.5c2 0 3.2 1.2 4 2.3.8-1.1 2-2.3 4-2.3 3.5 0 5 3.5 3.5 6.5C19 15.5 12 20 12 20z"/>'),
  "heart-fill": S('<path d="M12 20s-7-4.5-9.5-9C1 8 2.5 4.5 6 4.5c2 0 3.2 1.2 4 2.3.8-1.1 2-2.3 4-2.3 3.5 0 5 3.5 3.5 6.5C19 15.5 12 20 12 20z" fill="currentColor" stroke="none"/>'),
  list: S('<path d="M8 6h12"/><path d="M8 12h12"/><path d="M8 18h12"/><path d="M4 6h.01"/><path d="M4 12h.01"/><path d="M4 18h.01"/>'),
  text: S('<path d="M5 7V5h14v2"/><path d="M12 5v14"/><path d="M9 19h6"/>'),
  sync: S('<path d="M20 11a8 8 0 0 0-14-5l-2 2"/><path d="M4 13a8 8 0 0 0 14 5l2-2"/><path d="M4 4v4h4"/><path d="M20 20v-4h-4"/>'),
  plus: S('<path d="M12 5v14"/><path d="M5 12h14"/>'),
  gift: S('<path d="M20 12v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8"/><path d="M2 8h20v4H2z"/><path d="M12 8v13"/><path d="M12 8S10.5 4 8 4 5 7 7 8M12 8s1.5-4 4-4 3 3 1 4"/>'),
  lock: S('<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>'),
  clock: S('<circle cx="12" cy="12" r="8"/><path d="M12 8v4l3 2"/>'),
  settings: S('<circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.4-2.3 1a7 7 0 0 0-2-1.2L14.2 2H9.8L9.4 4.5a7 7 0 0 0-2 1.2l-2.3-1-2 3.4 2 1.5A7 7 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.4 2.3-1a7 7 0 0 0 2 1.2l.4 2.5h4.4l.4-2.5a7 7 0 0 0 2-1.2l2.3 1 2-3.4-2-1.5c.1-.4.1-.8.1-1.2z"/>'),
  star: S('<path d="M12 3l2.6 5.6 6.1.7-4.5 4.1 1.2 6L12 16.8 6.6 19.4l1.2-6L3.3 9.3l6.1-.7z" fill="currentColor" stroke="none"/>'),
  flame: S('<path d="M12 3c1 4 5 5 5 9a5 5 0 0 1-10 0c0-2 1-3 2-4 .5 2 2 2 2 2 0-3-1-5 1-7z" fill="currentColor" stroke="none"/>'),
  check: S('<path d="M5 12l4.5 4.5L19 7"/>'),
  "check-circle": S('<circle cx="12" cy="12" r="9"/><path d="M8 12l2.5 2.5L16 9"/>'),
  globe: S('<circle cx="12" cy="12" r="8"/><path d="M3 12h18"/><path d="M12 4c2.5 2.5 2.5 13 0 16M12 4c-2.5 2.5-2.5 13 0 16"/>'),
  shield: S('<path d="M12 3l7 3v6c0 4-3 7-7 9-4-2-7-5-7-9V6z"/>'),
  trash: S('<path d="M4 7h16"/><path d="M9 7V4h6v3"/><path d="M6 7l1 13h10l1-13"/>'),
  bookmark: S('<path d="M7 4h10a1 1 0 0 1 1 1v15l-6-4-6 4V5a1 1 0 0 1 1-1z"/>'),
  language: S('<path d="M4 6h10"/><path d="M9 4c0 6-3 10-6 12"/><path d="M6 9c1.5 3 4 5 7 6"/><path d="M14 20l4-9 4 9"/><path d="M15.5 16h5"/>'),
  mail: S('<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M4 7l8 6 8-6"/>'),
  wallet: S('<rect x="3" y="6" width="18" height="13" rx="2"/><path d="M16 12h3"/><path d="M3 9h13a2 2 0 0 1 0 0"/>'),
  google: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="#4285F4" d="M23.5 12.3c0-.8-.1-1.6-.2-2.3H12v4.5h6.5a5.5 5.5 0 0 1-2.4 3.6v3h3.9c2.2-2.1 3.5-5.2 3.5-8.8z"/><path fill="#34A853" d="M12 24c3.2 0 6-1.1 7.9-2.9l-3.9-3c-1 .7-2.4 1.2-4 1.2-3.1 0-5.8-2.1-6.7-5H1.3v3.1A12 12 0 0 0 12 24z"/><path fill="#FBBC05" d="M5.3 14.3a7.2 7.2 0 0 1 0-4.6V6.6H1.3a12 12 0 0 0 0 10.8l4-3.1z"/><path fill="#EA4335" d="M12 4.8c1.8 0 3.3.6 4.6 1.8l3.4-3.4A12 12 0 0 0 1.3 6.6l4 3.1C6.2 6.9 8.9 4.8 12 4.8z"/></svg>',
  facebook: '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="#1877F2" d="M24 12a12 12 0 1 0-13.9 11.9v-8.4H7.1V12h3V9.4c0-3 1.8-4.7 4.5-4.7 1.3 0 2.7.2 2.7.2v3h-1.5c-1.5 0-2 .9-2 1.9V12h3.3l-.5 3.5h-2.8v8.4A12 12 0 0 0 24 12z"/></svg>',
};
function injectIcons(root = document) {
  $$("[data-icon]", root).forEach((el) => {
    if (el.dataset.ready) return;
    el.innerHTML = ICONS[el.dataset.icon] || "";
    el.dataset.ready = "1";
  });
}

/* ============================================================
   Data
   ============================================================ */
const BOOKS = [
  { id: "alpha", title: "The Alpha's Forbidden Mate", author: "Elena Vale", g: "Werewolf", cls: "c-werewolf", rate: "4.8", reads: "31M", ch: 128, status: "ongoing", badge: "Trending", blurb: "Mara returns to the pack that exiled her and finds the Alpha who ruined her is her fated mate." },
  { id: "billionaire", title: "Married to the Billionaire's Shadow", author: "Cora Sloane", g: "CEO", cls: "c-ceo", rate: "4.7", reads: "18M", ch: 96, status: "ongoing", badge: "Editor's pick", blurb: "A contract marriage to a cold heir turns into a dangerous game of real feelings." },
  { id: "crown", title: "Crown of Ash and Thorns", author: "Isolde Frost", g: "Romantasy", cls: "c-romantasy", rate: "4.9", reads: "22M", ch: 140, status: "ongoing", badge: "Trending", blurb: "A deposed queen returns to a ruined court with a vow of revenge and a stranger's bargain." },
  { id: "luna", title: "His Reluctant Luna", author: "Bree Hollow", g: "Werewolf", cls: "c-werewolf", rate: "4.6", reads: "9M", ch: 88, status: "ongoing", badge: null, blurb: "A rejected mate, a slow burn, and a pack that won't let her leave." },
  { id: "vampire", title: "Midnight with the Vampire King", author: "Lena Crowe", g: "Vampire", cls: "c-vampire", rate: "4.8", reads: "12M", ch: 110, status: "ongoing", badge: null, blurb: "Gothic romance, forbidden bloodlines, and a throne built on secrets." },
  { id: "reborn", title: "Reborn as the Tyrant's Wife", author: "Mei Lin", g: "Reborn", cls: "c-reborn", rate: "4.7", reads: "14M", ch: 132, status: "complete", badge: null, blurb: "A second chance inside the palace, and a husband she swore to destroy." },
  { id: "secret", title: "The CEO's Secret Bride", author: "Nora Quinn", g: "Modern", cls: "c-modern", rate: "4.5", reads: "7M", ch: 74, status: "ongoing", badge: null, blurb: "A hidden marriage goes public the moment she decides to walk away." },
  { id: "heiress", title: "The Heiress He Bought", author: "Dahlia Ren", g: "Billionaire", cls: "c-ceo", rate: "4.6", reads: "11M", ch: 102, status: "ongoing", badge: null, blurb: "High-stakes inheritance, fake vows, and a man who never loses." },
];
const byId = (id) => BOOKS.find((b) => b.id === id) || BOOKS[0];
const TASTES = ["Werewolf", "CEO / Billionaire", "Reborn", "Vampire", "Romantasy", "Fated mates", "Contract marriage", "Second chance", "Enemies to lovers", "Forbidden love"];

/* ============================================================
   Cover renderer (CSS art, no images)
   ============================================================ */
function cover(b, opts = {}) {
  let badge = "";
  if (opts.badge) {
    const cls = opts.badge === "complete" ? "cv-badge cv-badge--ongoing" : "cv-badge";
    const ic = opts.badge === "complete" ? '<span data-icon="check"></span>' : '<span data-icon="flame"></span>';
    const txt = opts.badge === "complete" ? "Complete" : "Hot";
    badge = `<span class="${cls}">${ic}${txt}</span>`;
  }
  return `<span class="cover ${b.cls}" role="img" aria-label="${b.title} cover">${badge}<span class="cv-meta"><span class="cv-t">${b.title}</span><span class="cv-a">${b.author}</span></span></span>`;
}
const meta = (b) => `<span class="star" data-icon="star"></span>${b.rate} · ${b.reads}`;

/* ============================================================
   Home rendering
   ============================================================ */
function renderHome() {
  $("#onb-hero").innerHTML = ["crown", "alpha", "vampire"].map((id) => cover(byId(id))).join("");

  $("#hero-rail").innerHTML = ["alpha", "crown", "billionaire"].map((id) => {
    const b = byId(id);
    return `<button class="hero-card" type="button" data-route="detail" data-book="${b.id}">
      ${cover(b)}
      <span class="hero-info">
        <span class="hero-tag">${b.badge || "Featured"}</span>
        <span class="hero-title">${b.title}</span>
        <span class="hero-blurb">${b.blurb}</span>
        <span class="hero-meta"><span class="star" data-icon="star"></span>${b.rate} · ${b.reads} reads · ${b.ch} ch</span>
      </span>
    </button>`;
  }).join("");

  $("#row-charts").innerHTML = ["crown", "alpha", "billionaire", "vampire", "reborn"].map((id, i) => {
    const b = byId(id);
    return `<button class="rank-card ${i === 0 ? "top" : ""}" type="button" data-route="detail" data-book="${b.id}">
      <span class="rank-num">${i + 1}</span>
      ${cover(b, { badge: i < 2 ? "hot" : null })}
      <b>${b.title}</b>
      <span class="book-meta">${meta(b)}</span>
    </button>`;
  }).join("");

  $("#row-new").innerHTML = ["luna", "secret", "heiress", "reborn"].map((id) => {
    const b = byId(id);
    return `<button class="book" type="button" data-route="detail" data-book="${b.id}">
      ${cover(b, { badge: b.status === "complete" ? "complete" : null })}
      <b>${b.title}</b>
      <span class="book-meta">${meta(b)}</span>
    </button>`;
  }).join("");

  injectIcons($("[data-view='home']"));
  injectIcons($("[data-view='onboarding']"));
}

/* ----- waterfall feed with skeleton + infinite scroll ----- */
let feedIndex = 0;
let feedLoading = false;
const feedTags = ["Slow burn", "Fated mates", "Revenge arc", "Forbidden love", "Second chance", "Enemies to lovers", "Possessive hero", "Strong heroine"];

function skeletonCards(n) {
  let html = "";
  for (let i = 0; i < n; i++) {
    html += `<div class="sk-card"><div class="sk sk-thumb"></div><div class="sk-lines"><div class="sk sk-line"></div><div class="sk sk-line s"></div></div></div>`;
  }
  return html;
}
function feedCards(n) {
  let html = "";
  for (let i = 0; i < n; i++) {
    const b = BOOKS[(feedIndex + i) % BOOKS.length];
    const tag = feedTags[(feedIndex + i) % feedTags.length];
    const tall = (feedIndex + i) % 3 === 0;
    html += `<button class="feed-card" type="button" data-route="detail" data-book="${b.id}">
      ${cover(b)}
      <span class="fc-body">
        <span class="fc-tag">${tag}</span>
        <span class="fc-title">${b.title}</span>
        <span class="fc-blurb">${tall ? b.blurb : b.blurb.split(",")[0] + "."}</span>
        <span class="fc-meta">${meta(b)}</span>
      </span>
    </button>`;
  }
  feedIndex += n;
  return html;
}
function loadFeed(n = 6) {
  if (feedLoading) return;
  feedLoading = true;
  const feed = $("#discover-feed");
  const sk = document.createElement("div");
  sk.style.display = "contents";
  sk.innerHTML = skeletonCards(n);
  feed.appendChild(sk);
  setTimeout(() => {
    sk.remove();
    feed.insertAdjacentHTML("beforeend", feedCards(n));
    injectIcons(feed);
    feedLoading = false;
  }, 520);
}

/* ============================================================
   Library / Wallet / Profile rendering
   ============================================================ */
function renderLibrary() {
  const b = byId("alpha");
  $("#continue-card").innerHTML = `${cover(b)}
    <span class="cc-info">
      <span class="cc-kicker">Continue reading</span>
      <span class="cc-title">${b.title}</span>
      <span class="cc-sub">Chapter 12 · 64% complete</span>
      <span class="cc-bar"><i style="width:64%"></i></span>
      <span class="cc-btn"><span data-icon="play"></span>Continue</span>
    </span>`;
  const shelf = [
    { id: "billionaire", sub: "Chapter 28 · 42 unread", flag: "new", label: "New" },
    { id: "vampire", sub: "Chapter 9 · 2 unlocked", flag: "locked", label: "Locked" },
    { id: "reborn", sub: "Finished · reread anytime", flag: "saved", label: "Saved" },
    { id: "crown", sub: "Updates every Friday", flag: "saved", label: "Saved" },
  ];
  $("#library-list").innerHTML = shelf.map((s) => {
    const b = byId(s.id);
    return `<button class="list-book" type="button" data-route="detail" data-book="${b.id}">
      ${cover(b)}
      <span class="lb-info"><span class="lb-title">${b.title}</span><span class="lb-sub">${s.sub}</span></span>
      <span class="lb-flag ${s.flag}">${s.label}</span>
    </button>`;
  }).join("");
  injectIcons($("[data-view='library']"));
}

const PACKS = [
  { coins: "300 coins", bonus: "First-time price", price: "$0.99", tag: "Starter" },
  { coins: "600 coins", bonus: "+60 bonus", price: "$4.99", tag: null },
  { coins: "1,400 coins", bonus: "+240 bonus", price: "$9.99", tag: "Best value", best: true },
  { coins: "3,200 coins", bonus: "+720 bonus", price: "$19.99", tag: null },
];
function renderWallet() {
  $("#wallet-packs").innerHTML = PACKS.slice(1, 3).map((p) => packRow(p)).join("");
  $("#recharge-packs").innerHTML = PACKS.map((p, i) => packRow(p, i === 2)).join("");
  injectIcons($("[data-view='wallet']"));
  injectIcons($("[data-sheet='recharge']"));
}
function packRow(p, selected) {
  return `<button class="pack-row ${p.best ? "best" : ""} ${selected ? "selected" : ""}" type="button" data-open-recharge>
    <span class="pack-info"><span class="pack-ic" data-icon="coin"></span><span><b>${p.coins}</b><small>${p.bonus}</small></span></span>
    <span class="pack-price">${p.price}${p.tag ? `<span class="pack-tag">${p.tag}</span>` : ""}</span>
  </button>`;
}

function renderProfile() {
  const items = [
    { ic: "wallet", label: "Wallet & purchases", val: "1,240", page: "purchase-history" },
    { ic: "lock", label: "Transactions", val: "", page: "wallet-history" },
    { ic: "bell", label: "Messages", val: "3", page: "message-center" },
    { ic: "sliders", label: "Notifications", val: "On", page: "notifications" },
    { ic: "language", label: "Language", val: "English", page: "language" },
    { ic: "shield", label: "Push management", val: "", page: "push-management" },
    { ic: "lock", label: "Privacy & data", val: "", page: "privacy" },
    { ic: "trash", label: "Delete account", val: "", page: "delete-account", danger: true },
  ];
  $("#profile-menu").innerHTML = items.map((m) => `
    <button class="menu-item ${m.danger ? "danger" : ""}" type="button" data-subpage="${m.page}">
      <span class="menu-ic" data-icon="${m.ic}"></span>
      <span class="menu-label">${m.label}</span>
      <span class="menu-val">${m.val || ""}<span data-icon="chevron-right"></span></span>
    </button>`).join("");
  injectIcons($("[data-view='profile']"));
}

/* ============================================================
   Detail rendering
   ============================================================ */
let currentBook = byId("alpha");
function renderDetail(b) {
  currentBook = b;
  $("#detail-hero").innerHTML = `<span class="detail-hero-bg ${b.cls}" aria-hidden="true"></span>${cover(b, { badge: b.status === "complete" ? "complete" : "hot" })}`;
  const chapters = [
    { n: "01", name: "The night she came home", free: true },
    { n: "02", name: "A scent he could not forget", free: true },
    { n: "03", name: "The first warning", free: true },
    { n: "12", name: "The vow beneath the moon", free: false },
  ];
  $("#detail-body").innerHTML = `
    <p class="d-tag">${b.g} romance</p>
    <h1 class="d-title">${b.title}</h1>
    <p class="byline">by <b>${b.author}</b></p>
    <div class="metrics">
      <div><b><span class="star" data-icon="star"></span> ${b.rate}</b><span>Rating</span></div>
      <div><b>${b.reads}</b><span>Reads</span></div>
      <div><b>${b.ch}</b><span>Chapters</span></div>
    </div>
    <p class="synopsis clamp" id="synopsis">${b.blurb} A high-stakes, slow-burn romance with steady chapter unlocks, cliffhanger pacing, and a fiercely loyal reader base. Updated multiple times a week.</p>
    <button class="read-more" type="button" data-expand>Read more</button>
    <div class="block">
      <div class="section-head"><h2>Reader reviews</h2><button class="link" type="button" data-subpage="book-reviews">All<span data-icon="chevron-right"></span></button></div>
      <div class="review">
        <div class="review-top"><b>@nightreader</b><span class="review-rate"><span data-icon="star"></span>5.0</span></div>
        <p>"The unlock pacing is addictive and actually fair. I came back every night for the wait-to-unlock."</p>
      </div>
    </div>
    <div class="block">
      <div class="section-head"><h2>Chapters</h2><button class="link" type="button" data-subpage="chapter-catalog">All ${b.ch}<span data-icon="chevron-right"></span></button></div>
      <div class="list-card">
        ${chapters.map((c) => `<button class="ch-item" type="button" data-route="reader">
          <span class="ch-num">${c.n}</span>
          <span class="ch-name">${c.name}</span>
          <span class="ch-flag ${c.free ? "free" : "paid"}">${c.free ? "Free" : '<span data-icon="lock"></span>38'}</span>
        </button>`).join("")}
      </div>
    </div>`;
  injectIcons($("[data-view='detail']"));
}

/* ============================================================
   Subpages
   ============================================================ */
function bookList(ids) {
  return `<div class="book-list">${ids.map((id) => {
    const b = byId(id);
    return `<button class="list-book" type="button" data-route="detail" data-book="${b.id}">${cover(b)}<span class="lb-info"><span class="lb-title">${b.title}</span><span class="lb-sub">${b.g} · ${b.reads} reads</span></span><span class="lb-flag saved">Open</span></button>`;
  }).join("")}</div>`;
}
function rankList(ids) {
  return `<div class="row-list">${ids.map((id, i) => {
    const b = byId(id);
    return `<button type="button" data-route="detail" data-book="${b.id}"><span class="rl-rank ${i === 0 ? "gold" : ""}">${i + 1}</span><span class="rl-main"><b>${b.title}</b><small>${b.reads} reads · ${b.g}</small></span><span class="rl-val">${b.rate}</span></button>`;
  }).join("")}</div>`;
}
function toggleList(rows) {
  return `<div class="row-list">${rows.map((r) => `<div><span class="rl-main"><b>${r[0]}</b>${r[1] ? `<small>${r[1]}</small>` : ""}</span><span class="rl-toggle ${r[2] ? "on" : ""}"></span></div>`).join("")}</div>`;
}
function prefList(rows) {
  return `<div class="row-list">${rows.map((r) => `<button type="button"><span class="rl-main"><b>${r[0]}</b></span><span class="rl-val">${r[1]}</span></button>`).join("")}</div>`;
}
function historyList(rows) {
  return `<div class="ledger">${rows.map((r) => `<div class="ledger-row"><span class="ledger-ic" data-icon="${r[2]}"></span><span class="ledger-info"><span class="ledger-name">${r[0]}</span><span class="ledger-time">${r[3] || ""}</span></span><span class="ledger-amt ${r[4] || ""}">${r[1]}</span></div>`).join("")}</div>`;
}

const SUBPAGES = {
  "for-you": ["Personalized", "For you", () => `<div class="sub-card"><h2>Tuned to your taste</h2><p>Optimized for werewolf romance, contract marriage, and high-completion stories under 1,500 words a chapter.</p></div>${bookList(["alpha", "crown", "luna", "vampire"])}`],
  "genre-werewolf": ["Genre", "Werewolf", () => `<div class="sub-card"><h2>Top tropes</h2><p>Fated mate, rejected mate, pack politics. Highest unlock conversion between 8pm and 1am local.</p></div>${bookList(["alpha", "luna", "crown"])}`],
  "genre-ceo": ["Genre", "CEO & billionaire", () => `<div class="sub-card"><h2>Popular tropes</h2><p>Contract marriage, secret baby, revenge marriage, inheritance battle.</p></div>${bookList(["billionaire", "secret", "heiress"])}`],
  "genre-reborn": ["Genre", "Reborn & second chance", () => `<div class="sub-card"><h2>What readers expect</h2><p>Fast setup, a revenge hook in chapter one, and a clear power-progression loop.</p></div>${bookList(["reborn", "crown"])}`],
  "genre-vampire": ["Genre", "Vampire", () => `<div class="sub-card"><h2>Market note</h2><p>Lower volume than werewolf, but stronger completion among gothic romance readers.</p></div>${bookList(["vampire", "crown"])}`],
  "genre-romantasy": ["Genre", "Romantasy", () => `<div class="sub-card"><h2>Fastest growing</h2><p>Court intrigue, fae bargains, enemies-to-lovers. Strong crossover with fantasy readers.</p></div>${bookList(["crown", "vampire", "alpha"])}`],
  "search-results": ["Search", "Results", () => `<div class="sub-card"><h2>Showing romance matches</h2><p>Search blends title, author, trope and genre. Try "fated mate" or "contract marriage".</p></div>${bookList(["alpha", "billionaire", "crown", "luna"])}`],
  "top-charts": ["Charts", "Top this week", () => rankList(["crown", "alpha", "billionaire", "vampire", "reborn"])],
  "new-releases": ["New", "New & rising", () => bookList(["luna", "secret", "heiress", "reborn"])],
  "recommendation-tune": ["Preferences", "Tune your feed", () => toggleList([["More werewolf romance", "", true], ["More romantasy", "", true], ["Less palace fantasy", "", false], ["Prefer completed books", "", false], ["Show free-unlock titles first", "", true]])],
  "book-reviews": ["Reviews", "Reader reviews", () => `<div class="sub-card"><h2>4.8 average · 12,480 ratings</h2><p>Reviews stay lightweight: enough social proof to convert, without a full community to moderate.</p></div>${historyList([["@nightreader — Addictive and fair pacing.", "5.0", "star", "", "plus"], ["@lunafan — Great chemistry, real cliffhangers.", "4.8", "star", "", "plus"], ["@bookwyrm — Wait-to-unlock kept me coming back.", "4.7", "star", "", "plus"]])}`],
  "save-book": ["Library", "Saved", () => `<div class="sub-card"><h2>Added to your library</h2><p>New chapter reminders are on. Find it under Library → Reading.</p></div>`],
  "chapter-catalog": ["Chapters", "All chapters", () => `<div class="row-list">${[["01", "The night she came home", "Free"], ["02", "A scent he could not forget", "Free"], ["03", "The first warning", "Free"], ["11", "The door to his private wing", "Unlocked"], ["12", "The vow beneath the moon", "38"], ["13", "A secret under winter rain", "38"]].map((c) => `<button type="button" data-route="reader"><span class="rl-rank ${c[2] === "Free" ? "gold" : ""}">${c[0]}</span><span class="rl-main"><b>${c[1]}</b></span><span class="rl-val">${c[2]}</span></button>`).join("")}</div>`],
  "sync-status": ["Library", "Sync", () => `<div class="sub-card"><h2>All devices up to date</h2><p>Last sync just now. Reading progress, unlocked chapters and bookmarks are saved to your account.</p></div>`],
  "library-reading": ["Library", "Reading", () => bookList(["alpha", "billionaire", "vampire"])],
  "library-unlocked": ["Library", "Unlocked", () => `<div class="row-list">${[["11", "The door to his private wing"], ["10", "Her name on his contract"], ["09", "What the storm carried"]].map((c) => `<button type="button" data-route="reader"><span class="rl-rank gold">${c[0]}</span><span class="rl-main"><b>${c[1]}</b><small>Unlocked with coins</small></span><span class="rl-val">Read</span></button>`).join("")}</div>`],
  "library-finished": ["Library", "Finished", () => `<div class="empty-state"><span class="empty-ic" data-icon="check-circle"></span><h2>No finished books yet</h2><p>Stories you complete collect here for rereading and better recommendations.</p></div>`],
  "daily-checkin": ["Rewards", "Daily check-in", () => `<div class="checkin-grid">${[["Day 1", "+10", "done"], ["Day 2", "+15", "done"], ["Day 3", "+20", "now"], ["Day 4", "+25", ""], ["Day 5", "+30", ""], ["Day 6", "+40", ""], ["Day 7", "+80", ""], ["Bonus", "+120", ""]].map((d) => `<div class="checkin-day ${d[2]}"><span>${d[0]}</span><b>${d[1]}</b><span class="coin-mini" data-icon="coin"></span></div>`).join("")}</div><div class="sub-card" style="margin-top:14px"><h2>Day 3 ready</h2><p>Claim 20 coins today. Keep the streak for a 120-coin bonus on day 7.</p></div>`],
  "wallet-history": ["Wallet", "Transactions", () => historyList([["Unlocked Chapter 11", "-38", "lock", "Today", "minus"], ["Daily check-in", "+20", "gift", "Today", "plus"], ["Reward video", "+12", "play", "Yesterday", "plus"], ["1,400 coins + 240 bonus", "+1,640", "coin", "Mar 2", "plus"], ["Unlocked Chapter 10", "-38", "lock", "Mar 1", "minus"]])],
  "transaction-minus": ["Transaction", "Chapter unlock", () => `<div class="sub-card"><h2>-38 coins</h2><p>Unlocked a chapter of The Alpha's Forbidden Mate. Order EL-CH-0011. Coins are spent bonus-first.</p></div>`],
  "transaction-plus": ["Transaction", "Coins added", () => `<div class="sub-card"><h2>Coins credited</h2><p>Reward or purchase confirmed and added to your balance. Receipts are available in purchase history.</p></div>`],
  "purchase-history": ["Wallet", "Purchases", () => historyList([["1,400 coins + 240 bonus", "$9.99", "coin", "Mar 2 · Google Play", ""], ["600 coins + 60 bonus", "$4.99", "coin", "Feb 18 · Google Play", ""]])],
  "settings": ["Account", "Settings", () => prefList([["Notifications", "On"], ["Language", "English"], ["Push management", "Open"], ["Privacy & data", "Open"]])],
  "message-center": ["Inbox", "Messages", () => historyList([["New chapters in The Alpha's Forbidden Mate", "Now", "bell", "Tap to read", ""], ["Your wait-to-unlock is ready", "12m", "clock", "Chapter 12", ""], ["Weekend bonus: watch & earn double", "2h", "gift", "Limited time", ""]])],
  "notifications": ["Settings", "Notifications", () => toggleList([["New chapter alerts", "", true], ["Wait-to-unlock reminders", "", true], ["Daily check-in", "", true], ["Promotions", "", false]])],
  "language": ["Settings", "Language", () => prefList([["English", "Selected"], ["Español", ""], ["Português", ""], ["Bahasa Indonesia", ""], ["Deutsch", ""], ["Français", ""]])],
  "push-management": ["Compliance", "Push management", () => `${toggleList([["New chapter alerts", "", true], ["Library updates", "", true], ["Wait-to-unlock countdown", "", true], ["Marketing campaigns", "", false]])}<div class="sub-card"><h2>Permission baseline</h2><p>Android 13+ requires explicit notification permission. Every push category stays user-controlled.</p></div>`],
  "privacy": ["Settings", "Privacy & data", () => `${prefList([["Download my data", "Request"], ["Ad personalization", "On"], ["Clear reading history", "Clear"]])}<div class="sub-card"><h2>Your data, your call</h2><p>Consent is managed through a CMP. You can withdraw or adjust permissions at any time.</p></div>`],
  "delete-account": ["Account", "Delete account", () => `<div class="danger-card"><h2>Delete account</h2><p>This permanently removes your library, wallet balance and personal data. We show everything before the final, explicit confirmation.</p></div><button class="btn btn-ghost btn-block" type="button" data-toast="A confirmation step would open here" style="margin-top:4px">Continue to deletion</button>`],
};

function openSubpage(key) {
  const page = SUBPAGES[key] || SUBPAGES["for-you"];
  $("#subpage-kicker").textContent = page[0];
  $("#subpage-title").textContent = page[1];
  $("#subpage-content").innerHTML = typeof page[2] === "function" ? page[2]() : page[2];
  injectIcons($("#subpage-content"));
  showView("subpage");
}

/* ============================================================
   Routing
   ============================================================ */
const app = $(".app");
const scrim = $(".scrim");
const toastEl = $(".toast");
const history = ["onboarding"];
let current = "onboarding";

function showView(name, push = true) {
  if (!name) return;
  $$("[data-view]").forEach((v) => v.classList.toggle("is-active", v.dataset.view === name));
  closeSheet();
  if (push && name !== current) history.push(name);
  current = name;
  const v = $(`[data-view="${name}"]`);
  if (v) v.scrollTop = 0;
}
function goBack() {
  closeSheet();
  if (history.length <= 1) { resetTo("home"); return; }
  history.pop();
  const prev = history[history.length - 1];
  showView(prev, false);
  syncTabs(prev);
}
function resetTo(name) {
  history.splice(0, history.length, name);
  showView(name, false);
  syncTabs(name);
}
function syncTabs(name) {
  $$(".tab").forEach((t) => t.classList.toggle("is-on", t.dataset.route === name));
}
function enterApp() { resetTo("home"); }

/* ----- sheets ----- */
function openSheet(name) {
  $$(".sheet").forEach((s) => s.classList.toggle("is-open", s.dataset.sheet === name));
  scrim.classList.add("is-open");
}
function closeSheet() {
  $$(".sheet").forEach((s) => s.classList.remove("is-open"));
  scrim.classList.remove("is-open");
}
function toast(msg) {
  toastEl.textContent = msg;
  toastEl.classList.add("is-on");
  clearTimeout(toastEl._t);
  toastEl._t = setTimeout(() => toastEl.classList.remove("is-on"), 1900);
}

/* ----- onboarding taste chips ----- */
const picks = new Set();
function renderTaste() {
  $("#taste-grid").innerHTML = TASTES.map((t) => `<button class="taste-chip" type="button" data-taste-chip><span data-icon="check"></span>${t}</button>`).join("");
  injectIcons($("#taste-grid"));
}
function syncGuideCta() {
  $("#guide-cta-label").textContent = picks.size ? `Start reading (${picks.size})` : "Skip for now";
}

/* ----- reader settings ----- */
let readerSize = 1.075;
function setReaderTheme(t) {
  $(".reader-view").dataset.theme = t;
  $$(".swatch").forEach((s) => s.classList.toggle("is-on", s.dataset.theme === t));
}

/* ============================================================
   Events
   ============================================================ */
document.addEventListener("click", (e) => {
  const t = e.target;

  const sub = t.closest("[data-subpage]");
  if (sub) { openSubpage(sub.dataset.subpage); return; }

  if (t.closest("[data-enter-guide]")) { showView("guide"); return; }
  if (t.closest("[data-enter-app]")) { enterApp(); return; }

  const chip = t.closest("[data-taste-chip]");
  if (chip) {
    const on = chip.classList.toggle("is-picked");
    on ? picks.add(chip) : picks.delete(chip);
    syncGuideCta();
    return;
  }

  const route = t.closest("[data-route]");
  if (route) {
    const name = route.dataset.route;
    if (name === "detail" && route.dataset.book) renderDetail(byId(route.dataset.book));
    showView(name);
    syncTabs(name);
    return;
  }

  if (t.closest("[data-back]")) { goBack(); return; }
  if (t.closest("[data-open-paywall]")) { openSheet("paywall"); return; }
  if (t.closest("[data-open-recharge]")) { openSheet("recharge"); return; }
  if (t.closest("[data-open-settings]")) { openSheet("settings"); return; }
  if (t.closest("[data-close-overlay]")) { closeSheet(); return; }

  if (t.closest("[data-unlock]")) { closeSheet(); toast("Chapter unlocked — enjoy the rest."); return; }

  if (t.closest("[data-expand]")) {
    $("#synopsis").classList.remove("clamp");
    t.closest("[data-expand]").remove();
    return;
  }

  const size = t.closest("[data-size]");
  if (size) {
    readerSize += size.dataset.size === "+" ? 0.06 : -0.06;
    readerSize = Math.max(0.92, Math.min(1.32, readerSize));
    $(".reader-view").style.setProperty("--r-size", readerSize.toFixed(3) + "rem");
    return;
  }

  const theme = t.closest("[data-theme]");
  if (theme && theme.classList.contains("swatch")) { setReaderTheme(theme.dataset.theme); return; }

  const toastBtn = t.closest("[data-toast]");
  if (toastBtn) {
    toast(toastBtn.dataset.toast);
    if (toastBtn.closest(".sheet")) closeSheet();
    return;
  }
});

document.addEventListener("keydown", (e) => { if (e.key === "Escape") closeSheet(); });

/* ----- infinite feed ----- */
function initFeed() {
  loadFeed(8);
  const sentinel = $("#feed-sentinel");
  if (!("IntersectionObserver" in window) || !sentinel) return;
  const io = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting && feedIndex < 40) loadFeed(6);
  }, { root: $("[data-view='home']"), rootMargin: "600px" });
  io.observe(sentinel);
}

/* ============================================================
   Boot
   ============================================================ */
injectIcons(document);
renderTaste();
renderHome();
renderLibrary();
renderWallet();
renderProfile();
renderDetail(currentBook);
initFeed();
