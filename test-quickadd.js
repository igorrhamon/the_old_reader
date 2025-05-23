const fetch = require('node-fetch');

// Função para testar a adição de feed
async function testAddFeed(auth, feedUrl) {
  console.log(`Testando adição do feed: ${feedUrl}`);
  
  try {
    // Teste direto com a API do The Old Reader
    const directUrl = `https://theoldreader.com/reader/api/0/subscription/quickadd?quickadd=${encodeURIComponent(feedUrl)}`;
    console.log(`Fazendo requisição direta para: ${directUrl}`);
    
    const response = await fetch(directUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    
    const data = await response.text();
    console.log(`Status: ${response.status}`);
    console.log(`Resposta: ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      console.error('Erro na resposta!');
      
      // Extrai a mensagem de erro específica
      if (data.includes('Required: quickadd')) {
        console.error('ERRO CRÍTICO: O parâmetro quickadd não está sendo enviado corretamente!');
      }
    } else {
      console.log('Feed adicionado com sucesso!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    console.error(`Erro ao fazer requisição: ${error.message}`);
    return { error: error.message };
  }
}

// Função para testar usando o proxy
async function testViaProxy(auth, feedUrl) {
  console.log(`Testando adição do feed via proxy: ${feedUrl}`);
  
  try {
    // Teste usando o proxy - importante: quickadd deve estar na query string
    const proxyUrl = `http://localhost:3000/proxy/subscription/quickadd?quickadd=${encodeURIComponent(feedUrl)}`;
    console.log(`Fazendo requisição para o proxy: ${proxyUrl}`);
    
    const response = await fetch(proxyUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
      // Importante: não enviamos o parâmetro no body
    });
    
    const data = await response.text();
    console.log(`Status via proxy: ${response.status}`);
    console.log(`Resposta via proxy: ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      console.error('Erro na resposta via proxy!');
      
      // Extrai a mensagem de erro específica
      if (data.includes('Required: quickadd')) {
        console.error('ERRO CRÍTICO: O proxy não está enviando o parâmetro quickadd corretamente!');
      }
    } else {
      console.log('Feed adicionado com sucesso via proxy!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    console.error(`Erro ao fazer requisição via proxy: ${error.message}`);
    return { error: error.message };
  }
}

// Função para testar enviando o quickadd no corpo (maneira incorreta)
async function testBodyParam(auth, feedUrl) {
  console.log(`Testando adição do feed via proxy com parâmetro no body (maneira incorreta): ${feedUrl}`);
  
  try {
    // Teste enviando o parâmetro no corpo da requisição
    const proxyUrl = `http://localhost:3000/proxy/subscription/quickadd`;
    console.log(`Fazendo requisição para o proxy (com body): ${proxyUrl}`);
    
    const response = await fetch(proxyUrl, {
      method: 'POST',
      headers: {
        'Authorization': `GoogleLogin auth=${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: `quickadd=${encodeURIComponent(feedUrl)}`
    });
    
    const data = await response.text();
    console.log(`Status (body): ${response.status}`);
    console.log(`Resposta (body): ${data}`);
    
    // Verifica se a resposta contém erro
    if (data.includes('error')) {
      console.error('Erro na resposta (parâmetro no body)!');
      
      if (data.includes('Required: quickadd')) {
        console.error('ERRO ESPERADO: Enviar o parâmetro apenas no body não funciona!');
      }
    } else {
      console.log('CORRIGIDO: O proxy soube extrair o parâmetro do body e movê-lo para a URL!');
    }
    
    return { status: response.status, data };
  } catch (error) {
    console.error(`Erro ao fazer requisição (body): ${error.message}`);
    return { error: error.message };
  }
}

// Execute os testes
async function runTests() {
  const auth = process.argv[2]; // Token de autenticação
  const feedUrl = process.argv[3] || 'blog.theoldreader.com'; // URL do feed para teste
  
  if (!auth) {
    console.error('Por favor, forneça o token de autenticação como argumento:');
    console.error('node test-quickadd.js SEU_TOKEN feedurl');
    return;
  }
  
  console.log('==========================================');
  console.log('TESTES DO ENDPOINT QUICKADD - THE OLD READER');
  console.log('==========================================');
  console.log('Objetivo: Verificar se o parâmetro quickadd está sendo enviado corretamente');
  console.log(`Token: ${auth ? '******' : 'Não fornecido'}`);
  console.log(`Feed URL: ${feedUrl}`);
  console.log('==========================================');
  
  console.log('\n==== TESTE DIRETO (API OFICIAL) ====');
  await testAddFeed(auth, feedUrl);
  
  console.log('\n==== TESTE VIA PROXY (PARÂMETRO NA URL) ====');
  await testViaProxy(auth, feedUrl);
  
  console.log('\n==== TESTE VIA PROXY (PARÂMETRO NO BODY) ====');
  await testBodyParam(auth, feedUrl);
  
  console.log('\n==========================================');
  console.log('TESTES CONCLUÍDOS');
  console.log('==========================================');
}

runTests();
