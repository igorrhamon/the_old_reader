// Temporary file for proxy configuration
// This file will be automatically included by start-web-app.js and removed when the app exits

import 'services/old_reader_api.dart';

// This function will be called at app startup to set the correct proxy port
void configureProxy() {
  // The actual port number will be set by start-web-app.js
  // This is just a placeholder
  OldReaderApi.setProxyPort(3000);
  print('Proxy configured to use default port 3000');
}
