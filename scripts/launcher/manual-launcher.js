/**
 * The Old Reader - Manual Launcher
 * 
 * This script manually starts both the proxy and Flutter web app.
 */

const { spawn, execSync } = require('child_process');

console.log('==========================================================');
console.log('          THE OLD READER - MANUAL LAUNCHER');
console.log('==========================================================');
console.log('');

// 1. Start the proxy
console.log('Starting proxy server...');
const proxy = spawn('node', ['proxy/proxy.js'], { 
  stdio: 'inherit',
  shell: true 
});

// Wait for proxy to start
console.log('Waiting for proxy server to start...');
setTimeout(() => {
  // 2. Start Flutter
  console.log('\nStarting Flutter web app...');
  try {
    // Get the Flutter path from config if available
    let flutterPath;
    try {
      const config = require('./flutter-config');
      flutterPath = config.flutterPath;
      console.log(`Using configured Flutter path: ${flutterPath}`);
    } catch (e) {
      console.log('No Flutter configuration found. Trying to use Flutter from PATH...');
      flutterPath = 'flutter';
    }

    // Execute Flutter web directly with execSync to ensure proper shell handling on Windows
    execSync(`"${flutterPath}" run -d web-server --web-port 8000 --web-hostname 127.0.0.1`, {
      shell: true,
      stdio: 'inherit'
    });
  } catch (e) {
    console.error(`\nError running Flutter web: ${e.message}`);
    // Kill the proxy when Flutter fails
    proxy.kill();
    process.exit(1);
  }
}, 3000); // Wait 3 seconds for the proxy to start

// Handle clean shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down...');
  proxy.kill();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\nShutting down...');
  proxy.kill();
  process.exit(0);
});
