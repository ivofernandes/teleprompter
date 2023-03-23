import 'package:flutter/material.dart';
import 'package:teleprompter/src/shared/bottom_border.dart';

class ExpandableComponent extends StatefulWidget {
  final double height;
  final double maxHeight;
  final double dividerHeight;
  final double dividerSpace;
  final double remainingSpace;
  final Widget child;

  const ExpandableComponent({
    required this.child,
    this.height = 300,
    this.maxHeight = 1300,
    this.dividerHeight = 80,
    this.dividerSpace = 2,
    this.remainingSpace = 100,
    super.key,
  });

  @override
  _ExpandableComponentState createState() => _ExpandableComponentState();
}

class _ExpandableComponentState extends State<ExpandableComponent> {
  double? _height;
  late double _maxHeight;
  late double _dividerHeight;
  late double _dividerSpace;

  @override
  void initState() {
    super.initState();
    _height = widget.height;
    _maxHeight = widget.maxHeight;
    _dividerHeight = widget.dividerHeight;
    _dividerSpace = widget.dividerSpace;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final textHeight = _height! < screenHeight - widget.remainingSpace
        ? _height
        : screenHeight - widget.remainingSpace;

    return SizedBox(
      height: _maxHeight,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: textHeight,
              child: widget.child,
            ),
          ),
          Positioned(
            top: textHeight! - 40,
            child: SizedBox(
              height: _dividerHeight - 30.0,
              width: screenWidth,
              child: GestureDetector(
                child: Container(
                  color: Colors.blue.withOpacity(0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 120,
                  ),
                  child: const BottomBorder(),
                ),
                onPanUpdate: (details) {
                  setState(() {
                    _height = _height! + details.delta.dy;

                    // prevent overflow if height is more/less than available space
                    final maxLimit =
                        _maxHeight - _dividerHeight - _dividerSpace - 60;
                    const minLimit = 44.0;

                    if (_height! > maxLimit) {
                      _height = maxLimit;
                    } else if (_height! < minLimit) {
                      _height = minLimit;
                    }
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
