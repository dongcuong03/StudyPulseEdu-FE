import 'package:flutter/material.dart';

class HoverablePopupMenuItem extends PopupMenuItem<String> {
  HoverablePopupMenuItem({
    super.key,
    required String value,
    required String label,
  }) : super(
          value: value,
          padding: EdgeInsets.zero,
          child: _HoverableChild(label),
        );
}

class _HoverableChild extends StatefulWidget {
  final String label;

  const _HoverableChild(this.label);

  @override
  State<_HoverableChild> createState() => _HoverableChildState();
}

class _HoverableChildState extends State<_HoverableChild> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: Container(
        color: isHovering ? Colors.blue : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.label,
          style: TextStyle(
            color: isHovering ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
