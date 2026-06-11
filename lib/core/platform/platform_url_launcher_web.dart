import 'package:web/web.dart' as web;

Future<void> openPlatformUrlImpl(String url) async {
  web.window.open(url, '_self');
}
