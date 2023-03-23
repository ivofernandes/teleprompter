import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MySnackBar {
  /// Show a snackbar with the given [text] and [style].
  static void show({
    required BuildContext context,
    required String text,
    TextStyle? style,
    Duration duration = const Duration(seconds: 4),
  }) {
    showTopSnackBar(
      Overlay.of(context),
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Scaffold(
            body: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                text,
                style: style ?? Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
      displayDuration: duration,
    );
  }

  /// Show an error snackbar with the given [text]
  static void showError({
    required BuildContext context,
    required String text,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      text: text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
      duration: duration,
    );
  }
}
