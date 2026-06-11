import 'platform_url_launcher_app.dart'
    if (dart.library.js_interop) 'platform_url_launcher_web.dart';

Future<void> openPlatformUrl(String url) {
  return openPlatformUrlImpl(url);
}
