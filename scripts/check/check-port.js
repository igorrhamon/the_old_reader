const net = require('net');

const checkPort = (port) => {
  return new Promise((resolve) => {
    const server = net.createServer();
    
    server.once('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        console.log(`A porta ${port} já está em uso.`);
        resolve(false);
      } else {
        console.error(`Erro ao verificar porta: ${err.message}`);
        resolve(false);
      }
    });
    
    server.once('listening', () => {
      server.close();
      console.log(`A porta ${port} está disponível.`);
      resolve(true);
    });
    
    server.listen(port);
  });
};

// Verifica se a porta 3000 está disponível
checkPort(3000)
  .then(isAvailable => {
    if (isAvailable) {
      console.log('Você pode iniciar o proxy na porta 3000.');
    } else {
      console.log('ATENÇÃO: A porta 3000 já está sendo usada por outro processo.');
      console.log('Execute "npx kill-port 3000" para liberar a porta ou');
      console.log('modifique a variável PORT no arquivo proxy.js para usar outra porta.');
    }
  });
