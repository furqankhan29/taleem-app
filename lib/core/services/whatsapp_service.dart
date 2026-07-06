import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:taleem/core/utils/logger.dart';

abstract class BaseWhatsAppService extends GetxService {
  Future<bool> sendMessage({required String phone, required String message});
}

class WhatsAppService extends BaseWhatsAppService {
  @override
  Future<bool> sendMessage({required String phone, required String message}) async {
    // Clean phone number (remove spaces, symbols, leading zeros)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-()+\u200B-\u200D\uFEFF]'), '');
    
    // Fallback URL Schema to open WhatsApp
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (success) {
          Logger.success('WhatsApp launcher successfully triggered.');
          return true;
        }
      }
      
      Logger.error('Can launch URL returned false for: $uri');
      return false;
    } catch (e) {
      Logger.error('Failed to trigger WhatsApp launch', e);
      return false;
    }
  }
}
