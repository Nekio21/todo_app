import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/todo/models/todo.dart';
import 'package:todo_app/todo/viewmodel/todo_viewmodel.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_text_style.dart';
import '../../core/ui/app_theme.dart';

class TodoTile extends StatefulWidget {
  final Todo todo;
  final TodoViewModel vm;
  final Function? showModal;

  const TodoTile({
    required this.todo,
    required this.vm,
    this.showModal,
    super.key,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  late bool _done;
  late bool _clicked;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _done = widget.todo.isDone;
    _clicked = false;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color:
            widget.todo.getDuration(DateTime.now()).isNegative &&
                !widget.vm.showArchive
            ? AppTheme.error
            : AppTheme.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
      width: double.maxFinite,
      child: InkWell(
        onTap: () {
          widget.vm.toggleShow(widget.todo);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              spacing: AppSpacing.small,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: IconButton(
                    key: ValueKey(_done),
                    icon: Icon(
                      _done
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: AppTheme.onSurface,
                    ),
                    tooltip: "${"todo.completed".tr()}?",
                    onPressed: () async {
                      if (_clicked == false) {
                        _clicked = true;
                        setState(() {
                          _done = !_done;
                        });
                        await Future.delayed(Duration(milliseconds: 1000));
                        await widget.vm.toggleDone(widget.todo);
                        _clicked = false;
                        _done = widget.todo.isDone;
                      }
                    },
                  ),
                ),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      decoration: _done ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(
                      key: ValueKey(_done),
                      widget.todo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyle.captionBold,
                    ),
                  ),
                ),
                Text(
                  widget.vm.showArchive
                      ? "${"todo.completed".tr()}: ${DateFormat('dd.MM.yyyy').format(widget.todo.completedAt ?? DateTime.now())}"
                      : getDurationText(
                          widget.todo.getDuration(DateTime.now()),
                        ),
                  style: AppTextStyle.captionRegular,
                ),
              ],
            ),
            ClipRect(
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.centerRight,
                  heightFactor: widget.todo.showDescription ? 1.0 : 0.0,
                  child: Column(
                    spacing: AppSpacing.small,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 56),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            widget.todo.description ?? '',
                            style: AppTextStyle.captionSmall,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Text(
                        '${"todo.created".tr()} ${DateFormat('dd.MM.yyyy').format(widget.todo.createdAt)}',
                        style: AppTextStyle.captionSmall,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppSpacing.small,
                        children: [
                          InkWell(
                            onTap: () {
                              widget.vm.delete(widget.todo);
                            },
                            child: Row(
                              spacing: AppSpacing.small,
                              children: [
                                Icon(Icons.delete, color: AppTheme.onSecondary),
                                Text(
                                  "actions.delete".tr(),
                                  style: AppTextStyle.captionSmallBold,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              widget.showModal?.call();
                            },
                            child: Row(
                              spacing: AppSpacing.small,
                              children: [
                                Icon(
                                  Icons.brush_outlined,
                                  color: AppTheme.onSecondary,
                                ),
                                Text(
                                  "actions.edit".tr(),
                                  style: AppTextStyle.captionSmallBold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDurationText(Duration duration) {
    final isNegative = duration.isNegative;
    final durationAbs = duration.abs();

    String delay = isNegative ? 'errors.delay'.tr() : '';

    if (durationAbs.inDays > 0) {
      return "$delay ${durationAbs.inDays}d ${durationAbs.inHours % 24}h ${durationAbs.inMinutes % 60}m";
    } else if (durationAbs.inHours > 0) {
      return "$delay ${durationAbs.inHours % 24}h ${durationAbs.inMinutes % 60}m";
    } else {
      return "$delay ${durationAbs.inMinutes % 60}m";
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
