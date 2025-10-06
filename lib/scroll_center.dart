import 'package:flutter/material.dart';

class CenterOrScroll extends StatelessWidget {
  final Widget child;
  const CenterOrScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }
}