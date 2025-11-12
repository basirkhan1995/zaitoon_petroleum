import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZUnderlineTextfield extends StatelessWidget {
  final String title;
  final String? hintText;
  final double? titleSpace;
  final Widget? leading;
  final TextAlign textAlign;
  final Color? enabledColor;
  final bool isRequired;
  final Widget? trailing;
  final bool isEnabled;
  final List<TextInputFormatter>? inputFormatter;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  final double? width;
  const ZUnderlineTextfield({
    super.key,
    this.enabledColor,
    this.titleSpace,
    this.onChanged,
    this.leading,
    this.trailing,
    this.textAlign = TextAlign.start,
    this.inputFormatter,
    this.controller,
    this.focusNode,
    this.isEnabled = true,
    this.validator,
    this.width,
    required this.title,
    this.readOnly = false,
    this.hintText,
    this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              isRequired
                  ? Text(
                " *",
                style: TextStyle(color: Colors.red.shade900),
              )
                  : const SizedBox(),
            ],
          ),
          SizedBox(
            height: titleSpace,
          ),
          TextFormField(
            focusNode: focusNode,
            enabled: isEnabled,
            controller: controller,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator,
            textAlign: textAlign,
            inputFormatters: inputFormatter,
            readOnly:
            readOnly, // Make the field read-only to prevent manual input.
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              hintText: hintText,
              suffix: trailing,
              prefix: leading,
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary.withValues(alpha: .3)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary.withValues(alpha: .3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
