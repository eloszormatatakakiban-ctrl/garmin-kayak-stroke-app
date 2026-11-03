const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const webRoot = path.join(__dirname, 'web');

app.use(express.json({ limit: '1mb' }));
app.use(express.static(webRoot));

app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    app: 'Garmin Kayak Stroke Dashboard',
    status: 'running'
  });
});

app.post('/api/session', (req, res) => {
  const payload = req.body || {};

  if (!payload.sessionId && !payload.timestamp) {
    return res.status(400).json({
      ok: false,
      error: 'Missing session fields.'
    });
  }

  res.json({
    ok: true,
    message: 'Session payload accepted.',
    received: payload
  });
});

app.get('*', (req, res) => {
  res.sendFile(path.join(webRoot, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Garmin kayak dashboard running on port ${PORT}`);
});
