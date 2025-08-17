import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/todo_viewmodel.dart';

import 'app_spacing.dart';
import 'app_text_style.dart';
import 'app_theme.dart';

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
  late bool done;
  late bool clicked;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    done = widget.todo.done;
    clicked = false;
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
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
                    key: ValueKey(done),
                    icon: Icon(
                      done
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: AppTheme.onSurface,
                    ),
                    tooltip: "zrobione ?",
                    onPressed: () async {
                      if (clicked == false) {
                        clicked = true;
                        setState(() {
                          done = !done;
                        });
                        await Future.delayed(Duration(milliseconds: 1000));
                        await widget.vm.toggleDone(widget.todo);
                        clicked = false;
                        done = widget.todo.done;
                      }
                    },
                  ),
                ),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(
                      key: ValueKey(done),
                      widget.todo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyle.captionBold,
                    ),
                  ),
                ),
                Text(
                  widget.vm.showArchive
                      ? "done ${DateFormat('dd.MM.yyyy').format(widget.todo.doneTime ?? DateTime.now())}"
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
                  heightFactor: widget.todo.showDesc ? 1.0 : 0.0,
                  child: Column(
                    spacing: AppSpacing.small,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 56),
                        child: SizedBox(width: double.maxFinite, child:Text(
                          widget.todo.desc ?? '',
                          style: AppTextStyle.captionSmall,
                          textAlign: TextAlign.start,
                        )),
                      ),
                      Text(
                        'created ${DateFormat('dd.MM.yyyy').format(widget.todo.createdTime)}',
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
                                  "delete",
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
                                  "edit",
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

    String delay = isNegative ? 'delay' : '';

    if (durationAbs.inDays > 0) {
      return "$delay ${durationAbs.inDays} dni ${durationAbs.inHours % 24} H ${durationAbs.inMinutes % 60} min";
    } else if (durationAbs.inHours > 0) {
      return "$delay ${durationAbs.inHours % 24} H ${durationAbs.inMinutes % 60} min";
    } else {
      return "$delay ${durationAbs.inMinutes % 60} min";
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
