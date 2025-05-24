/**
 * Este script ajuda a diagnosticar o problema com o endpoint quickadd
 * Ele cria um servidor de teste simples para analisar como o parâmetro quickadd
 * está sendo enviado nas requisições
 */

const express = require('express');
const app = express();
const PORT = 3001;

// Middleware para processar URLs e bodys
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Endpoint para testar quickadd
app.post('/subscription/quickadd', (req, res) => {
  console.log('====== REQUISIÇÃO RECEBIDA ======');
  
  // Exibe informações da URL
  console.log(`URL original: ${req.originalUrl}`);
  console.log(`Path: ${req.path}`);
  console.log(`Query string:`, req.query);
  
  // Verifica se o parâmetro quickadd está presente na query string
  const hasQuickaddInQuery = req.query.hasOwnProperty('quickadd');
  console.log(`Parâmetro quickadd na query: ${hasQuickaddInQuery ? 'SIM' : 'NÃO'}`);
  if (hasQuickaddInQuery) {
    console.log(`Valor de quickadd na query: ${req.query.quickadd}`);
  }
  
  // Verifica se o parâmetro quickadd está presente no body
  const hasQuickaddInBody = req.body && req.body.hasOwnProperty('quickadd');
  console.log(`Parâmetro quickadd no body: ${hasQuickaddInBody ? 'SIM' : 'NÃO'}`);
  if (hasQuickaddInBody) {
    console.log(`Valor de quickadd no body: ${req.body.quickadd}`);
  }
  
  // Cabeçalhos da requisição
  console.log('Cabeçalhos:');
  Object.entries(req.headers).forEach(([key, value]) => {
    console.log(`  ${key}: ${key === 'authorization' ? '***' : value}`);
  });
  
  // Corpo da requisição
  console.log('Corpo da requisição:');
  console.log(req.body);
  
  // Resposta ao cliente
  if (hasQuickaddInQuery) {
    // Simula a resposta da API real quando o parâmetro está presente
    res.status(200).json({
      query: req.query.quickadd,
      numResults: 1,
      streamId: "feed/001simulatedStreamId001"
    });
  } else {
    // Simula o erro da API real quando o parâmetro não está presente
    res.status(200).send('<?xml version="1.0" encoding="UTF-8"?>\n<errors type="array">\n  <error>Required: quickadd</error>\n</errors>');
  }
});

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`Servidor de diagnóstico rodando em http://localhost:${PORT}`);
  console.log('\nPara testar, envie requisições POST para:');
  console.log(`http://localhost:${PORT}/subscription/quickadd?quickadd=url_do_feed`);
  console.log('\nVocê verá as informações detalhadas de como os parâmetros são recebidos.');
  console.log('\nPressione Ctrl+C para encerrar.\n');
});
