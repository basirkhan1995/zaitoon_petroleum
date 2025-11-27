import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../Localizations/l10n/translations/app_localizations.dart';

class Utils{

  static String getRole({required int role, required BuildContext context}) {
    switch (role) {
      case 0:return AppLocalizations.of(context)!.adminstrator;
      case 1:return AppLocalizations.of(context)!.admin;
      case 2:return AppLocalizations.of(context)!.manager;
      case 3:return AppLocalizations.of(context)!.viewer;
      default: return "";
    }
  }



  static Future<void> launchWhatsApp({required String phoneNumber, String? message}) async {
    final encodedMessage = Uri.encodeComponent(message ?? '');
    final url = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");
    final success = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!success) {
      throw 'Could not launch WhatsApp';
    }
  }

  static Future<Uint8List?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      return result.files.single.bytes; // Return the bytes if available
    } else if (result != null && result.files.single.path != null) {
      return await File(
        result.files.single.path!,
      ).readAsBytes(); // Return the bytes from the file path
    }
    return null;
  }

  static void showOverlayMessage(
      BuildContext context, {required String message, String? title, required bool isError, Duration duration = const Duration(seconds: 3)}) {
    final overlay = Overlay.of(context, rootOverlay: true);

    final color = isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 10,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: -30, end: 0),
            builder: (context, value, child) =>
                Transform.translate(offset: Offset(0, value), child: child),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.surface, size: 35),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        Text(
                          message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  //Goto
  static goto(context, Widget route) {
    return Navigator.of(context).push(_animatedRouting(route));
  }

  //Push and remove previous routes
  static gotoReplacement(context, Widget route) {
    Navigator.of(context).popUntil((route) => false);
    Navigator.push(context, _animatedRouting(route));
  }

  //Part of GOTO Widget
  static Route _animatedRouting(Widget route) {
    return PageRouteBuilder(
      allowSnapshotting: true,
      pageBuilder: (context, animation, secondaryAnimation) => route,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from the right
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static String? validatePassword({required String value, context}) {
    final locale = AppLocalizations.of(context)!;
    if (value.length < 8) {
      return locale.password8Char;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return locale.passwordUpperCase;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return locale.passwordLowerCase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return locale.passwordWithDigit;
    }
    if (!RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?/~`]').hasMatch(value)) {
      return locale.passwordWithSpecialChar;
    }

    return null; // Password is valid
  }

  static String? validateUsername({required String value, context}) {
    final locale = AppLocalizations.of(context)!;

    // Minimum length
    if (value.length < 4) {
      return locale.usernameMinLength; // "Username must be at least 4 characters"
    }

    // Cannot start with a digit
    if (RegExp(r'^[0-9]').hasMatch(value)) {
      return locale.usernameNoStartDigit; // "Username cannot start with a number"
    }

    // Allowed characters: letters, digits, underscore, dot
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return locale.usernameInvalidChars; // "Username can only contain letters, numbers, . or _"
    }

    // No spaces
    if (value.contains(' ')) {
      return locale.usernameNoSpaces; // "Username cannot contain spaces"
    }

    return null; // Username is valid
  }

  static zBackButton(context){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .6),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_rounded, size: 13),
      ),
    );
  }

  static String? validateEmail({required String email, context}) {
    final locale = AppLocalizations.of(context)!;
    if (email.isNotEmpty) {
      // Regular expression for validating an email
      final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
      );
      if (!emailRegex.hasMatch(email)) {
        return locale.emailValidationMessage;
      }
    } else {
      return null;
    }

    return null;
  }

  static String glCategories({required int category, AppLocalizations? locale}) {
    if (category == 1) {
      return locale!.asset;
    } else if (category == 2) {
      return locale!.liability;
    } else if (category == 3) {
      return locale!.income;
    } else if (category == 4) {
      return locale!.expense;
    } else {
      return "not found";
    }
  }

  static String genderType({required String gender, AppLocalizations? locale}) {
    if (gender == "Male") {
      return locale!.male;
    } else if (gender == "Female") {
      return locale!.female;
    } else {
      return "";
    }
  }

  static Color currencyColors(String ccy) {
    final lowerCategory = ccy.toLowerCase();
    if (lowerCategory == 'usd') {
      return Colors.orange.withValues(alpha: .6);
    } else if (lowerCategory == 'afn') {
      return Colors.cyan.withValues(alpha: .6);
    } else if (lowerCategory == 'eur') {
      return Colors.purple.withValues(alpha: .6);
    } else if (lowerCategory == 'gbp') {
      return Colors.greenAccent.withValues(alpha: .6);
    }  else {
      return Colors.lightBlueAccent.withValues(alpha: .6);
    }
  }

  static String getTxnName({required String txn, required BuildContext context}) {
    switch (txn) {
      case "Authorized":return AppLocalizations.of(context)!.authorizedTransactions;
      case "Pending":return AppLocalizations.of(context)!.pendingTransactions;
      case "Reversed":return AppLocalizations.of(context)!.reversed;
      default: return "";
    }
  }

  static String getTxnCode({required String txn, required BuildContext context}) {
    switch (txn) {
      case "CHDP":return AppLocalizations.of(context)!.deposit;
      case "CHWL":return AppLocalizations.of(context)!.withdraw;
      case "XPNS":return AppLocalizations.of(context)!.expense;
      case "INCM":return AppLocalizations.of(context)!.income;
      case "GLCR":return AppLocalizations.of(context)!.glCreditTitle;
      case "GLDR":return AppLocalizations.of(context)!.glDebitTitle;
      case "ATAT":return AppLocalizations.of(context)!.accountTransfer;
      default: return "NOT FOUND";
    }
  }

}