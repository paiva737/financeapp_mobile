const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// "banco" na memória (apenas DEV)
const users = new Map();      // email -> { id, email, name }
const codes = new Map();      // email -> { code, expiresAt }
const REFRESH_TOKENS = new Set();

const JWT_SECRET = 'dev-secret-apenas-local';
const ACCESS_TTL = '15m';
const REFRESH_TTL = '7d';

const newId = () => Math.random().toString(36).slice(2, 10);
const sign = (payload, exp) => jwt.sign(payload, JWT_SECRET, { expiresIn: exp });

function auth(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.status(401).json({ message: 'missing token' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ message: 'invalid token' });
  }
}

app.get('/health', (_, res) => res.json({ ok: true }));

app.post('/auth/register-email', (req, res) => {
  const { email } = req.body || {};
  if (!email || !email.includes('@')) return res.status(400).json({ message: 'email inválido' });
  if (!users.has(email)) users.set(email, { id: newId(), email, name: email.split('@')[0] });
  return res.json({ ok: true });
});

app.post('/auth/send-code', (req, res) => {
  const { email } = req.body || {};
  if (!email || !email.includes('@')) return res.status(400).json({ message: 'email inválido' });
  if (!users.has(email)) users.set(email, { id: newId(), email, name: email.split('@')[0] });

  const code = (Math.floor(100000 + Math.random() * 900000)).toString();
  const expiresAt = Date.now() + 5 * 60 * 1000;
  codes.set(email, { code, expiresAt });

  console.log(`[OTP] Código para ${email}: ${code} (expira em 5 min)`);
  return res.json({ ok: true });
});

app.post('/auth/verify-code', (req, res) => {
  const { email, code } = req.body || {};
  const rec = codes.get(email);
  if (!rec || rec.code !== code) return res.status(401).json({ message: 'código inválido' });
  if (Date.now() > rec.expiresAt) return res.status(401).json({ message: 'código expirado' });

  const user = users.get(email);
  const accessToken  = sign({ sub: user.id, email: user.email }, ACCESS_TTL);
  const refreshToken = sign({ sub: user.id, email: user.email, typ: 'refresh' }, REFRESH_TTL);
  REFRESH_TOKENS.add(refreshToken);
  codes.delete(email);

  return res.json({ accessToken, refreshToken });
});

app.post('/auth/refresh', (req, res) => {
  const { refreshToken } = req.body || {};
  if (!refreshToken || !REFRESH_TOKENS.has(refreshToken)) {
    return res.status(401).json({ message: 'refresh inválido' });
  }
  try {
    const p = jwt.verify(refreshToken, JWT_SECRET);
    const accessToken  = sign({ sub: p.sub, email: p.email }, ACCESS_TTL);
    const newRefresh   = sign({ sub: p.sub, email: p.email, typ: 'refresh' }, REFRESH_TTL);
    REFRESH_TOKENS.delete(refreshToken);
    REFRESH_TOKENS.add(newRefresh);
    return res.json({ accessToken, refreshToken: newRefresh });
  } catch {
    return res.status(401).json({ message: 'refresh expirado' });
  }
});

app.get('/auth/me', auth, (req, res) => {
  const user = [...users.values()].find(u => u.id === req.user.sub);
  if (!user) return res.status(404).json({ message: 'user not found' });
  return res.json({ id: user.id, email: user.email, name: user.name });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Auth server ON http://127.0.0.1:${PORT}`);
});
