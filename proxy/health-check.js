/**
 * Health Check for The Old Reader Proxy
 * 
 * This script checks if the proxy is running correctly and can communicate
 * with The Old Reader API.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

// Log directory setup
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

// Function to log messages
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  console.log(message);
  fs.appendFileSync(path.join(logDir, 'health-check.log'), logMessage);
}

// Check if proxy is running
function checkProxyStatus(port = 3000) {
  return new Promise((resolve) => {
    const req = http.get(`http://localhost:${port}`, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          data: data
        });
      });
    });
    
    req.on('error', (err) => {
      resolve({
        status: -1,
        error: err.message
      });
    });
    
    req.end();
  });
}

// Check if proxy can access The Old Reader API
function checkApiAccess(port = 3000) {
  return new Promise((resolve) => {
    const req = http.get(`http://localhost:${port}/proxy/status`, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          data: data
        });
      });
    });
    
    req.on('error', (err) => {
      resolve({
        status: -1,
        error: err.message
      });
    });
    
    req.end();
  });
}

// Run the health check
async function runHealthCheck() {
  log('Starting health check for The Old Reader Proxy...');
  
  // Try different ports
  const ports = [3000, 3001, 3002, 3003];
  let proxyRunning = false;
  let proxyPort = null;
  
  for (const port of ports) {
    log(`Checking if proxy is running on port ${port}...`);
    const result = await checkProxyStatus(port);
    
    if (result.status === 200) {
      log(`Proxy is running on port ${port}`);
      proxyRunning = true;
      proxyPort = port;
      break;
    } else if (result.status === -1) {
      log(`No proxy found on port ${port}: ${result.error}`);
    } else {
      log(`Unexpected response from proxy on port ${port}: ${result.status}`);
    }
  }
  
  if (!proxyRunning) {
    log('ERROR: Proxy is not running on any of the expected ports.');
    log('Please start the proxy using one of the start-proxy scripts.');
    return false;
  }
  
  // Check API access
  log(`Checking if proxy can access The Old Reader API...`);
  const apiResult = await checkApiAccess(proxyPort);
  
  if (apiResult.status === 200) {
    log('Proxy can access The Old Reader API successfully.');
    log('HEALTH CHECK PASSED: The proxy is running correctly.');
    return true;
  } else {
    log(`ERROR: Proxy cannot access The Old Reader API. Status: ${apiResult.status}`);
    if (apiResult.error) {
      log(`Error: ${apiResult.error}`);
    } else if (apiResult.data) {
      log(`Response: ${apiResult.data}`);
    }
    log('HEALTH CHECK FAILED: The proxy is running but cannot access the API.');
    return false;
  }
}

// Run the health check
runHealthCheck().then((success) => {
  log(`Health check completed. Result: ${success ? 'PASSED' : 'FAILED'}`);
});
