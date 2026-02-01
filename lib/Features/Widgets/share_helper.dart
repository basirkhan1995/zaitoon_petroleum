import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';

class WhatsAppShareHelper {
  final BuildContext context;

  WhatsAppShareHelper(this.context);

  String _getAccountPosition(double? balance) {
    if (balance == null || balance == 0) return AppLocalizations.of(context)!.noBalance;
    return balance > 0
        ? AppLocalizations.of(context)!.creditor
        : AppLocalizations.of(context)!.debtor;
  }

  String _formatAmount(double? amount) {
    if (amount == null) return "0";
    return amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  /// Generate account message with greeting and signatory
  String getMessage({
    required String accountNumber,
    required String accountName,
    double? currentBalance,
    double? availableBalance,
    String? currencySymbol,
    String? signatory,
  }) {
    final pos = _getAccountPosition(availableBalance);
    final formattedAvailable = _formatAmount(availableBalance);
    final formattedCurrent = _formatAmount(currentBalance);
    final symbol = currencySymbol ?? '';

    return "${AppLocalizations.of(context)!.dearCustomer},\n\n"
        "${AppLocalizations.of(context)!.balanceMessageShare}\n\n"
        "${AppLocalizations.of(context)!.accountName}: $accountName\n"
        "${AppLocalizations.of(context)!.accountNumber}: $accountNumber\n"
        "${AppLocalizations.of(context)!.currentBalance}: $symbol $formattedCurrent\n"
        "${AppLocalizations.of(context)!.availableBalance}: $symbol $formattedAvailable\n"
        "${AppLocalizations.of(context)!.accountPosition}: $pos\n\n"
        "${signatory != null ? '${AppLocalizations.of(context)!.regardsTitle},\n$signatory' : ''}";
  }


  /// Share via WhatsApp
  Future<void> shareViaWhatsApp({
    required String accountNumber,
    required String accountName,
    double? currentBalance,
    double? availableBalance,
    String? currencySymbol,
    String? signatory,
    String? phoneNumber, // optional: WhatsApp number with country code
  }) async {
    final message = getMessage(
      accountNumber: accountNumber,
      accountName: accountName,
      currentBalance: currentBalance,
      availableBalance: availableBalance,
      currencySymbol: currencySymbol,
      signatory: signatory,
    );

    final encodedMessage = Uri.encodeComponent(message);

    if (kIsWeb) {
      final uri = Uri.parse("https://web.whatsapp.com/send?text=$encodedMessage");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError();
      }
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      Uri uri;

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Open chat directly with number
        uri = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");
      } else {
        // Open WhatsApp app → search contact → message prefilled
        uri = Uri.parse("whatsapp://send?text=$encodedMessage");
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (phoneNumber != null) {
        // fallback to web
        final webUri = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          _showError();
        }
      } else {
        // fallback to WhatsApp Web
        final webUri = Uri.parse("https://web.whatsapp.com/send?text=$encodedMessage");
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          _showError();
        }
      }

      return;
    }

    // Desktop → copy to clipboard + open app / fallback web
    await Clipboard.setData(ClipboardData(text: message));

    String? desktopUri;
    if (Platform.isWindows || Platform.isMacOS) desktopUri = "whatsapp://";

    if (desktopUri != null) {
      final uri = Uri.parse(desktopUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // fallback WhatsApp Web
    final webUri = Uri.parse("https://web.whatsapp.com/");
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("WhatsApp is not available on this platform")),
    );
  }
}
