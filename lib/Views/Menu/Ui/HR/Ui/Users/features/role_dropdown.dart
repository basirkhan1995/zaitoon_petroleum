import 'package:flutter/material.dart';
import '../../../../../../../Features/Generic/custom_filter_drop.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';

enum UserRole {
  ceo,
  manager,
  deputy,
  admin,
  authorizer,
  cashier,
  officer,
  customerService,
  customer;

  String toDatabaseValue() {
    switch (this) {
      case UserRole.ceo:return 'CEO';
      case UserRole.manager:return 'Manager';
      case UserRole.deputy:return 'Deputy';
      case UserRole.admin:return 'Admin';
      case UserRole.authorizer:return 'Authoriser';
      case UserRole.cashier: return 'Cashier';
      case UserRole.officer: return 'Officer';
      case UserRole.customerService: return 'Customer Service';
      case UserRole.customer: return 'Customer';
    }
  }

  static UserRole fromDatabaseValue(String value) {
    switch (value) {
      case 'CEO': return UserRole.ceo;
      case 'Manager': return UserRole.manager;
      case 'Deputy': return UserRole.deputy;
      case 'Admin': return UserRole.admin;
      case 'Authoriser': return UserRole.authorizer;
      case 'Cashier': return UserRole.cashier;
      case 'Officer': return UserRole.officer;
      case 'Customer Service': return UserRole.customerService;
      case 'Customer': return UserRole.customer;
      default: return UserRole.customer;
    }
  }
}

class RoleTranslator {
  static String getTranslatedRole(BuildContext context, UserRole role) {
    final localizations = AppLocalizations.of(context)!;

    switch (role) {
      case UserRole.ceo: return localizations.ceo;
      case UserRole.manager:return localizations.manager;
      case UserRole.deputy:return localizations.deputy;
      case UserRole.admin:return localizations.admin;
      case UserRole.authorizer:return localizations.authoriser;
      case UserRole.cashier:return localizations.cashier;
      case UserRole.officer:return localizations.officer;
      case UserRole.customerService:return localizations.customerService;
      case UserRole.customer:return localizations.customer;
    }
  }

  static String getTranslatedRoleFromDatabaseValue(BuildContext context, String databaseValue) {
    final role = UserRole.fromDatabaseValue(databaseValue);
    return getTranslatedRole(context, role);
  }

  // Get all roles as translated list for dropdown
  static List<Map<String, dynamic>> getTranslatedRoleList(BuildContext context) {
    return UserRole.values.map((role) {
      return {
        'role': role,
        'translatedName': getTranslatedRole(context, role),
        'databaseValue': role.toDatabaseValue(),
      };
    }).toList();
  }
}

class UserRoleDropdown extends StatefulWidget {
  final UserRole? selectedRole;
  final Function(UserRole) onRoleSelected;

  const UserRoleDropdown({
    super.key,
    this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  State<UserRoleDropdown> createState() => _UserRoleDropdownState();
}

class _UserRoleDropdownState extends State<UserRoleDropdown> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    // If no role is provided, select the first one by default
    _selectedRole = widget.selectedRole ?? UserRole.values.first;

    // Notify parent about the initial selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRoleSelected(_selectedRole);
    });
  }

  @override
  void didUpdateWidget(covariant UserRoleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if the selectedRole from parent changes
    if (widget.selectedRole != null && widget.selectedRole != _selectedRole) {
      setState(() {
        _selectedRole = widget.selectedRole!;
      });
    }
  }

  void _handleRoleSelected(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
    widget.onRoleSelected(role);
  }

  @override
  Widget build(BuildContext context) {
    return ZDropdown<UserRole>(
      title: AppLocalizations.of(context)!.selectRole,
      items: UserRole.values.toList(),
      itemLabel: (role) => RoleTranslator.getTranslatedRole(context, role),
      selectedItem: _selectedRole,
      onItemSelected: _handleRoleSelected,
      leadingBuilder: (role) => _getRoleIcon(role),
    );
  }

  Widget _getRoleIcon(UserRole role) {
    final icon = switch (role) {
      UserRole.ceo => Icons.business_center_outlined,
      UserRole.manager => Icons.manage_accounts_rounded,
      UserRole.deputy => Icons.assistant_rounded,
      UserRole.admin => Icons.admin_panel_settings_rounded,
      UserRole.authorizer => Icons.verified_user_rounded,
      UserRole.cashier => Icons.monetization_on_rounded,
      UserRole.officer => Icons.security_rounded,
      UserRole.customerService => Icons.support_agent_rounded,
      UserRole.customer => Icons.person_rounded,
    };

    return Icon(icon, size: 20);
  }
}