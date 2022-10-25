import 'package:flutter/material.dart';

class TextOptionNavigatorIconComponent extends StatelessWidget {
  final int index;
  final Function? updateIndex;
  final Color? color;

  const TextOptionNavigatorIconComponent({
    required this.index,
    this.updateIndex,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.opacity;

    switch (index) {
      case 1:
        icon = Icons.speed;
        break;
      case 2:
        icon = Icons.text_format;
        break;
    }
    if (index >= 0 && index < 3) {
      return SizedBox(
        width: 50,
        child: Container(
            child: updateIndex != null
                ? IconButton(
                    onPressed: () => updateIndex!(index), icon: Icon(icon))
                : Icon(icon, color: color)),
      );
    } else {
      return const SizedBox(width: 50);
    }
  }
}
