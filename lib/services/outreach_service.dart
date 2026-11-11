import 'package:url_launcher/url_launcher.dart';

class OutreachService {
  /// Clean phone numbers and ensure proper country prefix (default India +91 if 10 digits)
  static String cleanPhoneNumber(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      return cleaned.substring(1);
    }
    if (cleaned.length == 10) {
      return '91$cleaned';
    }
    return cleaned;
  }

  /// Launch direct phone dialer
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleaned,
    );
    if (await canLaunchUrl(launchUri)) {
      return await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open WhatsApp with optional pre-filled pitch message
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    final cleanPhone = cleanPhoneNumber(phoneNumber);
    String url = 'https://wa.me/$cleanPhone';
    if (message != null && message.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(message);
      url = '$url?text=$encoded';
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open Email Client
  static Future<bool> sendEmail(
    String email, {
    String subject = 'Inquiry from Falconate (falconate.com) - Digital Presence & Web Apps',
    String? body,
  }) async {
    final params = <String, String>{
      'subject': subject,
    };
    if (body != null && body.isNotEmpty) {
      params['body'] = body;
    }
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      queryParameters: params,
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open Instagram Profile
  static Future<bool> openInstagram(String username) async {
    final clean = username.replaceAll('@', '').trim();
    if (clean.isEmpty || clean.toLowerCase() == 'not visible') return false;
    final Uri uri = Uri.parse('https://instagram.com/$clean');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open Web Link
  static Future<bool> openUrl(String url) async {
    var formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final Uri uri = Uri.parse(formatted);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Search location in Google Maps
  static Future<bool> openMaps(String location) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
