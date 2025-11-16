import '../Localizations/l10n/translations/app_localizations.dart';

class LocalizationService {
  late AppLocalizations loc;

  void update(AppLocalizations value) {
    loc = value;
  }
}

final localizationService = LocalizationService();
