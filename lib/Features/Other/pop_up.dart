import 'package:flutter/material.dart';
import '../../Localizations/l10n/translations/app_localizations.dart';

class EditDeletePopup extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EditDeletePopup({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Tooltip(
        message: AppLocalizations.of(context)!.more,
        child: const Icon(Icons.more_vert),
      ),
     // color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 2,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            title: Text(AppLocalizations.of(context)!.edit),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(AppLocalizations.of(context)!.delete),
          ),
        ),
      ],
    );
  }
}