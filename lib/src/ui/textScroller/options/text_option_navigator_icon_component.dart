import 'package:flutter/material.dart';

typedef UpdateIndexCallback = void Function(int index);

class TextOptionNavigatorIconComponent extends StatelessWidget {
  final int index;
  final UpdateIndexCallback? updateIndex;
  final Color? color;

  const TextOptionNavigatorIconComponent({
    required this.index,
    this.updateIndex,
    this.color,
    super.key,
  });

  IconData _getIcon() {
    switch (index) {
      case 1:
        return Icons.speed;
      case 2:
        return Icons.text_format;
      default:
        return Icons.opacity;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (index >= 0 && index < 3) {
      final IconData icon = _getIcon();
      return SizedBox(
        width: 50,
        child: Container(
          child: updateIndex != null
              ? IconButton(
                  onPressed: () => updateIndex!(index),
                  icon: Icon(
                    icon,
                  ),
                )
              : Icon(icon, color: color),
        ),
      );
    } else {
      return const SizedBox(width: 50);
    }
  }
}
