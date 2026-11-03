const statusBadge = document.getElementById('api-status');
const form = document.getElementById('session-form');
const message = document.getElementById('form-message');

fetch('/api/health')
  .then((response) => {
    if (!response.ok) throw new Error('API unavailable');
    return response.json();
  })
  .then(() => {
    statusBadge.textContent = 'Szerver működik';
    statusBadge.classList.add('online');
  })
  .catch(() => {
    statusBadge.textContent = 'Szerver nem érhető el';
    statusBadge.classList.add('offline');
  });

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  message.textContent = 'Küldés…';
  const payload = {
    sessionId: document.getElementById('sessionId').value.trim(),
    strokes: Number(document.getElementById('strokesInput').value),
    spm: Number(document.getElementById('spmInput').value),
    duration: Number(document.getElementById('durationInput').value),
    timestamp: new Date().toISOString()
  };

  try {
    const response = await fetch('/api/session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Küldési hiba');
    document.getElementById('strokes').textContent = String(result.received.strokes);
    document.getElementById('spm').textContent = result.received.spm.toFixed(1);
    document.getElementById('duration').textContent = formatDuration(result.received.duration);
    document.getElementById('source').textContent = 'Próbaadat';
    message.textContent = 'Sikeres próba: a szerver fogadta az adatot, de nem mentette el.';
  } catch (error) {
    message.textContent = error.message || 'Nem sikerült elküldeni az adatot.';
  }
});

function formatDuration(seconds) {
  const parts = [Math.floor(seconds / 3600), Math.floor((seconds % 3600) / 60), seconds % 60];
  return parts.map((value) => String(value).padStart(2, '0')).join(':');
}
