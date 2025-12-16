import 'package:flutter/material.dart';
import 'package:zaitoon_petroleum/Features/Widgets/outline_button.dart';
import 'package:zaitoon_petroleum/Localizations/l10n/translations/app_localizations.dart';

class StepItem {
  final String title;
  final Widget content;
  final IconData? icon;

  const StepItem({
    required this.title,
    required this.content,
    this.icon,
  });
}

class CustomStepper extends StatefulWidget {
  final List<StepItem> steps;
  final Axis direction;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback? onFinish;

  const CustomStepper({
    super.key,
    required this.steps,
    this.direction = Axis.horizontal,
    this.activeColor,
    this.inactiveColor,
    this.onFinish,
  });

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentStep = 0;

  void _goNext() {
    if (currentStep < widget.steps.length - 1) {
      setState(() => currentStep++);
    } else {
      widget.onFinish?.call();
    }
  }

  void _goPrevious() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final isHorizontal = widget.direction == Axis.horizontal;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step headers
          isHorizontal
              ? Row(
            textDirection: Directionality.of(context),
            children: _buildSteps(context),
          )
              : Column(children: _buildSteps(context)),
          const SizedBox(height: 8),
          // Current step content
          widget.steps[currentStep].content,
          const SizedBox(height: 8),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZOutlineButton(
                  width: 120,
                  height: 35,
                  onPressed: currentStep > 0 ? _goPrevious : null,
                  label: Text(tr.previous),
                ),
                ZOutlineButton(
                  width: 120,
                  height: 35,
                  onPressed: _goNext,
                  label: Text(
                      currentStep < widget.steps.length - 1 ? tr.next : tr.finish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSteps(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];

    for (int i = 0; i < widget.steps.length; i++) {
      final isActive = i <= currentStep;
      final isCompleted = i < currentStep;

      items.add(
        InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => setState(() => currentStep = i),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isActive
                      ? widget.activeColor ?? theme.colorScheme.primary
                      : widget.inactiveColor ??
                      theme.colorScheme.outline.withValues(alpha: .3),
                  child: widget.steps[i].icon != null
                      ? Icon(
                    widget.steps[i].icon,
                    size: 16,
                    color: theme.colorScheme.surface,
                  )
                      : Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.steps[i].title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? widget.activeColor ?? theme.colorScheme.primary
                        : widget.inactiveColor ??
                        theme.colorScheme.outline.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Separator line
      if (i != widget.steps.length - 1) {
        items.add(
          Expanded(
            child: Container(
              height: widget.direction == Axis.horizontal ? 2 : 30,
              width: widget.direction == Axis.horizontal ? double.infinity : 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? widget.activeColor ?? theme.colorScheme.primary
                    : widget.inactiveColor ??
                    theme.colorScheme.outline.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }
    }
    return items;
  }
}
