import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Date/shamsi_converter.dart';
import 'package:zaitoon_petroleum/Features/Other/extensions.dart';
import '../../../../../../../Features/Other/image_helper.dart';
import '../../../../../../../Localizations/l10n/translations/app_localizations.dart';
import '../model/emp_model.dart';

class EmployeeCard extends StatefulWidget {
  final EmployeeModel emp;
  final VoidCallback onTap;

  const EmployeeCard({
    super.key,
    required this.emp,
    required this.onTap,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;

    final emp = widget.emp;
    final fullName = "${emp.perName} ${emp.perLastName}";
    final isActive = emp.empStatus == 1;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovering
                ? color.primary.withValues(alpha: .5)
                : color.outline.withValues(alpha: .25),
            width: 1.2,
          ),
          boxShadow: _isHovering
              ? [
            BoxShadow(
              color: color.primary.withValues(alpha: .15),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 180, // Minimum height
              maxHeight: 280, // Maximum height before scrolling
            ),
            child: SingleChildScrollView( // Add scrolling for long content
              physics: const NeverScrollableScrollPhysics(), // Disable if not needed
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Avatar + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageHelper.stakeholderProfile(
                                imageName: emp.empImage,
                                size: 46,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                emp.empPosition ?? "",
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(
                          label: isActive ? locale.active : locale.inactive,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Info rows
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(icon: Icons.apartment, text: emp.empDepartment ?? "-"),
                        const SizedBox(height: 6),
                        _InfoRow(icon: Icons.payments, text: emp.empSalary?.toAmount() ?? "-"),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.date_range,
                          text: emp.empHireDate?.toFormattedDate() ?? "",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).hintColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}