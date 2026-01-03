import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZSearchField extends StatelessWidget {
  final String title;
  final String? hint;
  final bool isRequire;
  final bool isEnabled;
  final bool readOnly;
  final IconData? icon;
  final String errorMessage;
  final Color? infoColor;
  final Widget? end;
  final bool securePassword;
  final TextInputAction? inputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final FormFieldValidator? validator;
  final TextInputType? keyboardInputType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? trailing;
  final double width;
  final bool? compactMode;
  final bool autoFocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormat;

  const ZSearchField({
    super.key,
    required this.title,
    this.hint,
    this.readOnly = false,
    this.errorMessage = "",
    this.maxLength,
    this.infoColor,
    this.autoFocus = true,
    this.compactMode,
    this.isEnabled = true,
    this.securePassword = false,
    this.end,
    this.focusNode,
    this.isRequire = false,
    this.icon,
    this.inputFormat,
    this.validator,
    this.onSubmit,
    this.controller,
    this.onChanged,
    this.width = .5,
    this.trailing,
    this.keyboardInputType,
    this.inputAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          TextFormField(
            readOnly: readOnly,
            focusNode: focusNode,
            autofocus: autoFocus,
            enabled: isEnabled,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onSubmit,
            obscureText: securePassword,
            inputFormatters: inputFormat,
            keyboardType: keyboardInputType,
            controller: controller,
            maxLength: maxLength,
            maxLines: keyboardInputType == TextInputType.multiline ? null : 1,
            minLines: keyboardInputType == TextInputType.multiline ? 3 : 1,
            decoration: InputDecoration(
              filled: !isEnabled,
              suffixIcon: trailing,
              suffix: end,
              suffixIconConstraints: BoxConstraints(maxWidth: 35,maxHeight: 35),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: Colors.grey.withAlpha(100),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: .3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              hintText: hint,
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              isDense: compactMode ?? true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 8.0,
              ), // Adjust this value to control the height
            ),
          ),
          errorMessage.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 0,
            ),
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: infoColor,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color:
                    infoColor ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          )
              : SizedBox(),
        ],
      ),
    );
  }
}
