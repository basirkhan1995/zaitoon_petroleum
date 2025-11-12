import 'package:flutter/material.dart';

class DirectoryLink extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const DirectoryLink({
    super.key,
    required this.path,
    required this.onTap,
  });

  @override
  State<DirectoryLink> createState() => _DirectoryLinkState();
}

class _DirectoryLinkState extends State<DirectoryLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent, // 👈 prevent InkWell hover background
        child: Text(
          widget.path,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: _hovering ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
