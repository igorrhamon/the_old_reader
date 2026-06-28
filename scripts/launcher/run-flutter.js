/**
 * Flutter Helper Script
 * 
 * This script helps execute Flutter commands with the correct settings for Windows.
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

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

// Validate Flutter installation
try {
  const flutterVersion = execSync(`"${flutterPath}" --version`, { shell: true }).toString();
  console.log('Flutter version:');
  console.log(flutterVersion);
} catch (e) {
  console.error(`Error executing Flutter: ${e.message}`);
  console.log('Please make sure Flutter is installed correctly.');
  process.exit(1);
}

// Execute Flutter web
console.log('Starting Flutter web app...');
try {
  execSync(`"${flutterPath}" run -d web-server --web-port 8000 --web-hostname 127.0.0.1`, {
    shell: true,
    stdio: 'inherit'
  });
} catch (e) {
  console.error(`Error running Flutter web: ${e.message}`);
  process.exit(1);
}
