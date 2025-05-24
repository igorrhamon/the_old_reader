// Script de teste para verificar se há erros no proxy
const fs = require('fs');
const path = require('path');

// Configurando diretório de logs
const logDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

// Configurando handlers para erros não tratados
process.on('uncaughtException', (err) => {
  console.error('ERRO NÃO TRATADO:', err);
  fs.appendFileSync(path.join(logDir, 'proxy-error.log'), `${new Date().toISOString()} - Uncaught Exception: ${err.stack}\n`);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('PROMISE REJECTION NÃO TRATADA:', reason);
  fs.appendFileSync(path.join(logDir, 'proxy-error.log'), `${new Date().toISOString()} - Unhandled Rejection: ${reason}\n`);
});

// Importar o proxy para testar
try {
  require('./proxy.js');
  console.log('Proxy carregado com sucesso');
} catch (err) {
  console.error('ERRO AO CARREGAR PROXY:', err);
  fs.appendFileSync(path.join(logDir, 'proxy-error.log'), `${new Date().toISOString()} - Erro ao carregar: ${err.stack}\n`);
}
