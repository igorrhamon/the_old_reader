# Scripts Directory

This directory contains helper scripts for development, building, and testing The Old Reader Flutter app.

## Quick Start

**Start the web app with proxy:**
```bash
# Windows (PowerShell)
pwsh .\launcher\start-web-app.ps1

# Windows (Batch)
.\launcher\start-web-app.bat

# macOS/Linux
./launcher/start-web-app.sh
```

## Directory Structure

### `launcher/` - App Launch Scripts

Start the application on different platforms.

| Script | Platform | Purpose |
|--------|----------|---------|
| `start-web-app.*` | All | **Recommended**: Starts Flutter web server + proxy in one command |
| `direct-launcher.*` | All | Alternative launcher for web + proxy |
| `auto-launcher.*` | All | Automatic launcher with auto-detection |
| `run-flutter.*` | All | Simple Flutter run command |
| `run-web-app.*` | Windows | Legacy web app runner |
| `manual-launcher.*` | Windows | Manual control launcher |

**Usage:**
```bash
pwsh ./launcher/start-web-app.ps1     # PowerShell
./launcher/start-web-app.sh            # Bash
./launcher/start-web-app.bat           # Windows Batch
```

### `proxy/` - Proxy Server Scripts

Node.js Express proxy for web CORS bypass (port 3000).

| Script | Purpose |
|--------|---------|
| `proxy.js` | Main proxy server |
| `proxy-debug.js` | Proxy with verbose logging |
| `proxy-test.js` | Simplified test version |
| `start-proxy.*` | Start proxy with checks |
| `test-quickadd.js` | Test the subscription/quickadd endpoint |
| `quickadd-diagnostics.js` | Diagnose quickadd issues |
| `check-proxy-health.*` | Verify proxy is running |
| `manage-logs.*` | View/clear/archive proxy logs |
| `check-proxy.ps1` | PowerShell proxy status check |

**Usage:**
```bash
node ./proxy/proxy.js                  # Start proxy
pwsh ./proxy/start-proxy.ps1           # PowerShell start script
./proxy/manage-logs.sh                 # Manage logs
node ./proxy/test-quickadd.js          # Test feed addition
```

**Environment Variables:**
```bash
# Optional - configure proxy port
PROXY_PORT=3000

# Optional - Old Reader API base URL
OLD_READER_URL=https://theoldreader.com/reader/api/0
```

### `check/` - Verification Scripts

Check Flutter installation, ports, and prerequisites.

| Script | Purpose |
|--------|---------|
| `check-flutter.*` | Verify Flutter is installed and configured |
| `check-port.js` | Check if a port is available |

**Usage:**
```bash
node ./check/check-port.js 3000        # Check if port 3000 is free
./check/check-flutter.bat              # Verify Flutter setup
```

### `config/` - Configuration Scripts

Setup and configuration helpers.

| Script | Purpose |
|--------|---------|
| `fix-flutter-path.*` | Fix Flutter PATH issues (Windows) |
| `flutter-config.js` | Configure Flutter settings |
| `flutter-path-fixer.js` | Automatic Flutter path detection |
| `organize-proxy-files.*` | Organize proxy directory structure |

**Usage:**
```bash
./config/fix-flutter-path.bat          # Fix Windows PATH
node ./config/flutter-path-fixer.js    # Auto-detect Flutter
```

## Development Workflow

### 1. First Time Setup
```bash
# Check Flutter installation
./check/check-flutter.bat

# Fix any path issues
./config/fix-flutter-path.bat

# Check port availability
node ./check/check-port.js 3000
node ./check/check-port.js 8000
```

### 2. Development
```bash
# Start web app with proxy (recommended)
pwsh ./launcher/start-web-app.ps1

# Or manually in separate terminals
node ./proxy/proxy.js                  # Terminal 1
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1  # Terminal 2
```

### 3. Testing
```bash
# Widget tests
flutter test

# E2E tests (requires credentials)
export the_old_reader_email="your@email.com"
export the_old_reader_password="your_password"
npx playwright test

# Test proxy feeds
node ./proxy/test-quickadd.js
```

### 4. Debugging
```bash
# Proxy debug mode
node ./proxy/proxy-debug.js

# Check proxy health
./proxy/check-proxy-health.sh

# View logs
./proxy/manage-logs.sh view
```

## Cross-Platform Compatibility

- **Windows**: Use `.bat`, `.ps1`, or `.js` versions
- **macOS/Linux**: Use `.sh` or `.js` versions
- **All platforms**: JavaScript versions work with Node.js

## Notes

- Proxy is only needed for **web builds** (native platforms call API directly)
- Default ports: Flutter web (8000), Proxy (3000)
- Log files are stored in `../logs/` directory
- All paths are relative to project root (except when called from other directories)

## Troubleshooting

**Port already in use:**
```bash
node ./check/check-port.js 3000
# Then kill the process or change PROXY_PORT
```

**Flutter not found:**
```bash
./config/fix-flutter-path.bat
```

**Proxy connection issues:**
```bash
./proxy/check-proxy-health.sh
node ./proxy/proxy-debug.js
```

**Feed addition fails:**
```bash
node ./proxy/quickadd-diagnostics.js
```
