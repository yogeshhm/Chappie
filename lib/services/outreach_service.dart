import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class OutreachService {
  /// Open phone dialer directly with the exact phone number (NO predictions, NO added prefixes)
  static Future<bool> makePhoneCall(String phoneNumber) async {
    // Keep exact digits / plus as provided in the sheet
    final clean = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return false;
    final Uri uri = Uri(scheme: 'tel', path: clean);
    try {
      if (kIsWeb) {
        return await launchUrl(uri);
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching dialer for $clean: $e');
      return false;
    }
  }

  /// Open WhatsApp with the provided number
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    String clean = phoneNumber.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return false;
    // WhatsApp API requires country code for international format
    if (clean.length == 10) {
      clean = '91$clean';
    }
    String url = 'https://wa.me/$clean';
    if (message != null && message.trim().isNotEmpty) {
      url += '?text=${Uri.encodeComponent(message)}';
    }
    final Uri uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Open Email Client with exact address
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    final clean = email.trim();
    if (clean.isEmpty) return false;
    final Uri uri = Uri(
      scheme: 'mailto',
      path: clean,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );
    try {
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching email: $e');
      return false;
    }
  }

  /// Open external URL
  static Future<bool> openUrl(String url) async {
    var clean = url.trim();
    if (clean.isEmpty) return false;
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'https://$clean';
    }
    final Uri uri = Uri.parse(clean);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening URL: $e');
      return false;
    }
  }

  /// Open Instagram Profile
  static Future<bool> openInstagram(String username) async {
    final clean = username.replaceAll('@', '').trim();
    if (clean.isEmpty || clean.toLowerCase() == 'not visible') return false;
    return await openUrl('https://instagram.com/$clean');
  }

  /// Open Location in Google Maps
  static Future<bool> openMaps(String location) async {
    final clean = location.trim();
    if (clean.isEmpty) return false;
    return await openUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(clean)}');
  }
}
