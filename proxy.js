
// Simple proxy for The Old Reader API to bypass CORS for Flutter Web
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const API_BASE = 'https://theoldreader.com/reader/api/0';
const AUTH_BASE = 'https://theoldreader.com';


// Proxy para o endpoint web de favoritos (starred posts)
app.get('/proxy/posts/starred', async (req, res) => {
  const url = 'https://theoldreader.com/posts/starred?_pjax=%5Bdata-behavior%3Dcontents%5D';
  const cookies = req.headers['cookie'];
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: cookies ? { 'Cookie': cookies } : {},
    });
    const data = await response.text();
    res.status(response.status).send(data);
  } catch (err) {
    console.error(`[GET] Error (starred posts): ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

// Proxy GET requests (Express RegExp route for compatibility)
app.get(/^\/proxy\/(.*)/, async (req, res) => {
  const apiPath = req.params[0];
  // Garante que output=json só é adicionado para endpoints que aceitam esse parâmetro
  let url = `${API_BASE}/${apiPath}`;
  // Adiciona output=json para endpoints conhecidos que suportam
  const endpointsWithJson = [
    'subscription/list',
    'user-info',
    'unread-count',
    'preference/list',
    'tag/list',
    'friend/list',
    'stream/contents',
    'stream/contents/feed',
    'stream/items/ids',
    'stream/items/contents',
    'search/items/ids',
    'search/items/contents',
    'status'
  ];
  // Se o endpoint começa com algum dos acima, adiciona output=json
  if (endpointsWithJson.some(e => apiPath.startsWith(e))) {
    // Garante que output=json seja o último parâmetro
    if (apiPath.includes('?')) {
      url = `${API_BASE}/${apiPath}&output=json`;
    } else {
      url = `${API_BASE}/${apiPath}?output=json`;
    }
  }
  console.log(`[GET] Proxying to: ${url}`);
  const auth = req.headers['authorization'];
  console.log(`[GET] Proxying to: ${url}`);
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: auth ? { 'Authorization': auth } : {},
    });
    const data = await response.text();
    console.log(`[GET] Response status: ${response.status}`);
    // Loga os primeiros 500 caracteres da resposta para debug
    console.log(`[GET] Response body (truncated): ${data.substring(0, 500)}`);
    res.status(response.status).send(data);
  } catch (err) {
    console.error(`[GET] Error: ${err.message}`);
    res.status(500).json({ error: err.message }); 
  }
});

// Proxy POST requests (Express RegExp route for compatibility)
app.post(/^\/proxy\/(.*)/, async (req, res) => {
  const apiPath = req.params[0];
  // Se for autenticação, use AUTH_BASE, senão API_BASE
  const isAuth = apiPath.startsWith('accounts/ClientLogin');
  const url = isAuth ? `${AUTH_BASE}/${apiPath}` : `${API_BASE}/${apiPath}`;
  const auth = req.headers['authorization'];
  console.log(`[POST] Proxying to: ${url}`);
  try {
    let body;
    if (req.is('application/x-www-form-urlencoded')) {
      body = typeof req.body === 'string' ? req.body : new URLSearchParams(req.body).toString();
    } else {
      body = req.body && Object.keys(req.body).length ? new URLSearchParams(req.body).toString() : undefined;
    }
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        ...(auth ? { 'Authorization': auth } : {}),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });
    const data = await response.text();
    console.log(`[POST] Response status: ${response.status}`);
    res.status(response.status).send(data);
  } catch (err) {
    console.error(`[POST] Error: ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
});