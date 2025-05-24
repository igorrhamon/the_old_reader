/**
 * The Old Reader - Automatic Setup and Launcher
 * 
 * Este script configura automaticamente o ambiente e inicia o aplicativo web:
 * 1. Verifica e configura o Flutter
 * 2. Inicia o servidor proxy
 * 3. Inicia o aplicativo Flutter Web
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

console.log(`${colors.bright}${colors.blue}==========================================================`);
console.log(`          THE OLD READER - AUTOMATIC LAUNCHER          `);
console.log(`==========================================================${colors.reset}`);
console.log('');

// Verificar requisitos
console.log(`${colors.cyan}Verificando requisitos...${colors.reset}`);

// 1. Verificar Node.js
try {
  const nodeVersion = execSync('node --version', { encoding: 'utf8' }).trim();
  console.log(`${colors.green}✓ Node.js instalado: ${nodeVersion}${colors.reset}`);
} catch (e) {
  console.log(`${colors.red}✗ Node.js não encontrado. Por favor, instale o Node.js.${colors.reset}`);
  console.log(`  Download: https://nodejs.org/`);
  process.exit(1);
}

// 2. Verificar/configurar Flutter
console.log(`${colors.cyan}Verificando Flutter...${colors.reset}`);

// Verificar se já temos um arquivo de configuração
let flutterPath = null;
if (fs.existsSync('./flutter-config.js')) {
  try {
    const config = require('./flutter-config');
    flutterPath = config.flutterPath;
    console.log(`${colors.green}✓ Configuração do Flutter encontrada: ${flutterPath}${colors.reset}`);
  } catch (e) {
    console.log(`${colors.yellow}! Erro ao carregar configuração do Flutter: ${e.message}${colors.reset}`);
  }
}

// Se não temos um caminho configurado, verificar se o Flutter está no PATH
if (!flutterPath) {
  try {
    const flutterVersion = execSync('flutter --version', { encoding: 'utf8' });
    console.log(`${colors.green}✓ Flutter disponível no PATH${colors.reset}`);
    
    // Criar arquivo de configuração
    const configContent = `/**
 * Flutter Path Configuration
 * Generated automatically
 */

module.exports = {
  flutterPath: "flutter"  // Using system PATH
};
`;
    fs.writeFileSync('./flutter-config.js', configContent);
    console.log(`${colors.green}✓ Configuração do Flutter criada.${colors.reset}`);
    flutterPath = 'flutter';
    
  } catch (e) {
    console.log(`${colors.yellow}! Flutter não encontrado no PATH. Buscando instalações...${colors.reset}`);
    
    // Procurar em locais comuns
    const possiblePaths = [
      // Windows com .bat
      path.join(process.env.LOCALAPPDATA || '', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.APPDATA || '', 'flutter', 'bin', 'flutter.bat'),
      'C:\\flutter\\bin\\flutter.bat',
      path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.USERPROFILE || '', 'Documents', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter.bat'),
      // Windows sem .bat
      path.join(process.env.LOCALAPPDATA || '', 'flutter', 'bin', 'flutter'),
      path.join(process.env.APPDATA || '', 'flutter', 'bin', 'flutter'),
      'C:\\flutter\\bin\\flutter',
      path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter'),
      path.join(process.env.USERPROFILE || '', 'Documents', 'flutter', 'bin', 'flutter'),
      path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter'),
      // Linux/macOS
      '/usr/local/flutter/bin/flutter',
      '/opt/flutter/bin/flutter',
      path.join(process.env.HOME || '', 'flutter', 'bin', 'flutter')
    ];
    
    for (const p of possiblePaths) {
      try {
        if (fs.existsSync(p)) {
          console.log(`${colors.green}✓ Flutter encontrado em: ${p}${colors.reset}`);
          
          // Testar se o Flutter funciona
          try {
            execSync(`"${p}" --version`, { encoding: 'utf8' });
            
            // Criar arquivo de configuração
            const configContent = `/**
 * Flutter Path Configuration
 * Generated automatically
 */

module.exports = {
  flutterPath: "${p.replace(/\\/g, '\\\\')}"
};
`;
            fs.writeFileSync('./flutter-config.js', configContent);
            console.log(`${colors.green}✓ Configuração do Flutter criada.${colors.reset}`);
            flutterPath = p;
            break;
          } catch (e) {
            console.log(`${colors.yellow}! Flutter encontrado mas não pode ser executado: ${e.message}${colors.reset}`);
          }
        }
      } catch (e) {
        // Ignorar erros
      }
    }
  }
}

// Se ainda não temos um caminho para o Flutter, perguntar ao usuário
if (!flutterPath) {
  console.log(`${colors.red}✗ Flutter não encontrado automaticamente.${colors.reset}`);
  console.log(`${colors.yellow}Por favor, execute um dos seguintes scripts:${colors.reset}`);
  console.log(`  1. .\\fix-flutter-path.bat - para configurar o caminho do Flutter`);
  console.log(`  2. .\\check-flutter.bat - para verificar sua instalação do Flutter`);
  process.exit(1);
}

// 3. Verificar dependências do proxy
console.log(`${colors.cyan}Verificando dependências do proxy...${colors.reset}`);

const requiredPackages = ['express', 'cors', 'node-fetch'];
let allDependenciesInstalled = true;

for (const pkg of requiredPackages) {
  try {
    require.resolve(pkg);
    console.log(`${colors.green}✓ ${pkg} já instalado.${colors.reset}`);
  } catch (e) {
    console.log(`${colors.yellow}! ${pkg} não instalado. Instalando...${colors.reset}`);
    try {
      execSync(`npm install ${pkg}`, { stdio: 'inherit' });
      console.log(`${colors.green}✓ ${pkg} instalado com sucesso.${colors.reset}`);
    } catch (e) {
      console.log(`${colors.red}✗ Falha ao instalar ${pkg}: ${e.message}${colors.reset}`);
      allDependenciesInstalled = false;
    }
  }
}

if (!allDependenciesInstalled) {
  console.log(`${colors.red}✗ Nem todas as dependências foram instaladas.${colors.reset}`);
  console.log(`${colors.yellow}Tente executar manualmente: npm install express cors node-fetch${colors.reset}`);
  process.exit(1);
}

// 4. Iniciar o aplicativo
console.log('');
console.log(`${colors.bright}${colors.green}Tudo pronto! Iniciando o aplicativo...${colors.reset}`);
console.log('');

// Iniciar o start-web-app.js
const app = spawn('node', ['start-web-app.js'], { stdio: 'inherit' });

app.on('close', (code) => {
  if (code !== 0) {
    console.log(`${colors.red}O aplicativo foi encerrado com código de erro: ${code}${colors.reset}`);
    process.exit(code);
  }
});

// Lidar com sinais para encerramento limpo
process.on('SIGINT', () => {
  console.log(`${colors.yellow}Encerrando o aplicativo...${colors.reset}`);
  app.kill();
});

process.on('SIGTERM', () => {
  console.log(`${colors.yellow}Encerrando o aplicativo...${colors.reset}`);
  app.kill();
});
