const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

// Configure logging
const logDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  console.log(message);
  fs.appendFileSync(path.join(logDir, 'quickadd-test.log'), logMessage);
}

// Função para testar a adição de feed
async function testAddFeed(auth, feedUrl) {
  log(`Testando adição do feed: ${feedUrl}`);
  
  try {
    // Teste direto com a API do The Old Reader
    const directUrl = `https://theoldreader.com/reader/api/0/subscription/quickadd?quickadd=${encodeURIComponent(feedUrl)}`;
    log(`Fazendo requisição direta para: ${directUrl}`);
    
    const response = await fetch(directUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    
    const data = await response.text();
    log(`Status: ${response.status}`);
    log(`Resposta: ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      log('Erro na resposta!');
      
      // Extrai a mensagem de erro específica
      if (data.includes('Required: quickadd')) {
        log('ERRO CRÍTICO: O parâmetro quickadd não está sendo enviado corretamente!');
      }
    } else {
      log('Feed adicionado com sucesso!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    log(`Erro ao fazer requisição: ${error.message}`);
    return { error: error.message };
  }
}

// Função para testar usando o proxy
async function testViaProxy(auth, feedUrl) {
  log(`Testando adição do feed via proxy: ${feedUrl}`);
  
  try {
    // Teste usando o proxy - importante: quickadd deve estar na query string
    const proxyUrl = `http://localhost:3000/proxy/subscription/quickadd?quickadd=${encodeURIComponent(feedUrl)}`;
    log(`Fazendo requisição para o proxy: ${proxyUrl}`);
    
    const response = await fetch(proxyUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
      // Importante: não enviamos o parâmetro no body
    });
    
    const data = await response.text();
    log(`Status via proxy: ${response.status}`);
    log(`Resposta via proxy: ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      log('Erro na resposta via proxy!');
      
      // Extrai a mensagem de erro específica
      if (data.includes('Required: quickadd')) {
        log('ERRO CRÍTICO: O proxy não está enviando o parâmetro quickadd corretamente!');
      }
    } else {
      log('Feed adicionado com sucesso via proxy!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    log(`Erro ao fazer requisição via proxy: ${error.message}`);
    return { error: error.message };
  }
}

// Função para testar enviando o quickadd no corpo (maneira incorreta)
async function testViaProxyBody(auth, feedUrl) {
  log(`Testando adição do feed via proxy com parâmetro no body: ${feedUrl}`);
  
  try {
    // Teste usando o proxy - parâmetro no body (incorreto, mas deve ser corrigido pelo proxy)
    const proxyUrl = `http://localhost:3000/proxy/subscription/quickadd`;
    log(`Fazendo requisição para o proxy (com parâmetro no body): ${proxyUrl}`);
    
    const response = await fetch(proxyUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: `quickadd=${encodeURIComponent(feedUrl)}`
    });
    
    const data = await response.text();
    log(`Status via proxy (body): ${response.status}`);
    log(`Resposta via proxy (body): ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      log('Erro na resposta via proxy (body)!');
      
      // Extrai a mensagem de erro específica
      if (data.includes('Required: quickadd')) {
        log('ERRO CRÍTICO: O proxy não está convertendo o parâmetro quickadd do body para a URL!');
      }
    } else {
      log('Feed adicionado com sucesso via proxy (com parâmetro no body)!');
      log('O proxy está funcionando corretamente ao mover o parâmetro do body para a URL!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    log(`Erro ao fazer requisição via proxy (body): ${error.message}`);
    return { error: error.message };
  }
}

// Função principal para executar todos os testes
async function runAllTests(auth, feedUrl) {
  log('======= INICIANDO TESTES DE ADIÇÃO DE FEED =======');
  log(`Token de autenticação: ${auth.slice(0, 5)}...${auth.slice(-5)}`);
  log(`URL do feed: ${feedUrl}`);
  log('');
  
  log('1. TESTE DIRETO COM A API');
  const directResult = await testAddFeed(auth, feedUrl);
  log('');
  
  log('2. TESTE VIA PROXY (URL)');
  const proxyResult = await testViaProxy(auth, feedUrl);
  log('');
  
  log('3. TESTE VIA PROXY (BODY)');
  const proxyBodyResult = await testViaProxyBody(auth, feedUrl);
  log('');
  
  log('======= RESULTADOS DOS TESTES =======');
  
  // Compara os resultados
  const directSuccess = !directResult.error && !directResult.data?.includes('error');
  const proxySuccess = !proxyResult.error && !proxyResult.data?.includes('error');
  const proxyBodySuccess = !proxyBodyResult.error && !proxyBodyResult.data?.includes('error');
  
  log(`Teste direto: ${directSuccess ? 'SUCESSO' : 'FALHA'}`);
  log(`Teste via proxy (URL): ${proxySuccess ? 'SUCESSO' : 'FALHA'}`);
  log(`Teste via proxy (BODY): ${proxyBodySuccess ? 'SUCESSO' : 'FALHA'}`);
  
  // Avalia a correção do proxy
  if (proxySuccess && proxyBodySuccess) {
    log('');
    log('CONCLUSÃO: O proxy está funcionando corretamente!');
    log('O parâmetro quickadd está sendo tratado adequadamente tanto na URL quanto no body.');
  } else if (directSuccess && !proxySuccess) {
    log('');
    log('CONCLUSÃO: O proxy NÃO está funcionando corretamente ao passar o parâmetro na URL.');
    log('Ainda há um problema na implementação do proxy.');
  } else if (directSuccess && !proxyBodySuccess) {
    log('');
    log('CONCLUSÃO: O proxy NÃO está convertendo corretamente o parâmetro do body para a URL.');
    log('A correção para o parâmetro no body ainda não está funcionando.');
  } else if (!directSuccess) {
    log('');
    log('CONCLUSÃO: O teste direto com a API falhou!');
    log('Verifique se o token de autenticação está correto ou se há outros problemas na API.');
  }
}

// Executa os testes se for chamado diretamente
if (require.main === module) {
  // Verifica os argumentos da linha de comando
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.error('Uso: node test-quickadd.js <auth_token> <feed_url>');
    console.error('Exemplo: node test-quickadd.js abcdef123456 https://blog.theoldreader.com/rss');
    process.exit(1);
  }
  
  const auth = args[0];
  const feedUrl = args[1];
  
  // Executa os testes
  runAllTests(auth, feedUrl);
}

// Exporta as funções para uso em outros módulos
module.exports = {
  testAddFeed,
  testViaProxy,
  testViaProxyBody,
  runAllTests
};
