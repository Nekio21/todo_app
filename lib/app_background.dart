import 'package:flutter/material.dart';
import 'package:todo_app/app_text_style.dart';

import 'app_spacing.dart';
import 'app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String name;
  final Function? fun;

  const AppBackground({required this.child, required this.name, this.fun, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Icon(Icons.list, size: 32, color: AppTheme.onSurface),
        title: Text(name, style: AppTextStyle.headingLarge),
        actions: [IconButton(onPressed: (){fun?.call();}, icon: Icon(Icons.work_history_rounded))],
      ),
      backgroundColor: AppTheme.onSurface,
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.surface, AppTheme.surface, AppTheme.onSurface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.07, 0.47],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.large),
            child: child,
          ),
        ),
      ),
    );
  }
}
