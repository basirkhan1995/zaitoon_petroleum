import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/zaitoon_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';


class StatusDropdown extends StatelessWidget {
  final int? value; // null = All
  final ValueChanged<int?> onChanged;
  final double? height;
  final bool disable;

  const StatusDropdown({
    super.key,
    required this.onChanged,
    this.value,
    this.height,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      StatusItem(null, l10n.all),        // ✅ ALL
      StatusItem(1, l10n.active),        // ✅ ACTIVE
      StatusItem(0, l10n.inactive),      // ✅ INACTIVE
    ];

    StatusItem? selectedItem = items.firstWhere(
          (e) => e.value == value,
      orElse: () => items.first, // default ALL
    );

    return ZDropdown<StatusItem>(
      title: l10n.status,
      items: items,
      selectedItem: selectedItem,
      initialValue: l10n.all,
      disableAction: disable,
      itemLabel: (item) => item.label,
      onItemSelected: (item) {
        onChanged(item.value); // ✅ returns null / 1 / 0
      },
    );
  }
}
class StatusItem {
  final int? value;
  final String label;

  const StatusItem(this.value, this.label);
}
