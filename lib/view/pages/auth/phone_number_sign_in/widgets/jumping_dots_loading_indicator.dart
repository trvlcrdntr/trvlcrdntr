import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class JumpingDotsLoadingIndicator extends StatelessWidget {
  final Color? color;
  const JumpingDotsLoadingIndicator({this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: JumpingDotsProgressIndicator(
          fontSize: 100.0,
          numberOfDots: 5,
          milliseconds: 120,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
