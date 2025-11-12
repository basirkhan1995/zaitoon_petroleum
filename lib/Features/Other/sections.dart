import 'package:flutter/material.dart';

class SectionFormLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> formFields;
  final double leftPanelWidth;
  final double spacing;
  final Widget? trailing; // Optional right-side panel (like actions, help text, etc.)

  const SectionFormLayout({
    super.key,
    required this.title,
    required this.formFields,
    this.subtitle,
    this.leftPanelWidth = 250,
    this.spacing = 4,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Left: Title & Subtitle
              SizedBox(
                width: leftPanelWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              // 🔹 Middle: Form fields
              Flexible(
                flex: 2,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - leftPanelWidth - 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formFields
                        .map((e) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: e,
                    ))
                        .toList(),
                  ),
                ),
              ),

              // 🔹 Optional Right Panel
              if (trailing != null)
                Flexible(
                  flex: 1,
                  child: trailing!,
                ),
            ],
          ),
        );
      },
    );
  }
}
