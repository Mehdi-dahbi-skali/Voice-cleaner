# Flutter Web Port Information

## Default Behavior

When you run `flutter run -d chrome`, Flutter web uses a **random available port**. The port is shown in the terminal output when the app starts.

Example output:
```
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
...
The Flutter DevTools debugger and profiler on Chrome is available at:
http://127.0.0.1:49203/...
```

In this case, the app is running on port `49203` (or similar random port).

## How to Find the Port

1. **Check terminal output** - When you run `flutter run -d chrome`, look for the URL in the output
2. **Check browser address bar** - The URL in Chrome will show the port (e.g., `http://localhost:49203`)
3. **Check DevTools** - Open Chrome DevTools (F12) and look at the Network tab - requests will show the origin

## Set a Fixed Port

If you want to use a specific port, use the `--web-port` flag:

```bash
flutter run -d chrome --web-port=3000
```

This will run the app on `http://localhost:3000`

## For CORS Configuration

**Good news:** Your CORS configuration uses `allowedOriginPatterns: "*"` which allows **all origins**, so the Flutter web port doesn't matter!

Your Gateway CORS config:
```properties
spring.cloud.gateway.globalcors.cors-configurations.[/**].allowed-origin-patterns=*
```

This means it will accept requests from:
- `http://localhost:49203` (random port)
- `http://localhost:3000` (if you set a fixed port)
- `http://127.0.0.1:any-port`
- Any other origin

## Summary

- **Default:** Random port (shown in terminal)
- **Fixed port:** Use `--web-port=PORT` flag
- **CORS:** Your config allows all origins, so port doesn't matter ✅

