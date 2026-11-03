* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

:root {
  --bg: #07111b;
  --panel: #101f30;
  --panel-alt: #13273d;
  --line: #284b6d;
  --primary: #66d9ef;
  --accent: #8dffb7;
  --text: #edf6ff;
  --muted: #a9bed1;
  --danger: #ff9c6a;
}

body {
  background: linear-gradient(180deg, #07111b 0%, #0e1d2c 100%);
  color: var(--text);
  font-family: Arial, Helvetica, sans-serif;
}

.app-shell {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 64px;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  margin-bottom: 24px;
}

.eyebrow {
  color: var(--primary);
  font-size: 0.75rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  margin-bottom: 8px;
}

h1 {
  font-size: clamp(2rem, 4vw, 3rem);
}

.status-pill {
  border-radius: 999px;
  background: rgba(141, 255, 183, 0.16);
  color: var(--accent);
  border: 1px solid rgba(141, 255, 183, 0.4);
  padding: 10px 14px;
  font-weight: 700;
}

.stats-grid,
.panel-grid {
  display: grid;
  gap: 20px;
}

.stats-grid {
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  margin-bottom: 24px;
}

.stat-card,
.panel {
  background: rgba(16, 31, 48, 0.96);
  border: 1px solid var(--line);
  border-radius: 18px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18);
}

.stat-card {
  min-height: 130px;
  padding: 22px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.stat-card label {
  color: var(--muted);
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.stat-card strong {
  font-size: clamp(1.7rem, 4vw, 2.5rem);
}

.panel-grid {
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  margin-bottom: 24px;
}

.panel {
  padding: 22px;
}

.panel h2 {
  margin-bottom: 16px;
}

.summary-list {
  list-style: none;
  display: grid;
  gap: 14px;
}

.summary-list li {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  padding-bottom: 10px;
}

.chart-bars {
  display: flex;
  align-items: end;
  gap: 8px;
  height: 160px;
  padding-top: 18px;
}

.chart-bars span {
  display: block;
  width: 100%;
  background: linear-gradient(180deg, var(--primary) 0%, var(--accent) 100%);
  border-radius: 6px 6px 0 0;
}

.form-panel {
  margin-top: 8px;
}

.field-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 14px;
  margin-bottom: 14px;
}

label {
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: var(--muted);
  font-size: 0.9rem;
}

input {
  border: 1px solid var(--line);
  background: #0d1b2a;
  color: var(--text);
  border-radius: 10px;
  padding: 12px 14px;
  font-size: 1rem;
}

button {
  background: linear-gradient(135deg, var(--primary), var(--accent));
  color: #03131e;
  border: none;
  border-radius: 12px;
  font-weight: 800;
  padding: 12px 18px;
  cursor: pointer;
  margin-top: 8px;
}

@media (max-width: 620px) {
  .topbar {
    flex-direction: column;
    align-items: flex-start;
  }
}
