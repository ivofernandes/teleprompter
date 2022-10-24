import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MySnackBar {
  static void show({
    required BuildContext context,
    required String text,
    Duration duration = const Duration(seconds: 4),
  }) {
    showTopSnackBar(
      context,
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Scaffold(
            body: Text(
              text,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
      ),
      displayDuration: duration,
    );
  }
}
