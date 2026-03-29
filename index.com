<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <title>Matt's Pool App — Final</title>
  <style>
    :root {
      --bg: #080808;
      --line: #2a2a2a;
      --text: #f6f2e8;
      --muted: #b7aa85;
      --gold: #d3a83b;
      --gold-2: #f1d17a;
      --shadow: 0 10px 30px rgba(0,0,0,.35);
    }
    * { box-sizing: border-box; }
    html, body {
      margin: 0; width: 100%; height: 100%; overflow: hidden;
      background: radial-gradient(circle at top, #151515 0%, var(--bg) 52%);
      color: var(--text); font-family: Arial, Helvetica, sans-serif;
    }
    body { display: flex; align-items: stretch; justify-content: center; }
    .app {
      width: 100%; height: 100dvh; display: grid;
      grid-template-columns: minmax(0, 1fr) 290px; gap: 12px; padding: 12px; overflow: hidden;
    }
    .main, .side {
      min-height: 0; background: linear-gradient(180deg, rgba(255,255,255,.02), rgba(255,255,255,.01));
      border: 1px solid var(--line); border-radius: 18px; box-shadow: var(--shadow); overflow: hidden;
    }
    .main { display: grid; grid-template-rows: auto auto 1fr auto; min-width: 0; }
    .topbar {
      display: flex; align-items: center; justify-content: center; padding: 12px 14px 8px;
      border-bottom: 1px solid rgba(211,168,59,.18);
      background: linear-gradient(180deg, rgba(211,168,59,.10), rgba(211,168,59,.03));
    }
    .title {
      text-align: center; font-weight: 700; letter-spacing: .08em; color: var(--gold-2);
      font-size: clamp(18px, 2.3vw, 28px); text-transform: uppercase;
    }
    .subtitle {
      margin-top: 4px; text-align: center; color: var(--muted); font-size: 12px;
      letter-spacing: .15em; text-transform: uppercase;
    }
    .inputs {
      display: grid; grid-template-columns: 1fr 1fr 1fr 180px; gap: 10px; padding: 12px;
      border-bottom: 1px solid var(--line); background: rgba(255,255,255,.015);
    }
    .field { display: grid; gap: 5px; min-width: 0; }
    .field label {
      font-size: 11px; color: var(--muted); font-weight: 700; letter-spacing: .14em;
      text-transform: uppercase; padding-left: 2px;
    }
    input {
      width: 100%; height: 42px; padding: 10px 12px; border-radius: 12px; border: 1px solid #3b3220;
      outline: none; color: var(--text); background: #0e0e0e; font-size: 15px; text-align: center;
    }
    input:focus { border-color: var(--gold); box-shadow: 0 0 0 2px rgba(211,168,59,.18); }
    .board-wrap {
      min-height: 0; overflow: auto; padding: 12px; display: flex; align-items: center; justify-content: center;
      background: linear-gradient(180deg, rgba(0,0,0,.08), rgba(255,255,255,.01));
    }
    .board-card {
      width: min(100%, 980px); aspect-ratio: 1 / 1; background: #0d0d0d; border: 1px solid #312814;
      border-radius: 20px; padding: 14px; box-shadow: inset 0 0 0 1px rgba(211,168,59,.06);
    }
    .board-meta { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-bottom: 10px; }
    .meta-box {
      min-width: 0; height: 42px; display: flex; align-items: center; justify-content: center; padding: 0 10px;
      border-radius: 12px; background: linear-gradient(180deg, #1a1a1a, #111111); border: 1px solid #3b3220;
      color: var(--gold-2); font-size: clamp(12px, 1.3vw, 16px); font-weight: 700; letter-spacing: .06em;
      text-transform: uppercase; text-align: center; overflow: hidden; white-space: nowrap; text-overflow: ellipsis;
    }
    .grid-shell {
      width: 100%; height: calc(100% - 52px); display: grid;
      grid-template-columns: 52px repeat(10, 1fr); grid-template-rows: 52px repeat(10, 1fr); gap: 4px;
    }
    .axis, .corner, .cell {
      border-radius: 12px; display: flex; align-items: center; justify-content: center; user-select: none;
      text-align: center; line-height: 1.05; overflow: hidden;
    }
    .corner {
      background: linear-gradient(180deg, #2a2110, #17120a); border: 1px solid #5b4822; color: var(--gold-2);
      font-weight: 800; font-size: 12px; padding: 4px;
    }
    .axis {
      background: linear-gradient(180deg, #d3a83b, #a97814); color: #111; border: 1px solid #f0ce6a;
      font-weight: 800; font-size: clamp(16px, 1.8vw, 22px); box-shadow: inset 0 0 0 1px rgba(255,255,255,.15);
    }
    .cell {
      position: relative; background: linear-gradient(180deg, #faf7f0, #ebe3d2); color: #151515;
      border: 1px solid #d7c29f; font-size: clamp(10px, 1.2vw, 16px); font-weight: 700; padding: 4px;
      cursor: pointer; word-break: break-word;
    }
    .cell.empty:hover { filter: brightness(0.98); }
    .cell.filled { border-color: rgba(0,0,0,.28); }
    .cell.locked { cursor: default; }
    .cell-name {
      display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; padding: 2px;
    }
    .controls {
      display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; padding: 12px;
      border-top: 1px solid var(--line); background: rgba(255,255,255,.02);
    }
    button {
      border: 0; height: 44px; border-radius: 12px; font-weight: 800; letter-spacing: .04em; cursor: pointer;
      color: #141414; background: linear-gradient(180deg, #f0cf73, #c99725); box-shadow: 0 4px 14px rgba(0,0,0,.25);
    }
    button.secondary {
      background: linear-gradient(180deg, #2a2a2a, #1a1a1a); color: var(--text); border: 1px solid #3a3a3a; box-shadow: none;
    }
    button:disabled { opacity: .42; cursor: not-allowed; }
    .side { display: grid; grid-template-rows: auto 1fr; }
    .side-head {
      padding: 14px 14px 10px; border-bottom: 1px solid var(--line);
      background: linear-gradient(180deg, rgba(211,168,59,.10), rgba(211,168,59,.02));
    }
    .side-title { color: var(--gold-2); font-size: 16px; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; }
    .side-note { margin-top: 4px; color: var(--muted); font-size: 12px; }
    .saved-list { min-height: 0; overflow: auto; padding: 12px; display: grid; gap: 10px; align-content: start; }
    .saved-card {
      background: linear-gradient(180deg, #171717, #111111); border: 1px solid #2b2b2b; border-radius: 14px;
      padding: 10px; display: grid; gap: 8px;
    }
    .saved-name { color: var(--gold-2); font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; }
    .saved-meta { color: #ddd4c3; font-size: 12px; }
    .saved-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .mini-board {
      width: 100%; aspect-ratio: 1 / 1; display: grid; grid-template-columns: repeat(11, 1fr);
      grid-template-rows: repeat(11, 1fr); gap: 1px; background: #0d0d0d; border-radius: 10px;
      overflow: hidden; padding: 4px; border: 1px solid #2a2a2a;
    }
    .mini-board > div {
      min-width: 0; min-height: 0; display: flex; align-items: center; justify-content: center; font-size: 7px;
      font-weight: 700; text-align: center; overflow: hidden; line-height: 1; padding: 1px;
    }
    .mini-axis { background: #d3a83b; color: #111; }
    .mini-corner { background: #1f180c; color: #f0d27d; }
    .mini-cell { background: #f4ecde; color: #111; }
    .empty-state {
      border: 1px dashed #3a3a3a; border-radius: 14px; padding: 18px; color: #b8b0a3; text-align: center;
      font-size: 13px; background: rgba(255,255,255,.02);
    }
    .toast {
      position: fixed; left: 50%; bottom: 16px; transform: translateX(-50%) translateY(120%);
      background: #111; color: var(--gold-2); border: 1px solid #4f3b14; border-radius: 999px; padding: 10px 14px;
      font-size: 13px; box-shadow: var(--shadow); transition: transform .22s ease; z-index: 30; pointer-events: none;
    }
    .toast.show { transform: translateX(-50%) translateY(0); }
    @media (max-width: 980px) {
      .app { grid-template-columns: 1fr; grid-template-rows: minmax(0, 1fr) 240px; }
      .inputs { grid-template-columns: 1fr 1fr; }
      .controls { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
      .app { padding: 8px; gap: 8px; }
      .board-card { padding: 10px; }
      .grid-shell { grid-template-columns: 36px repeat(10, 1fr); grid-template-rows: 36px repeat(10, 1fr); gap: 3px; }
      .axis { font-size: 14px; border-radius: 9px; }
      .corner, .cell { border-radius: 9px; }
      .controls { gap: 8px; }
      button { height: 40px; font-size: 12px; }
      .meta-box { height: 36px; font-size: 11px; }
      .inputs { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <div class="app">
    <section class="main">
      <div class="topbar">
        <div>
          <div class="title">Matt's Pool App</div>
          <div class="subtitle">Final Single File Build</div>
        </div>
      </div>

      <div class="inputs">
        <div class="field">
          <label for="gameName">Game Name</label>
          <input id="gameName" placeholder="Game Name" />
        </div>
        <div class="field">
          <label for="gameAmount">Amount</label>
          <input id="gameAmount" placeholder="$ Amount" />
        </div>
        <div class="field">
          <label for="gameDate">Date</label>
          <input id="gameDate" placeholder="Date" />
        </div>
        <div class="field">
          <label for="playerName">Player Name</label>
          <input id="playerName" placeholder="Type name then tap squares" />
        </div>
      </div>

      <div class="board-wrap">
        <div class="board-card" id="captureBoard">
          <div class="board-meta">
            <div class="meta-box" id="metaName">Game Name</div>
            <div class="meta-box" id="metaAmount">Amount</div>
            <div class="meta-box" id="metaDate">Date</div>
          </div>
          <div class="grid-shell" id="gridShell"></div>
        </div>
      </div>

      <div class="controls">
        <button id="clearBtn" class="secondary">Clear</button>
        <button id="saveBtn" class="secondary">Save Board</button>
        <button id="downloadBtn">Download Image</button>
        <button id="lockBtn">Lock Board</button>
        <button id="newBtn" class="secondary">New Board</button>
      </div>
    </section>

    <aside class="side">
      <div class="side-head">
        <div class="side-title">Saved Boards</div>
        <div class="side-note">Locked boards stay here with delete and preview.</div>
      </div>
      <div class="saved-list" id="savedList">
        <div class="empty-state" id="emptyState">No saved boards yet.</div>
      </div>
    </aside>
  </div>

  <div class="toast" id="toast"></div>

  <script>
    const SIZE = 10;
    const state = {
      board: Array.from({ length: SIZE * SIZE }, () => ({ name: '', color: '' })),
      locked: false,
      topNums: Array(SIZE).fill(''),
      leftNums: Array(SIZE).fill(''),
      saved: [],
      playerColors: {},
    };

    const gridShell = document.getElementById('gridShell');
    const savedList = document.getElementById('savedList');
    const emptyState = document.getElementById('emptyState');
    const toastEl = document.getElementById('toast');

    const gameName = document.getElementById('gameName');
    const gameAmount = document.getElementById('gameAmount');
    const gameDate = document.getElementById('gameDate');
    const playerName = document.getElementById('playerName');

    const metaName = document.getElementById('metaName');
    const metaAmount = document.getElementById('metaAmount');
    const metaDate = document.getElementById('metaDate');

    const clearBtn = document.getElementById('clearBtn');
    const saveBtn = document.getElementById('saveBtn');
    const downloadBtn = document.getElementById('downloadBtn');
    const lockBtn = document.getElementById('lockBtn');
    const newBtn = document.getElementById('newBtn');

    function showToast(message) {
      toastEl.textContent = message;
      toastEl.classList.add('show');
      clearTimeout(showToast.timer);
      showToast.timer = setTimeout(() => toastEl.classList.remove('show'), 1500);
    }

    function sanitize(text) {
      return String(text || '').replace(/[<>]/g, '').trim();
    }

    function seedColor(name) {
      let hash = 0;
      for (let i = 0; i < name.length; i++) hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
      const hue = hash % 360;
      return `hsl(${hue} 70% 78%)`;
    }

    function getColor(name) {
      if (!state.playerColors[name]) state.playerColors[name] = seedColor(name);
      return state.playerColors[name];
    }

    function isBoardFull() {
      return state.board.every(cell => cell.name);
    }

    function randomDigits() {
      const digits = ['0','1','2','3','4','5','6','7','8','9'];
      for (let i = digits.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [digits[i], digits[j]] = [digits[j], digits[i]];
      }
      return digits;
    }

    function ensureNumbersIfFull() {
      if (isBoardFull() && state.topNums.every(v => v === '') && state.leftNums.every(v => v === '')) {
        state.topNums = randomDigits();
        state.leftNums = randomDigits();
        state.locked = true;
        showToast('Board filled and locked');
      }
    }

    function updateMeta() {
      metaName.textContent = sanitize(gameName.value) || 'Game Name';
      metaAmount.textContent = sanitize(gameAmount.value) || 'Amount';
      metaDate.textContent = sanitize(gameDate.value) || 'Date';
    }

    function renderBoard() {
      updateMeta();
      gridShell.innerHTML = '';

      const corner = document.createElement('div');
      corner.className = 'corner';
      corner.textContent = 'SRL';
      gridShell.appendChild(corner);

      for (let col = 0; col < SIZE; col++) {
        const axis = document.createElement('div');
        axis.className = 'axis';
        axis.textContent = state.topNums[col];
        gridShell.appendChild(axis);
      }

      for (let row = 0; row < SIZE; row++) {
        const left = document.createElement('div');
        left.className = 'axis';
        left.textContent = state.leftNums[row];
        gridShell.appendChild(left);

        for (let col = 0; col < SIZE; col++) {
          const idx = row * SIZE + col;
          const data = state.board[idx];
          const cell = document.createElement('div');
          cell.className = `cell ${data.name ? 'filled' : 'empty'} ${state.locked ? 'locked' : ''}`;
          if (data.color) cell.style.background = data.color;
          if (data.name) cell.innerHTML = `<div class="cell-name">${data.name}</div>`;
          cell.addEventListener('click', () => fillCell(idx));
          gridShell.appendChild(cell);
        }
      }

      clearBtn.disabled = state.locked;
      saveBtn.disabled = !state.locked;
      lockBtn.disabled = state.locked || !isBoardFull();
      lockBtn.textContent = state.locked ? 'Locked' : 'Lock Board';
    }

    function fillCell(idx) {
      if (state.locked) return;
      const name = sanitize(playerName.value);
      if (!name) {
        showToast('Enter a player name');
        return;
      }
      if (state.board[idx].name) return;
      state.board[idx] = { name, color: getColor(name) };
      ensureNumbersIfFull();
      renderBoard();
    }

    function clearBoard() {
      if (state.locked) return;
      state.board = Array.from({ length: SIZE * SIZE }, () => ({ name: '', color: '' }));
      state.topNums = Array(SIZE).fill('');
      state.leftNums = Array(SIZE).fill('');
      renderBoard();
      showToast('Board cleared');
    }

    function newBoard() {
      state.board = Array.from({ length: SIZE * SIZE }, () => ({ name: '', color: '' }));
      state.topNums = Array(SIZE).fill('');
      state.leftNums = Array(SIZE).fill('');
      state.locked = false;
      playerName.value = '';
      renderBoard();
      showToast('New board ready');
    }

    function lockBoard() {
      if (!isBoardFull()) {
        showToast('Fill all 100 squares first');
        return;
      }
      if (!state.locked) {
        state.topNums = randomDigits();
        state.leftNums = randomDigits();
        state.locked = true;
        renderBoard();
        showToast('Board locked');
      }
    }

    function buildSnapshot() {
      return {
        id: Date.now() + Math.random().toString(36).slice(2, 7),
        name: sanitize(gameName.value) || 'Pool Board',
        amount: sanitize(gameAmount.value) || '',
        date: sanitize(gameDate.value) || '',
        board: state.board.map(cell => ({ ...cell })),
        topNums: [...state.topNums],
        leftNums: [...state.leftNums],
      };
    }

    function saveBoard() {
      if (!state.locked) {
        showToast('Lock the board first');
        return;
      }
      state.saved.unshift(buildSnapshot());
      renderSavedBoards();
      showToast('Board saved');
    }

    function renderSavedBoards() {
      savedList.innerHTML = '';
      if (!state.saved.length) {
        savedList.appendChild(emptyState);
        return;
      }

      state.saved.forEach(item => {
        const card = document.createElement('div');
        card.className = 'saved-card';

        const title = document.createElement('div');
        title.className = 'saved-name';
        title.textContent = item.name;
        card.appendChild(title);

        const meta = document.createElement('div');
        meta.className = 'saved-meta';
        meta.textContent = [item.amount, item.date].filter(Boolean).join(' • ') || 'Locked board';
        card.appendChild(meta);

        const mini = document.createElement('div');
        mini.className = 'mini-board';
        const cells = [];
        cells.push(Object.assign(document.createElement('div'), { className: 'mini-corner', textContent: 'SRL' }));
        item.topNums.forEach(n => cells.push(Object.assign(document.createElement('div'), { className: 'mini-axis', textContent: n })));
        for (let r = 0; r < SIZE; r++) {
          cells.push(Object.assign(document.createElement('div'), { className: 'mini-axis', textContent: item.leftNums[r] }));
          for (let c = 0; c < SIZE; c++) {
            const idx = r * SIZE + c;
            const d = item.board[idx];
            const el = document.createElement('div');
            el.className = 'mini-cell';
            el.textContent = d.name ? d.name.slice(0, 4) : '';
            el.style.background = d.color || '#f4ecde';
            cells.push(el);
          }
        }
        cells.forEach(el => mini.appendChild(el));
        card.appendChild(mini);

        const actions = document.createElement('div');
        actions.className = 'saved-actions';

        const loadBtn = document.createElement('button');
        loadBtn.className = 'secondary';
        loadBtn.textContent = 'Load';
        loadBtn.onclick = () => loadSnapshot(item.id);

        const delBtn = document.createElement('button');
        delBtn.textContent = 'Delete';
        delBtn.onclick = () => deleteSnapshot(item.id);

        actions.appendChild(loadBtn);
        actions.appendChild(delBtn);
        card.appendChild(actions);

        savedList.appendChild(card);
      });
    }

    function loadSnapshot(id) {
      const item = state.saved.find(x => x.id === id);
      if (!item) return;
      gameName.value = item.name || '';
      gameAmount.value = item.amount || '';
      gameDate.value = item.date || '';
      state.board = item.board.map(cell => ({ ...cell }));
      state.topNums = [...item.topNums];
      state.leftNums = [...item.leftNums];
      state.locked = true;
      renderBoard();
      showToast('Board loaded');
    }

    function deleteSnapshot(id) {
      state.saved = state.saved.filter(x => x.id !== id);
      renderSavedBoards();
      showToast('Saved board deleted');
    }

    function roundedRect(ctx, x, y, w, h, r) {
      ctx.beginPath();
      ctx.moveTo(x + r, y);
      ctx.arcTo(x + w, y, x + w, y + h, r);
      ctx.arcTo(x + w, y + h, x, y + h, r);
      ctx.arcTo(x, y + h, x, y, r);
      ctx.arcTo(x, y, x + w, y, r);
      ctx.closePath();
    }

    function fitText(ctx, text, maxWidth, startSize, weight = '700') {
      let size = startSize;
      do {
        ctx.font = `${weight} ${size}px Arial`;
        if (ctx.measureText(text).width <= maxWidth || size <= 10) break;
        size -= 1;
      } while (size > 10);
      return size;
    }

    function downloadBoardImage() {
      const scale = 2;
      const canvas = document.createElement('canvas');
      const size = 1400 * scale;
      canvas.width = size;
      canvas.height = size;
      const ctx = canvas.getContext('2d');

      ctx.fillStyle = '#090909';
      ctx.fillRect(0, 0, size, size);

      const pad = 38 * scale;
      const metaH = 90 * scale;
      const gap = 10 * scale;
      const axis = 64 * scale;
      const boardY = pad + metaH + gap;
      const boardSize = size - pad * 2;
      const cellSize = Math.floor((boardSize - axis - gap * 10) / 10);

      const totalGridW = axis + gap * 10 + cellSize * 10;
      const startX = (size - totalGridW) / 2;
      const startY = boardY;

      const boxW = Math.floor((totalGridW - gap * 2) / 3);
      const labels = [sanitize(gameName.value) || 'Game Name', sanitize(gameAmount.value) || 'Amount', sanitize(gameDate.value) || 'Date'];
      for (let i = 0; i < 3; i++) {
        const x = startX + i * (boxW + gap);
        const y = pad;
        ctx.fillStyle = '#151515';
        roundedRect(ctx, x, y, boxW, metaH, 24 * scale);
        ctx.fill();
        ctx.strokeStyle = '#6a531f';
        ctx.lineWidth = 2 * scale;
        ctx.stroke();
        const fontSize = fitText(ctx, labels[i], boxW - 32 * scale, 28 * scale, '700');
        ctx.fillStyle = '#f1d17a';
        ctx.font = `700 ${fontSize}px Arial`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(labels[i], x + boxW / 2, y + metaH / 2);
      }

      function drawCell(x, y, w, h, fill, text, textColor, border) {
        ctx.fillStyle = fill;
        roundedRect(ctx, x, y, w, h, 18 * scale);
        ctx.fill();
        ctx.strokeStyle = border;
        ctx.lineWidth = 2 * scale;
        ctx.stroke();
        if (text) {
          const fontSize = fitText(ctx, text, w - 12 * scale, 22 * scale);
          ctx.fillStyle = textColor;
          ctx.font = `700 ${fontSize}px Arial`;
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          const lines = text.length > 12 ? text.match(/.{1,12}/g).slice(0, 3) : [text];
          const lineH = fontSize * 1.05;
          const totalH = lineH * lines.length;
          let yy = y + h / 2 - totalH / 2 + lineH / 2;
          lines.forEach(line => {
            ctx.fillText(line, x + w / 2, yy);
            yy += lineH;
          });
        }
      }

      drawCell(startX, startY, axis, axis, '#1b140a', 'SRL', '#f1d17a', '#6a531f');
      for (let c = 0; c < 10; c++) {
        const x = startX + axis + gap + c * (cellSize + gap);
        drawCell(x, startY, cellSize, axis, '#d3a83b', state.topNums[c] || '', '#111', '#f0ce6a');
      }

      for (let r = 0; r < 10; r++) {
        const y = startY + axis + gap + r * (cellSize + gap);
        drawCell(startX, y, axis, cellSize, '#d3a83b', state.leftNums[r] || '', '#111', '#f0ce6a');
        for (let c = 0; c < 10; c++) {
          const x = startX + axis + gap + c * (cellSize + gap);
          const data = state.board[r * 10 + c];
          drawCell(x, y, cellSize, cellSize, data.color || '#f4ecde', data.name || '', '#111', '#ccb48a');
        }
      }

      const filenameBase = (sanitize(gameName.value) || 'matts_pool_app').replace(/\s+/g, '_').toLowerCase();
      const link = document.createElement('a');
      link.href = canvas.toDataURL('image/png');
      link.download = `${filenameBase}.png`;
      link.click();
      showToast('Image downloaded');
    }

    [gameName, gameAmount, gameDate].forEach(el => el.addEventListener('input', updateMeta));
    clearBtn.addEventListener('click', clearBoard);
    saveBtn.addEventListener('click', saveBoard);
    downloadBtn.addEventListener('click', downloadBoardImage);
    lockBtn.addEventListener('click', lockBoard);
    newBtn.addEventListener('click', newBoard);

    renderBoard();
    renderSavedBoards();
  </script>
</body>
</html>

