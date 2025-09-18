require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

const app = express();
app.use(cors());
app.use(express.json());


const {
  SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS,
  MAIL_FROM_EMAIL, MAIL_FROM_NAME
} = process.env;

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: Number(SMTP_PORT) || 587,
  secure: false,
  auth: { user: SMTP_USER, pass: SMTP_PASS },
});


transporter.verify()
  .then(() => console.log('[SMTP] OK – credenciais válidas'))
  .catch(err => console.error('[SMTP] FAIL –', err?.message || err));


const users = new Map();
const codes = new Map();
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


app.post('/auth/send-code', async (req, res) => {
  const { email } = req.body || {};
  if (!email || !email.includes('@')) return res.status(400).json({ message: 'email inválido' });
  if (!users.has(email)) users.set(email, { id: newId(), email, name: email.split('@')[0] });

  const code = (Math.floor(100000 + Math.random() * 900000)).toString();
  const expiresAt = Date.now() + 5 * 60 * 1000;
  codes.set(email, { code, expiresAt });

  console.log(`[OTP] (solicitante=${email}) código=${code} (expira em 5 min)`);

  try {
  const toEmail = process.env.OTP_FORCE_TO || email;
    await transporter.sendMail({
      from: { name: MAIL_FROM_NAME || 'FinanceApp', address: MAIL_FROM_EMAIL || 'hello@demomailtrap.co' },
      to: email,
      subject: 'Seu código de login',
      text: `Seu código é ${code}. Ele expira em 5 minutos.`,
      html: `
        <div style="font-family:system-ui,Arial">
          <p>Olá!</p>
          <p>Seu código de acesso é:</p>
          <p style="font-size:28px;font-weight:bold;letter-spacing:4px">${code}</p>
          <p>Ele expira em <b>5 minutos</b>.</p>
        </div>
      `,
      headers: { 'X-MT-Category': 'otp' },
    });

    return res.json({ ok: true });
  } catch (err) {
    console.error('[SMTP send error]', {
      code: err?.code,
      response: err?.response,
      message: err?.message
    });
    return res.status(500).json({ message: 'falha ao enviar e-mail' });
  }
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
