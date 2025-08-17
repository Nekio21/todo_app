import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const Loader({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [child,if (isLoading) CircularProgressIndicator()],
        ),
      ),
    );
  }
}
