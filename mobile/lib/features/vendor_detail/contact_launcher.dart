import 'package:url_launcher/url_launcher.dart';

typedef CanLaunchUri = Future<bool> Function(Uri uri);
typedef LaunchUri = Future<bool> Function(Uri uri, {LaunchMode mode});

class ContactLauncher {
  ContactLauncher({CanLaunchUri? canLaunch, LaunchUri? launch})
      : _canLaunch = canLaunch ?? canLaunchUrl,
        _launch = launch ?? _launchUrl;

  final CanLaunchUri _canLaunch;
  final LaunchUri _launch;

  static Future<bool> _launchUrl(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) {
    return launchUrl(uri, mode: mode);
  }

  Future<void> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final opened = await _launch(uri, mode: LaunchMode.externalApplication);
    if (!opened) throw StateError('Could not open the phone dialer');
  }

  Future<void> route({required double lat, required double lng}) async {
    final nativeUri = Uri.parse(
      'yandexnavi://build_route_on_map?lat_to=$lat&lon_to=$lng',
    );
    if (await _canLaunch(nativeUri)) {
      final opened = await _launch(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    }

    final webUri = Uri.https('yandex.ru', '/maps/', {
      'rtext': '~$lat,$lng',
      'rtt': 'auto',
    });
    final opened = await _launch(webUri, mode: LaunchMode.externalApplication);
    if (!opened) throw StateError('Could not open Yandex Maps');
  }
}
