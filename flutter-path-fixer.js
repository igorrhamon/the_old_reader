/**
 * Flutter Path Fixer for The Old Reader Web App
 * 
 * Este script verifica especificamente o caminho do Flutter que está causando
 * erro ENOENT no run-web-app.bat e cria um arquivo de configuração para resolver.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('==========================================================');
console.log('           FLUTTER PATH FIXER PARA THE OLD READER         ');
console.log('==========================================================');
console.log('');

// Caminhos específicos do Flutter baseados no erro
const errorPath = 'C:\\Users\\igor-\\sdk\\flutter\\bin\\flutter';
const specificPaths = [
  errorPath,
  errorPath + '.bat',
  path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter'),
  path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter.bat')
];

// Primeiro, vamos tentar encontrar o Flutter nos caminhos específicos
console.log('Verificando caminhos específicos mencionados no erro...');
let flutterPath = null;

for (const p of specificPaths) {
  try {
    if (fs.existsSync(p)) {
      console.log(`✓ Encontrado Flutter em: ${p}`);
      flutterPath = p;
      break;
    }
  } catch (e) {
    // Ignorar erros
  }
}

// Se não encontrarmos nos caminhos específicos, vamos buscar em caminhos comuns
if (!flutterPath) {
  console.log('Flutter não encontrado nos caminhos específicos. Procurando em caminhos comuns...');
  
  const commonPaths = [
    path.join(process.env.LOCALAPPDATA || '', 'flutter', 'bin', 'flutter.bat'),
    path.join(process.env.APPDATA || '', 'flutter', 'bin', 'flutter.bat'),
    'C:\\flutter\\bin\\flutter.bat',
    path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter.bat'),
    path.join(process.env.USERPROFILE || '', 'Documents', 'flutter', 'bin', 'flutter.bat'),
    path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter'),
    'C:\\flutter\\bin\\flutter'
  ];
  
  for (const p of commonPaths) {
    try {
      if (fs.existsSync(p)) {
        console.log(`✓ Encontrado Flutter em: ${p}`);
        flutterPath = p;
        break;
      }
    } catch (e) {
      // Ignorar erros
    }
  }
}

// Tente encontrar Flutter usando o PATH do sistema
if (!flutterPath) {
  console.log('Tentando encontrar Flutter no PATH do sistema...');
  
  try {
    const whereOutput = execSync('where flutter', { encoding: 'utf8' });
    const paths = whereOutput.split('\n').filter(p => p.trim());
    
    if (paths.length > 0) {
      flutterPath = paths[0].trim();
      console.log(`✓ Encontrado Flutter no PATH: ${flutterPath}`);
    }
  } catch (e) {
    console.log('Flutter não encontrado no PATH.');
  }
}

if (!flutterPath) {
  console.log('❌ Flutter não encontrado. Por favor, instale o Flutter e adicione-o ao PATH do sistema.');
  console.log('   Visite: https://flutter.dev/docs/get-started/install');
  process.exit(1);
}

// Criar arquivo de configuração para o Flutter
console.log('\nCriando configuração para o caminho do Flutter...');

// Limpar o caminho (remover caracteres de controle)
const cleanPath = flutterPath.replace(/[\r\n]+$/, '');

// Criar um arquivo flutter-config.js para ser usado pelo start-web-app.js
const configContent = `/**
 * Configuração automática para o caminho do Flutter
 * Gerado por flutter-path-fixer.js
 */

module.exports = {
  flutterPath: "${cleanPath.replace(/\\/g, '\\\\')}"
};
`;

fs.writeFileSync(path.join(__dirname, 'flutter-config.js'), configContent);
console.log('✓ Arquivo de configuração criado: flutter-config.js');

// Modificar start-web-app.js para usar o arquivo de configuração
console.log('\nAtualizando start-web-app.js para usar a configuração...');

try {
  const startWebAppPath = path.join(__dirname, 'start-web-app.js');
  let content = fs.readFileSync(startWebAppPath, 'utf8');
  
  // Verificar se já temos a importação do arquivo de configuração
  if (!content.includes('flutter-config')) {
    // Adicionar a importação no início do arquivo, após o primeiro bloco de comentários
    const insertPoint = content.indexOf('const { spawn, exec }');
    if (insertPoint !== -1) {
      const newContent = 
        content.substring(0, insertPoint) +
        '// Import Flutter path configuration\n' +
        'let flutterConfig;\n' +
        'try {\n' +
        '  flutterConfig = require(\'./flutter-config\');\n' +
        '} catch (e) {\n' +
        '  // Config file not found, will use default paths\n' +
        '}\n\n' +
        content.substring(insertPoint);
      
      fs.writeFileSync(startWebAppPath, newContent);
      console.log('✓ Importação de configuração adicionada a start-web-app.js');
      content = newContent;
    }
  }
  
  // Agora, vamos modificar a parte que usa o Flutter
  if (content.includes('const flutterProcess = spawn(flutterPath')) {
    const modified = content.replace(
      /const flutterProcess = spawn\(flutterPath/g,
      'const flutterProcess = spawn(flutterConfig && flutterConfig.flutterPath ? flutterConfig.flutterPath : flutterPath'
    );
    
    fs.writeFileSync(startWebAppPath, modified);
    console.log('✓ Referência ao caminho do Flutter atualizada em start-web-app.js');
  }
  
  if (content.includes('const flutterProcess = spawn(cleanPath')) {
    const modified = content.replace(
      /const flutterProcess = spawn\(cleanPath/g,
      'const flutterProcess = spawn(flutterConfig && flutterConfig.flutterPath ? flutterConfig.flutterPath : cleanPath'
    );
    
    fs.writeFileSync(startWebAppPath, modified);
    console.log('✓ Referência ao caminho limpo do Flutter atualizada em start-web-app.js');
  }
  
  if (content.includes('const flutterProcess = spawn(foundPath')) {
    const modified = content.replace(
      /const flutterProcess = spawn\(foundPath/g,
      'const flutterProcess = spawn(flutterConfig && flutterConfig.flutterPath ? flutterConfig.flutterPath : foundPath'
    );
    
    fs.writeFileSync(startWebAppPath, modified);
    console.log('✓ Referência ao caminho encontrado do Flutter atualizada em start-web-app.js');
  }
  
  console.log('\n✓ Configuração concluída com sucesso!');
  console.log('');
  console.log('Agora você pode executar o app web com:');
  console.log('  .\\run-web-app.bat');
  console.log('');
} catch (e) {
  console.log(`❌ Erro ao atualizar start-web-app.js: ${e.message}`);
  console.log('Por favor, atualize manualmente o arquivo start-web-app.js para usar o caminho do Flutter:');
  console.log(`  ${cleanPath}`);
}
