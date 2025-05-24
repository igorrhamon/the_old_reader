/**
 * The Old Reader App Launcher
 * 
 * This script manages the startup process for The Old Reader app in web mode.
 * It starts the proxy server, detects the port, and launches the Flutter web app.
 */

const { spawn, exec } = require('child_process');
const net = require('net');
const path = require('path');
const fs = require('fs');
const readline = require('readline');

// ANSI color codes for prettier console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  bgRed: '\x1b[41m',
  bgGreen: '\x1b[42m',
  bgBlue: '\x1b[44m',
};

// Configuration
const DEFAULT_PROXY_PORT = 3000;
const DEFAULT_WEB_PORT = 8000;
const WEB_HOSTNAME = '127.0.0.1';

// Check if a port is available
function isPortAvailable(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    
    server.once('error', () => {
      resolve(false);
    });
    
    server.once('listening', () => {
      server.close();
      resolve(true);
    });
    
    server.listen(port);
  });
}

// Find an available port starting from the given port
async function findAvailablePort(startPort) {
  let port = startPort;
  while (port < startPort + 100) { // Try 100 ports
    if (await isPortAvailable(port)) {
      return port;
    }
    port++;
  }
  return null; // No available port found
}

// Get the process using a port (Windows-specific)
function getProcessUsingPort(port) {
  return new Promise((resolve) => {
    exec(`netstat -ano | findstr :${port} | findstr LISTENING`, (error, stdout) => {
      if (error || !stdout) {
        resolve(null);
        return;
      }
      
      const match = stdout.match(/LISTENING\s+(\d+)/);
      if (!match || !match[1]) {
        resolve(null);
        return;
      }
      
      const pid = match[1];
      exec(`tasklist /fi "PID eq ${pid}" /fo csv /nh`, (error, stdout) => {
        if (error || !stdout) {
          resolve({ pid });
          return;
        }
        
        const parts = stdout.split(',');
        if (parts.length >= 2) {
          const processName = parts[0].replace(/"/g, '');
          resolve({ pid, name: processName });
        } else {
          resolve({ pid });
        }
      });
    });
  });
}

// Check if a command exists and get its path
function getCommandPath(command) {
  return new Promise((resolve) => {
    const platform = process.platform;
    const cmd = platform === 'win32' ? 'where' : 'which';
    
    exec(`${cmd} ${command}`, (error, stdout) => {
      if (error) {
        resolve(null);      } else {
        // Get the first line from the output (the path to the command)
        // Clean the path to remove any control characters (like \r) that might be present
        const path = stdout.toString().trim().split('\n')[0].trim().replace(/[\r\n]+$/, '');
        resolve(path);
      }
    });
  });
}

// Check if a command exists
function commandExists(command) {
  return new Promise((resolve) => {
    getCommandPath(command).then(path => {
      resolve(!!path);
    });
  });
}

// Install a Node.js package if it's not already installed
async function ensurePackageInstalled(packageName) {
  try {
    require.resolve(packageName);
    console.log(`${colors.green}✓${colors.reset} ${packageName} is already installed.`);
    return true;
  } catch (e) {
    console.log(`${colors.yellow}!${colors.reset} ${packageName} is not installed. Installing...`);
    
    return new Promise((resolve) => {
      const install = spawn('npm', ['install', packageName], {
        stdio: 'inherit'
      });
      
      install.on('close', (code) => {
        if (code === 0) {
          console.log(`${colors.green}✓${colors.reset} ${packageName} installed successfully.`);
          resolve(true);
        } else {
          console.error(`${colors.red}✗${colors.reset} Failed to install ${packageName}.`);
          resolve(false);
        }
      });
    });
  }
}

// Start the proxy server and return the port it's running on
async function startProxyServer() {
  console.log(`\n${colors.bright}${colors.blue}Starting proxy server...${colors.reset}`);
  
  // Check proxy port availability
  let proxyPort = DEFAULT_PROXY_PORT;
  const isProxyPortAvailable = await isPortAvailable(proxyPort);
  
  if (!isProxyPortAvailable) {
    const processInfo = await getProcessUsingPort(proxyPort);
    console.log(`${colors.yellow}!${colors.reset} Port ${proxyPort} is already in use.`);
    
    if (processInfo) {
      console.log(`  Process: ${processInfo.name || 'Unknown'} (PID: ${processInfo.pid})`);
      
      // Ask if user wants to terminate the process
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });
      
      const answer = await new Promise((resolve) => {
        rl.question(`${colors.yellow}?${colors.reset} Do you want to terminate this process? (y/n) `, (answer) => {
          rl.close();
          resolve(answer.toLowerCase());
        });
      });
      
      if (answer === 'y' || answer === 'yes') {
        try {
          process.kill(processInfo.pid);
          console.log(`${colors.green}✓${colors.reset} Process terminated.`);
          // Wait a moment for the port to be released
          await new Promise(resolve => setTimeout(resolve, 1000));
          if (await isPortAvailable(proxyPort)) {
            console.log(`${colors.green}✓${colors.reset} Port ${proxyPort} is now available.`);
          } else {
            throw new Error('Port still in use');
          }
        } catch (e) {
          console.log(`${colors.red}✗${colors.reset} Failed to terminate process.`);
          // Try to find an alternative port
          const alternativePort = await findAvailablePort(proxyPort + 1);
          if (alternativePort) {
            console.log(`${colors.yellow}!${colors.reset} Using alternative port: ${alternativePort}`);
            proxyPort = alternativePort;
          } else {
            console.error(`${colors.red}✗${colors.reset} No available ports found.`);
            process.exit(1);
          }
        }
      } else {
        // Try to find an alternative port
        const alternativePort = await findAvailablePort(proxyPort + 1);
        if (alternativePort) {
          console.log(`${colors.yellow}!${colors.reset} Using alternative port: ${alternativePort}`);
          proxyPort = alternativePort;
        } else {
          console.error(`${colors.red}✗${colors.reset} No available ports found.`);
          process.exit(1);
        }
      }
    } else {
      // No process info, just try to find an alternative port
      const alternativePort = await findAvailablePort(proxyPort + 1);
      if (alternativePort) {
        console.log(`${colors.yellow}!${colors.reset} Using alternative port: ${alternativePort}`);
        proxyPort = alternativePort;
      } else {
        console.error(`${colors.red}✗${colors.reset} No available ports found.`);
        process.exit(1);
      }
    }
  }
  
  // Ensure required packages are installed
  const packages = ['express', 'cors', 'node-fetch'];
  for (const pkg of packages) {
    const installed = await ensurePackageInstalled(pkg);
    if (!installed) {
      console.error(`${colors.red}✗${colors.reset} Failed to install required package: ${pkg}`);
      process.exit(1);
    }
  }
  
  // Start the proxy server
  console.log(`${colors.green}✓${colors.reset} Starting proxy server on port ${proxyPort}...`);
  
  const proxyProcess = spawn('node', ['proxy.js'], {
    env: { ...process.env, PORT: proxyPort.toString() },
    stdio: ['ignore', 'pipe', 'pipe']
  });
  
  // Handle proxy server output
  proxyProcess.stdout.on('data', (data) => {
    const output = data.toString().trim();
    console.log(`${colors.dim}[Proxy]${colors.reset} ${output}`);
  });
  
  proxyProcess.stderr.on('data', (data) => {
    const output = data.toString().trim();
    console.error(`${colors.red}[Proxy Error]${colors.reset} ${output}`);
  });
  
  // Wait for the proxy server to start
  await new Promise((resolve) => setTimeout(resolve, 2000));
  
  return { proxyProcess, proxyPort };
}

// Start the Flutter web app
async function startFlutterWeb(proxyPort) {
  console.log(`\n${colors.bright}${colors.blue}Starting Flutter web app...${colors.reset}`);
  
  // Check if Flutter is installed
  const flutterExists = await commandExists('flutter');
  if (!flutterExists) {
    console.error(`${colors.red}✗${colors.reset} Flutter command not found. Please install Flutter and add it to your PATH.`);
    process.exit(1);
  }
  
  // Check web port availability
  let webPort = DEFAULT_WEB_PORT;
  const isWebPortAvailable = await isPortAvailable(webPort);
  
  if (!isWebPortAvailable) {
    const processInfo = await getProcessUsingPort(webPort);
    console.log(`${colors.yellow}!${colors.reset} Port ${webPort} is already in use.`);
    
    if (processInfo) {
      console.log(`  Process: ${processInfo.name || 'Unknown'} (PID: ${processInfo.pid})`);
      
      // Ask if user wants to terminate the process
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });
      
      const answer = await new Promise((resolve) => {
        rl.question(`${colors.yellow}?${colors.reset} Do you want to terminate this process? (y/n) `, (answer) => {
          rl.close();
          resolve(answer.toLowerCase());
        });
      });
      
      if (answer === 'y' || answer === 'yes') {
        try {
          process.kill(processInfo.pid);
          console.log(`${colors.green}✓${colors.reset} Process terminated.`);
          // Wait a moment for the port to be released
          await new Promise(resolve => setTimeout(resolve, 1000));
          if (await isPortAvailable(webPort)) {
            console.log(`${colors.green}✓${colors.reset} Port ${webPort} is now available.`);
          } else {
            throw new Error('Port still in use');
          }
        } catch (e) {
          console.log(`${colors.red}✗${colors.reset} Failed to terminate process.`);
          // Try to find an alternative port
          const alternativePort = await findAvailablePort(webPort + 1);
          if (alternativePort) {
            console.log(`${colors.yellow}!${colors.reset} Using alternative port for web server: ${alternativePort}`);
            webPort = alternativePort;
          } else {
            console.error(`${colors.red}✗${colors.reset} No available ports found for web server.`);
            process.exit(1);
          }
        }
      } else {
        // Try to find an alternative port
        const alternativePort = await findAvailablePort(webPort + 1);
        if (alternativePort) {
          console.log(`${colors.yellow}!${colors.reset} Using alternative port for web server: ${alternativePort}`);
          webPort = alternativePort;
        } else {
          console.error(`${colors.red}✗${colors.reset} No available ports found for web server.`);
          process.exit(1);
        }
      }
    } else {
      // No process info, just try to find an alternative port
      const alternativePort = await findAvailablePort(webPort + 1);
      if (alternativePort) {
        console.log(`${colors.yellow}!${colors.reset} Using alternative port for web server: ${alternativePort}`);
        webPort = alternativePort;
      } else {
        console.error(`${colors.red}✗${colors.reset} No available ports found for web server.`);
        process.exit(1);
      }
    }
  }
  
  // Create a temporary Dart file to set the proxy port
  const tempDartFile = path.join(__dirname, 'lib', 'proxy_config.dart');
  try {
    fs.writeFileSync(tempDartFile, `
// Generated by the app launcher script
// This file will be deleted after the app starts

import '../lib/services/old_reader_api.dart';

void configureProxy() {
  // Set the proxy port to the one that's actually in use
  OldReaderApi.setProxyPort(${proxyPort});
  print('Proxy configured to use port ${proxyPort}');
}
`);
    
    console.log(`${colors.green}✓${colors.reset} Created temporary proxy configuration file.`);
  } catch (e) {
    console.error(`${colors.red}✗${colors.reset} Failed to create temporary configuration file: ${e.message}`);
    // Continue anyway, we'll just use the default port
  }
  
  // Patch main.dart to include the proxy_config.dart file
  const mainDartFile = path.join(__dirname, 'lib', 'main.dart');
  let mainDartContent;
  
  try {
    mainDartContent = fs.readFileSync(mainDartFile, 'utf8');
    
    // Check if the file already contains the import
    if (!mainDartContent.includes('proxy_config.dart')) {
      // Find the import section
      const importSection = mainDartContent.match(/import [^\n]+;\n+/g);
      if (importSection && importSection.length > 0) {
        // Add our import after the last import
        const lastImport = importSection[importSection.length - 1];
        const lastImportIndex = mainDartContent.lastIndexOf(lastImport) + lastImport.length;
        
        const newContent = 
          mainDartContent.substring(0, lastImportIndex) + 
          "import 'proxy_config.dart';\n" + 
          mainDartContent.substring(lastImportIndex);
        
        fs.writeFileSync(mainDartFile, newContent);
        
        // Also add the call to configureProxy() at the start of main()
        const mainFunctionMatch = newContent.match(/void main\(\)\s*{/);
        if (mainFunctionMatch && mainFunctionMatch.index) {
          const mainFunctionStart = mainFunctionMatch.index + mainFunctionMatch[0].length;
          const updatedContent = 
            newContent.substring(0, mainFunctionStart) + 
            "\n  configureProxy();\n" + 
            newContent.substring(mainFunctionStart);
          
          fs.writeFileSync(mainDartFile, updatedContent);
        }
        
        console.log(`${colors.green}✓${colors.reset} Updated main.dart to use the proxy configuration.`);
      }
    }
  } catch (e) {
    console.error(`${colors.yellow}!${colors.reset} Failed to patch main.dart: ${e.message}`);
    console.log(`${colors.yellow}!${colors.reset} You may need to manually set the proxy port in old_reader_api.dart.`);
    // Continue anyway
  }
  
  // Import Flutter path configuration
  let flutterConfig;
  try {
    flutterConfig = require('./flutter-config');
    console.log(`Flutter configuration loaded. Using path: ${flutterConfig.flutterPath}`);
  } catch (e) {
    // Config file not found, will use default paths
    console.log('No Flutter configuration found. Will search for Flutter in PATH.');
  }
  
  // Start the Flutter web app
  console.log(`${colors.green}✓${colors.reset} Starting Flutter web app on port ${webPort}...`);
  
  console.log(`\n${colors.bright}${colors.bgBlue}${colors.white} The Old Reader App ${colors.reset}`);
  console.log(`${colors.cyan}Proxy server: ${colors.reset}http://localhost:${proxyPort}`);
  console.log(`${colors.cyan}Web app: ${colors.reset}http://${WEB_HOSTNAME}:${webPort}`);  console.log(`\n${colors.yellow}When the app starts, open your browser and navigate to:${colors.reset}`);
  console.log(`${colors.bright}${colors.green}http://${WEB_HOSTNAME}:${webPort}${colors.reset}`);
  console.log(`\n${colors.dim}Press Ctrl+C to stop the app.${colors.reset}\n`);
    // Check if we have a configured Flutter path first
  if (flutterConfig && flutterConfig.flutterPath) {
    console.log(`${colors.green}ℹ${colors.reset} Using configured Flutter path: ${flutterConfig.flutterPath}`);
      // On Windows, use spawn with shell option for .bat files
    const isWindows = process.platform === 'win32';
    const options = isWindows ? { stdio: 'inherit', shell: true } : { stdio: 'inherit' };
    
    const flutterProcess = spawn(flutterConfig.flutterPath, [
      'run',
      '-d', 'web-server',
      '--web-port', webPort.toString(),
      '--web-hostname', WEB_HOSTNAME
    ], options);
    
    return { flutterProcess, webPort };
  }
  
  // Otherwise, get the path to Flutter
  const flutterPath = await getCommandPath('flutter');
    // If we have a direct path, use it
  if (flutterPath) {
    // Ensure the path is clean without any control characters
    const cleanPath = flutterPath.replace(/[\r\n]+$/, '');
    console.log(`${colors.green}ℹ${colors.reset} Using Flutter at: ${cleanPath}`);
      const flutterProcess = spawn(flutterConfig && flutterConfig.flutterPath ? flutterConfig.flutterPath : cleanPath, [
      'run',
      '-d', 'web-server',
      '--web-port', webPort.toString(),
      '--web-hostname', WEB_HOSTNAME
    ], { stdio: 'inherit', shell: process.platform === 'win32' });
    
    return { flutterProcess, webPort };
  } else {    // Try common Flutter paths
    const possiblePaths = [
      // Windows with .bat extension
      path.join(process.env.LOCALAPPDATA || '', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.APPDATA || '', 'flutter', 'bin', 'flutter.bat'),
      'C:\\flutter\\bin\\flutter.bat',
      'C:\\src\\flutter\\bin\\flutter.bat',
      path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.USERPROFILE || '', 'Documents', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.USERPROFILE || '', 'development', 'flutter', 'bin', 'flutter.bat'),
      path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter.bat'),
      // Windows without .bat extension
      path.join(process.env.LOCALAPPDATA || '', 'flutter', 'bin', 'flutter'),
      path.join(process.env.APPDATA || '', 'flutter', 'bin', 'flutter'),
      'C:\\flutter\\bin\\flutter',
      'C:\\src\\flutter\\bin\\flutter',
      path.join(process.env.USERPROFILE || '', 'flutter', 'bin', 'flutter'),
      path.join(process.env.USERPROFILE || '', 'Documents', 'flutter', 'bin', 'flutter'),
      path.join(process.env.USERPROFILE || '', 'development', 'flutter', 'bin', 'flutter'),
      path.join(process.env.USERPROFILE || '', 'sdk', 'flutter', 'bin', 'flutter'),
      // Linux/macOS
      '/usr/local/flutter/bin/flutter',
      '/opt/flutter/bin/flutter',
      path.join(process.env.HOME || '', 'flutter', 'bin', 'flutter'),
      path.join(process.env.HOME || '', 'development', 'flutter', 'bin', 'flutter')
    ];
    
    let foundPath = null;
    for (const p of possiblePaths) {
      if (fs.existsSync(p)) {
        foundPath = p;
        console.log(`${colors.green}✓${colors.reset} Found Flutter at: ${foundPath}`);
        break;
      }
    }      if (foundPath) {
      // Ensure the path is clean without any control characters
      const cleanPath = foundPath.replace(/[\r\n]+$/, '');
      console.log(`${colors.green}ℹ${colors.reset} Using Flutter at: ${cleanPath}`);
      
      // On Windows, use spawn with shell option for .bat files
      const isWindows = process.platform === 'win32';
      const options = isWindows ? { stdio: 'inherit', shell: true } : { stdio: 'inherit' };
      
      const flutterProcess = spawn(flutterConfig && flutterConfig.flutterPath ? flutterConfig.flutterPath : cleanPath, [
        'run',
        '-d', 'web-server',
        '--web-port', webPort.toString(),
        '--web-hostname', WEB_HOSTNAME
      ], options);
      
      return { flutterProcess, webPort };
    } else {
      console.error(`${colors.red}✗${colors.reset} Flutter not found. Please ensure Flutter is installed correctly.`);
      console.log(`${colors.yellow}!${colors.reset} You can install Flutter from: https://flutter.dev/docs/get-started/install`);
      console.log(`${colors.yellow}!${colors.reset} After installation, make sure to add Flutter to your PATH.`);
      process.exit(1);
    }
  }
}

// Clean up temporary files
function cleanup() {
  // Remove the temporary proxy_config.dart file
  const tempDartFile = path.join(__dirname, 'lib', 'proxy_config.dart');
  if (fs.existsSync(tempDartFile)) {
    try {
      fs.unlinkSync(tempDartFile);
      console.log(`${colors.dim}Removed temporary configuration file.${colors.reset}`);
    } catch (e) {
      console.error(`${colors.yellow}!${colors.reset} Failed to remove temporary file: ${e.message}`);
    }
  }
  
  // Restore main.dart if we modified it
  const mainDartFile = path.join(__dirname, 'lib', 'main.dart');
  try {
    const content = fs.readFileSync(mainDartFile, 'utf8');
    if (content.includes("import 'proxy_config.dart';")) {
      const newContent = content
        .replace("import 'proxy_config.dart';\n", '')
        .replace("\n  configureProxy();\n", '');
      fs.writeFileSync(mainDartFile, newContent);
      console.log(`${colors.dim}Restored main.dart.${colors.reset}`);
    }
  } catch (e) {
    console.error(`${colors.yellow}!${colors.reset} Failed to restore main.dart: ${e.message}`);
  }
}

// Main function
async function main() {
  console.log(`\n${colors.bright}${colors.bgBlue}${colors.white} THE OLD READER APP LAUNCHER ${colors.reset}`);
  console.log(`${colors.dim}This script will start the proxy server and the Flutter web app.${colors.reset}\n`);
  
  let proxyProcess, flutterProcess;
  
  try {
    // Start the proxy server
    const proxyInfo = await startProxyServer();
    proxyProcess = proxyInfo.proxyProcess;
    
    // Start the Flutter web app
    const webInfo = await startFlutterWeb(proxyInfo.proxyPort);
    flutterProcess = webInfo.flutterProcess;
    
    // Handle process termination
    process.on('SIGINT', () => {
      console.log(`\n${colors.yellow}Shutting down...${colors.reset}`);
      
      if (proxyProcess) {
        proxyProcess.kill();
      }
      
      if (flutterProcess) {
        flutterProcess.kill();
      }
      
      cleanup();
      process.exit(0);
    });
    
    // Handle child process termination
    flutterProcess.on('close', (code) => {
      console.log(`\n${colors.yellow}Flutter process exited with code ${code}.${colors.reset}`);
      
      if (proxyProcess) {
        proxyProcess.kill();
      }
      
      cleanup();
      process.exit(0);
    });
    
    proxyProcess.on('close', (code) => {
      console.log(`\n${colors.yellow}Proxy process exited with code ${code}.${colors.reset}`);
      
      if (flutterProcess) {
        flutterProcess.kill();
      }
      
      cleanup();
      process.exit(0);
    });
  } catch (e) {
    console.error(`${colors.red}Error:${colors.reset} ${e.message}`);
    
    if (proxyProcess) {
      proxyProcess.kill();
    }
    
    if (flutterProcess) {
      flutterProcess.kill();
    }
    
    cleanup();
    process.exit(1);
  }
}

// Run the main function
main();
