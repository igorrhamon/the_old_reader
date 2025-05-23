# Quickadd Parameter Fix for The Old Reader API Proxy

## Problem

The Old Reader API requires the `quickadd` parameter to be in the URL query string for the `/subscription/quickadd` endpoint. However, our proxy was not correctly handling this special case, resulting in the error:

```
[POST] Proxying to: https://theoldreader.com/reader/api/0/subscription/quickadd
[POST] Response status: 200
[POST] Response body (truncated): <?xml version="1.0" encoding="UTF-8"?>
<errors type="array">
  <error>Required: quickadd</error>
</errors>
```

## Solution

We made the following changes to the proxy.js file:

1. **Special Handling for Quickadd Endpoint**: Implemented a detection system for quickadd requests to handle them differently from other API endpoints.

2. **Parameter Extraction and Placement**:
   - Added logic to check for the quickadd parameter in the URL query string
   - If found in the URL, preserved it when forwarding the request
   - If found in the request body, extracted it and placed it in the URL query string
   - Made sure to properly encode the parameter value

3. **Improved Error Handling and Logging**: Enhanced logging to help diagnose any future issues with the API.

## Key Changes in Code

1. URL construction for quickadd requests:
```javascript
if (isQuickadd) {
  // Procura o parâmetro quickadd na query string
  const quickaddValue = req.query.quickadd || (req.body && req.body.quickadd);
  
  if (quickaddValue) {
    // Constrói a URL com o parâmetro na query string
    url = isAuth 
        ? `${AUTH_BASE}/subscription/quickadd?quickadd=${encodeURIComponent(quickaddValue)}` 
        : `${API_BASE}/subscription/quickadd?quickadd=${encodeURIComponent(quickaddValue)}`;
  }
}
```

2. Handling request body for quickadd:
```javascript
// Para quickadd, não enviamos o parâmetro no body, pois já está na URL
if (isQuickadd) {
  body = undefined;
}
```

## Testing

The fix was verified using:

1. Curl requests directly to the proxy
2. Test scripts to check different parameter placement scenarios
3. Diagnostic tools to analyze request processing

All tests confirmed that the proxy now correctly forwards the quickadd parameter in the URL query string to The Old Reader API.

## Note for Future Maintainers

The Old Reader API has this unique requirement for the `/subscription/quickadd` endpoint where parameters must be in the URL and not in the request body. If you're adding new endpoints or modifying the proxy, be aware of this special case and maintain the current handling logic.

If you encounter similar issues with other endpoints, consider adding them to the special case handling in the proxy.js file.
