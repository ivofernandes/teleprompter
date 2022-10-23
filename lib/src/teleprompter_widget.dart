import 'package:flutter/cupertino.dart';

class TeleprompterWidget extends StatelessWidget {
  /// Text that will be presented in the teleprompter
  final String text;

  const TeleprompterWidget({
    this.text = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
