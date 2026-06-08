const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => Array.from(root.querySelectorAll(selector));

const app = $(".app");
const views = $$("[data-view]");
const scrim = $(".scrim");
const toast = $(".toast");
const historyStack = ["home"];
let currentView = "home";
let readerSize = 17;
let feedBatch = 0;

const feedSeeds = [
  ["cover-alpha.png", "The Alpha's Forbidden Mate", "Werewolf", "31M reads", "Fated mate, exile, pack politics", "2 / 3"],
  ["cover-billionaire.png", "Married to the Billionaire's Shadow", "CEO", "18M reads", "Contract marriage with a cold heir", "3 / 4"],
  ["cover-crown.png", "Crown of Ash and Thorns", "Romantasy", "22M reads", "A queen returns to a ruined court", "2 / 3"],
  ["cover-luna.png", "His Reluctant Luna", "Werewolf", "9M reads", "A rejected mate story with slow burn", "4 / 5"],
  ["cover-vampire.png", "Midnight with the Vampire King", "Vampire", "12M reads", "Gothic romance and forbidden bloodlines", "2 / 3"],
  ["cover-reborn.png", "Reborn as the Tyrant's Wife", "Reborn", "14M reads", "Second chance inside the palace", "3 / 4"],
  ["cover-secret.png", "The CEO's Secret Bride", "Modern romance", "7M reads", "A hidden marriage turns public", "2 / 3"],
  ["cover-crown.png", "Ashes Beneath Her Crown", "Fantasy", "5M reads", "Court intrigue with a revenge arc", "4 / 5"],
  ["cover-billionaire.png", "The Heiress He Bought", "Billionaire", "11M reads", "High stakes inheritance and fake vows", "2 / 3"],
  ["cover-luna.png", "Marked by Moonlight", "Shifter", "8M reads", "Pack secrets, slow trust, fast chapters", "3 / 4"],
];

const bookListHtml = `
  <button class="list-book" type="button" data-route="detail"><img src="./assets/cover-alpha.png" alt=""><span><b>The Alpha's Forbidden Mate</b><small>4.8 · 31M reads · Werewolf</small></span><em>Open</em></button>
  <button class="list-book" type="button" data-route="detail"><img src="./assets/cover-billionaire.png" alt=""><span><b>Married to the Billionaire's Shadow</b><small>4.7 · 18M reads · CEO</small></span><em>Open</em></button>
  <button class="list-book" type="button" data-route="detail"><img src="./assets/cover-crown.png" alt=""><span><b>Crown of Ash and Thorns</b><small>4.9 · 22M reads · Romantasy</small></span><em>Open</em></button>
  <button class="list-book" type="button" data-route="detail"><img src="./assets/cover-luna.png" alt=""><span><b>His Reluctant Luna</b><small>4.6 · 9M reads · Shifter</small></span><em>Open</em></button>
`;

const subpages = {
  "for-you": ["Personalized feed", "For you", `<section class="sub-card"><h2>Your recommendation signals</h2><p>Optimized for werewolf romance, contract marriage, high completion rate stories, and chapters under 1,500 words.</p></section><section class="book-list">${bookListHtml}</section>`],
  "genre-werewolf": ["Genre", "Werewolf romance", `<section class="sub-card"><h2>Category performance</h2><p>Highest unlock conversion: fated mate, rejected mate, pack politics. Best time to push: 20:00-01:00 local.</p></section><section class="book-list">${bookListHtml}</section>`],
  "genre-ceo": ["Genre", "CEO romance", `<section class="sub-card"><h2>Popular tropes</h2><p>Contract marriage, secret baby, revenge marriage, inheritance battle.</p></section><section class="book-list">${bookListHtml}</section>`],
  "genre-reborn": ["Genre", "Reborn & second chance", `<section class="sub-card"><h2>Reader expectation</h2><p>Fast setup, revenge hook in chapter one, and a clear power progression loop.</p></section><section class="book-list">${bookListHtml}</section>`],
  "genre-vampire": ["Genre", "Vampire romance", `<section class="sub-card"><h2>Market note</h2><p>Lower volume than werewolf, but stronger completion among gothic romance readers.</p></section><section class="book-list">${bookListHtml}</section>`],
  "top-charts": ["Chart", "Top charts", `<section class="rank-list"><button data-route="detail"><b>1</b><span>The Alpha's Forbidden Mate<small>31M reads · 12% unlock lift this week</small></span></button><button data-route="detail"><b>2</b><span>Crown of Ash and Thorns<small>22M reads · strong retention</small></span></button><button data-route="detail"><b>3</b><span>Married to the Billionaire's Shadow<small>18M reads · high first-pay conversion</small></span></button></section>`],
  "new-releases": ["Shelf", "New releases", `<section class="sub-card"><h2>Fresh titles</h2><p>New books are ranked by early read-through rate, not only views.</p></section><section class="book-list">${bookListHtml}</section>`],
  "recommendation-tune": ["Preferences", "Tune recommendations", `<section class="pref-list"><button>More werewolf romance <em>On</em></button><button>Less palace fantasy <em>Off</em></button><button>Prefer completed books <em>On</em></button><button>Show more free unlocks <em>On</em></button></section>`],
  "save-book": ["Saved", "Added to library", `<section class="sub-card"><h2>The Alpha's Forbidden Mate</h2><p>Saved to Reading. Push reminders are enabled for new chapters.</p><button class="primary full" type="button" data-route="library">View in Library</button></section>`],
  "sync-status": ["Library", "Sync status", `<section class="sub-card"><h2>All devices synced</h2><p>Last sync: just now. Reading progress, unlocked chapters, and bookmarks are up to date.</p></section>`],
  "library-reading": ["Library", "Currently reading", `<section class="book-list">${bookListHtml}</section>`],
  "library-unlocked": ["Library", "Unlocked chapters", `<section class="chapter-log"><button data-route="reader"><b>Chapter 11</b><span>The door to his private wing</span><em>Unlocked</em></button><button data-route="reader"><b>Chapter 10</b><span>Her name on his contract</span><em>Unlocked</em></button></section>`],
  "library-finished": ["Library", "Finished books", `<section class="empty-state"><h2>No finished books yet</h2><p>Finished stories will collect here for rereading and recommendations.</p></section>`],
  "daily-checkin": ["Rewards", "Daily check-in", `<section class="checkin-grid"><span>Day 1<br><b>+10</b></span><span>Day 2<br><b>+15</b></span><span class="is-now">Day 3<br><b>+20</b></span><span>Day 4<br><b>+25</b></span><span>Day 5<br><b>+30</b></span><span>Day 7<br><b>+80</b></span></section><button class="primary full" type="button" data-toast="Daily reward claimed">Claim today's reward</button>`],
  "wallet-history": ["Wallet", "Transaction history", `<section class="history-list"><div><span>Unlocked Chapter 11</span><em>-38</em></div><div><span>Daily reward</span><em>+20</em></div><div><span>Reward video</span><em>+12</em></div><div><span>Recharge package</span><em>+1,640</em></div></section>`],
  "transaction-unlock": ["Transaction", "Chapter unlock", `<section class="sub-card"><h2>-38 coins</h2><p>Unlocked Chapter 11 of The Alpha's Forbidden Mate. Order ID: EL-CH-0011.</p></section>`],
  "transaction-reward": ["Transaction", "Daily reward", `<section class="sub-card"><h2>+20 coins</h2><p>Reward granted for day 3 check-in streak.</p></section>`],
  "transaction-ad": ["Transaction", "Reward video", `<section class="sub-card"><h2>+12 coins</h2><p>Reward granted after a completed video placement.</p></section>`],
  "purchase-history": ["Wallet", "Purchase history", `<section class="history-list"><div><span>1,400 coins + 240 bonus</span><em>$9.99</em></div><div><span>600 coins + 60 bonus</span><em>$4.99</em></div></section>`],
  "settings": ["Account", "Settings", `<section class="pref-list"><button data-subpage="notifications">Notifications <em>On</em></button><button data-subpage="language">Language <em>English</em></button><button data-subpage="privacy">Privacy & data <em>Open</em></button></section>`],
  "notifications": ["Settings", "Notifications", `<section class="pref-list"><button>New chapter alerts <em>On</em></button><button>Wait-to-unlock reminders <em>On</em></button><button>Promotions <em>Off</em></button></section>`],
  "language": ["Settings", "Language", `<section class="pref-list"><button>English <em>Selected</em></button><button>Español <em></em></button><button>Português <em></em></button><button>Bahasa Indonesia <em></em></button></section>`],
  "privacy": ["Settings", "Privacy & data", `<section class="pref-list"><button>Download my data <em>›</em></button><button>Ad personalization <em>On</em></button><button>Delete reading history <em>›</em></button></section>`],
  "delete-account": ["Account", "Delete account", `<section class="danger-card"><h2>Account deletion</h2><p>This flow must be explicit and reversible before the final confirmation. Reading history, wallet records, and personal data are shown before deletion.</p><button class="secondary" type="button" data-toast="Deletion confirmation would open">Continue</button></section>`],
};

function showView(name, push = true) {
  if (!name || name === currentView) return;
  views.forEach((view) => view.classList.toggle("is-active", view.dataset.view === name));
  closeSheet();
  if (push) historyStack.push(name);
  currentView = name;
  app.scrollTop = 0;
  const activeView = $(`[data-view="${name}"]`);
  if (activeView) activeView.scrollTop = 0;
}

function goBack() {
  closeSheet();
  if (historyStack.length <= 1) {
    showView("home", false);
    historyStack.splice(0, historyStack.length, "home");
    return;
  }
  historyStack.pop();
  showView(historyStack[historyStack.length - 1], false);
}

function openSheet(name) {
  $$(".sheet").forEach((sheet) => sheet.classList.toggle("is-open", sheet.dataset.sheet === name));
  scrim.classList.add("is-open");
}

function closeSheet() {
  $$(".sheet").forEach((sheet) => sheet.classList.remove("is-open"));
  scrim.classList.remove("is-open");
}

function say(message) {
  toast.textContent = message;
  toast.classList.add("is-on");
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => toast.classList.remove("is-on"), 1700);
}

function syncBottomNav(name) {
  $$(".bottom-nav button").forEach((button) => {
    button.classList.toggle("is-on", button.dataset.route === name);
  });
}

function openSubpage(key) {
  const page = subpages[key] || subpages["for-you"];
  $("#subpage-kicker").textContent = page[0];
  $("#subpage-title").textContent = page[1];
  $("#subpage-content").innerHTML = page[2];
  showView("subpage");
}

function appendFeed(count = 10) {
  const feed = $("#discover-feed");
  if (!feed) return;

  for (let i = 0; i < count; i += 1) {
    const seed = feedSeeds[(feedBatch * count + i) % feedSeeds.length];
    const card = document.createElement("button");
    card.type = "button";
    card.className = "feed-card";
    card.dataset.route = "detail";
    card.style.setProperty("--ratio", seed[5]);
    card.innerHTML = `
      <img src="./assets/${seed[0]}" alt="">
      <span class="fc-body">
        <span class="fc-tag">${seed[2]}</span>
        <b>${seed[1]}</b>
        <p>${seed[4]}</p>
        <span class="fc-meta"><span>${seed[3]}</span><span>${(4.4 + ((feedBatch + i) % 6) / 10).toFixed(1)}</span></span>
      </span>
    `;
    feed.appendChild(card);
  }
  feedBatch += 1;
}

function initEndlessDiscover() {
  const home = $('[data-view="home"]');
  if (!home) return;
  appendFeed(18);
  home.addEventListener("scroll", () => {
    const remaining = home.scrollHeight - home.scrollTop - home.clientHeight;
    if (remaining < 900) appendFeed(10);
  });
}

document.addEventListener("click", (event) => {
  const subpage = event.target.closest("[data-subpage]");
  if (subpage) {
    openSubpage(subpage.dataset.subpage);
    return;
  }

  const route = event.target.closest("[data-route]");
  if (route) {
    const name = route.dataset.route;
    showView(name);
    syncBottomNav(name);
    return;
  }

  if (event.target.closest("[data-back]")) {
    goBack();
    syncBottomNav(currentView);
    return;
  }

  const paywall = event.target.closest("[data-open-paywall]");
  if (paywall) {
    openSheet("paywall");
    return;
  }

  const recharge = event.target.closest("[data-open-recharge]");
  if (recharge) {
    openSheet("recharge");
    return;
  }

  const settings = event.target.closest("[data-open-settings]");
  if (settings) {
    openSheet("settings");
    return;
  }

  if (event.target.closest("[data-close-overlay]")) {
    closeSheet();
    return;
  }

  const unlock = event.target.closest("[data-unlock]");
  if (unlock) {
    closeSheet();
    say("Chapter unlocked. Enjoy the rest of the night.");
    return;
  }

  const toastAction = event.target.closest("[data-toast]");
  if (toastAction) {
    say(toastAction.dataset.toast);
    if (toastAction.closest("[data-sheet='recharge']")) closeSheet();
    return;
  }

  const size = event.target.closest("[data-size]");
  if (size) {
    readerSize += size.dataset.size === "+" ? 1 : -1;
    readerSize = Math.max(15, Math.min(22, readerSize));
    document.documentElement.style.setProperty("--reader-size", `${readerSize}px`);
    return;
  }

  const theme = event.target.closest("[data-theme]");
  if (theme) {
    if (theme.dataset.theme === "paper") {
      document.documentElement.style.setProperty("--reader-bg", "var(--paper)");
      document.documentElement.style.setProperty("--reader-ink", "var(--paper-ink)");
    } else {
      document.documentElement.style.setProperty("--reader-bg", "var(--bg)");
      document.documentElement.style.setProperty("--reader-ink", "var(--ink)");
    }
  }
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") closeSheet();
});

document.addEventListener("DOMContentLoaded", initEndlessDiscover);
