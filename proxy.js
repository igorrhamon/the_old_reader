// Simple proxy for The Old Reader API to bypass CORS for Flutter Web
const express = require("express");
const cors = require("cors");

// Verifica se fetch está disponível globalmente (Node.js 18+) 
// ou se precisa ser importado (Node.js 16 ou anterior)
let fetch;
try {
  // Para Node.js <18
  if (!globalThis.fetch) {
    const nodeFetch = require('node-fetch');
    fetch = nodeFetch.default || nodeFetch;
    console.log("Usando node-fetch importado");
  } else {
    fetch = globalThis.fetch;
    console.log("Usando fetch global");
  }
} catch (err) {
  console.error(`Erro ao configurar fetch: ${err.message}`);
  console.error("Se você estiver usando Node.js <18, instale node-fetch com: npm install node-fetch");
  process.exit(1);
}

// Tratamento de erros global para evitar que o processo termine inesperadamente
process.on('uncaughtException', (err) => {
  console.error('Erro não tratado capturado:');
  console.error(err);
  console.error(err.stack);
  // Não terminamos o processo, permitindo que ele continue funcionando
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Promessa rejeitada não tratada:');
  console.error(reason);
  // Não terminamos o processo, permitindo que ele continue funcionando
});

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const API_BASE = "https://theoldreader.com/reader/api/0";
const AUTH_BASE = "https://theoldreader.com";


// Proxy para o endpoint web de favoritos (starred posts)
app.get("/proxy/posts/starred", async (req, res) => {
  const url = "https://theoldreader.com/posts/starred?_pjax=%5Bdata-behavior%3Dcontents%5D";
  const cookies = req.headers["cookie"];
  try {
    const response = await fetch(url, {
      method: "GET",
      headers: cookies ? { "Cookie": cookies } : {},
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
    "subscription/list",
    "user-info",
    "unread-count",
    "preference/list",
    "tag/list",
    "friend/list",
    "stream/contents",
    "stream/contents/feed",
    "stream/items/ids",
    "stream/items/contents",
    "search/items/ids",
    "search/items/contents",
    "status"
  ];
  // Se o endpoint começa com algum dos acima, adiciona output=json
  if (endpointsWithJson.some(e => apiPath.startsWith(e))) {
    // Garante que output=json seja o último parâmetro
    if (apiPath.includes("?")) {
      url = `${API_BASE}/${apiPath}&output=json`;
    } else {
      url = `${API_BASE}/${apiPath}?output=json`;
    }
  }

  const auth = req.headers["authorization"];
  console.log(`[GET] Proxying to: ${url}`);

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: auth ? { "Authorization": auth } : {},
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

// Handler especial para o endpoint quickadd para fins de debug
app.post("/proxy/subscription/quickadd", (req, res, next) => {
  console.log("================= REQUISIÇÃO QUICKADD =================");
  console.log(`URL completa: ${req.originalUrl}`);
  console.log(`Query string completa: ${JSON.stringify(req.query)}`);
  console.log(`Body completo: ${JSON.stringify(req.body)}`);
  
  // Continua para o handler geral
  next();
});

// Proxy POST requests (Express RegExp route for compatibility)
app.post(/^\/proxy\/(.*)/, async (req, res) => {
  let apiPath = req.params[0];
  
  // Vamos registrar a URL completa recebida para debug
  console.log(`[POST] Recebida requisição para: /proxy/${apiPath}`);
  console.log(`[POST] URL original completa: ${req.originalUrl}`);
  
  // Preserva a query string original
  const originalQueryString = req.originalUrl.includes('?') ? req.originalUrl.split('?')[1] : '';
  
  // Se for autenticação, use AUTH_BASE, senão API_BASE
  const isAuth = apiPath.startsWith("accounts/ClientLogin");
  
  // Verifica se é uma requisição de quickadd (adicionar feed)
  const isQuickadd = apiPath.includes("subscription/quickadd");
  
  // Para o quickadd, precisamos garantir que o parâmetro quickadd esteja na URL final
  let url;
  
  if (isQuickadd) {
    // Procura o parâmetro quickadd na query string
    const quickaddValue = req.query.quickadd || (req.body && req.body.quickadd);
    
    if (quickaddValue) {
      // Constrói a URL com o parâmetro na query string
      url = isAuth 
          ? `${AUTH_BASE}/subscription/quickadd?quickadd=${encodeURIComponent(quickaddValue)}` 
          : `${API_BASE}/subscription/quickadd?quickadd=${encodeURIComponent(quickaddValue)}`;
      
      console.log(`[POST] URL para quickadd construída: ${url}`);
    } else {
      // Se não encontramos o parâmetro, vamos tentar preservar a query string original
      if (originalQueryString) {
        url = isAuth
            ? `${AUTH_BASE}/${apiPath.split('?')[0]}?${originalQueryString}`
            : `${API_BASE}/${apiPath.split('?')[0]}?${originalQueryString}`;
      } else {
        // Usa a URL sem parâmetros (provavelmente dará erro)
        url = isAuth ? `${AUTH_BASE}/${apiPath}` : `${API_BASE}/${apiPath}`;
      }
    }
  } else {
    // Para outras requisições, separa a query string
    if (originalQueryString) {
      url = isAuth
          ? `${AUTH_BASE}/${apiPath.split('?')[0]}?${originalQueryString}`
          : `${API_BASE}/${apiPath.split('?')[0]}?${originalQueryString}`;
    } else {
      url = isAuth ? `${AUTH_BASE}/${apiPath}` : `${API_BASE}/${apiPath}`;
    }
  }

  console.log(`[POST] Proxying to: ${url}`);
  
  const auth = req.headers["authorization"];

  try {
    let body;
    
    // Para quickadd, não enviamos o parâmetro no body, pois já está na URL
    if (isQuickadd) {
      body = undefined;
    } else if (req.is("application/x-www-form-urlencoded")) {
      body = typeof req.body === "string" ? req.body : new URLSearchParams(req.body).toString();
    } else {
      body = req.body && Object.keys(req.body).length ? new URLSearchParams(req.body).toString() : undefined;
    }
    
    const response = await fetch(url, {
      method: "POST",
      headers: {
        ...(auth ? { "Authorization": auth } : {}),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body,
    });
    
    const data = await response.text();
    console.log(`[POST] Response status: ${response.status}`);
    console.log(`[POST] Response body (truncated): ${data.substring(0, 500)}`);
    
    // Para debug - mostrar detalhes completos da requisição
    console.log(`[POST] Requisição completa:
      URL: ${url}
      Método: POST
      Headers: ${JSON.stringify({
        ...(auth ? { "Authorization": "***" } : {}),
        "Content-Type": "application/x-www-form-urlencoded",
      })}
      Body: ${body || 'nenhum'}
    `);
    
    // Se a resposta for JSON, tenta parsear e logar
    try {
      if (response.headers.get("content-type")?.includes("application/json")) {
        const jsonData = JSON.parse(data);
        console.log(`[POST] JSON Response: ${JSON.stringify(jsonData)}`);
      } else {
        console.log(`[POST] Response is not JSON.`);
      }
    } catch (e) {
      console.error(`[POST] Failed to parse JSON: ${e.message}`);
    }

    res.status(response.status).send(data);
  } catch (err) {
    console.error(`[POST] Error: ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
}).on('error', (err) => {
  console.error(`Erro ao iniciar o servidor: ${err.message}`);
  if (err.code === 'EADDRINUSE') {
    console.error(`A porta ${PORT} já está em uso. Por favor, encerre o processo que está usando esta porta ou escolha outra porta.`);
  }
});
// Para rodar o servidor, use o comando:
// node proxy.js