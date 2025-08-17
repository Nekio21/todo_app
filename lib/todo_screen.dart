import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/app_spacing.dart';
import 'package:todo_app/app_text_style.dart';
import 'package:todo_app/data_picker.dart';
import 'package:todo_app/error_msg.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/todo_tile.dart';
import 'package:todo_app/todo_viewmodel.dart';

import 'app_background.dart';
import 'app_theme.dart';
import 'loader.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TodoViewModel(),
      child: const TodoScreenWidget(),
    );
  }
}

class TodoScreenWidget extends StatefulWidget {
  const TodoScreenWidget({super.key});

  @override
  State<TodoScreenWidget> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreenWidget> {
  late final StreamSubscription<Message> _onMsg;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final vm = context.read<TodoViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.init();
    });

    _onMsg = vm.msgStream.listen((msg) {
      showMessage(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodoViewModel>();

    return AppBackground(
      name: vm.showArchive ? "Archive" : 'general.app_name'.tr(),
      fun: () {
        vm.toggleArchive();
      },
      child: Loader(
        isLoading: vm.isLoading,
        child: Column(
          spacing: AppSpacing.medium,
          children: [
            weatherBar(),
            Expanded(
              child: ValueListenableBuilder<Box<Todo>?>(
                valueListenable:
                    vm.database?.listenable() ?? ValueNotifier(null),
                builder: (context, Box<Todo>? todosBox, _) {
                  if (todosBox == null) {
                    return SizedBox.shrink();
                  }

                  final List todos = todosBox.values
                      .toList()
                      .where((td) => td.done == vm.showArchive)
                      .toList();

                  todos.sort((a, b) => a.deadline.compareTo(b.deadline));

                  return ListView.separated(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final Todo todo = todos[index];
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1.0,
                            child: child,
                          );
                        },
                        child: TodoTile(
                          todo: todo,
                          vm: vm,
                          key: ValueKey(todo.key),
                          showModal: () => showShowModal(context, todo: todo),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.small),
                  );
                },
              ),
            ),
            if (!vm.showArchive)
              button2("Add new task", fun: () => showShowModal(context)),
            if (!vm.showArchive) bottom(),
          ],
        ),
      ),
    );
  }

  Widget button2(String text, {Function? fun}) {
    return ElevatedButton(
      onPressed: () {
        fun?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.medium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(text, style: AppTextStyle.bodyLarge),
    );
  }

  Widget button() {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.medium,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text("Add new task", style: AppTextStyle.bodyLarge),
      ),
    );
  }

  Widget bottom() {
    final vm = context.watch<TodoViewModel>();
    return bar(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.howMany.toString(), style: AppTextStyle.bodyLarge),
              Text("success", style: AppTextStyle.captionBold),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.theBestDay != null ? DateFormat.EEEE().format(DateTime(2025, 8, 17).add(Duration(days: vm.theBestDay ?? 0))).tr() : "???", style: AppTextStyle.bodyLarge),
              Text("your productive day", style: AppTextStyle.captionBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget weatherBar() {
    return bar(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: AppSpacing.small,
            children: [
              Icon(Icons.sunny, size: 48, color: AppTheme.onSurface),
              Text("24°C", style: AppTextStyle.bodyLarge),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("odczuwalna: 21°C", style: AppTextStyle.captionRegular),
              Text("opady: brak", style: AppTextStyle.captionRegular),
              Text("zachmurzenie: duże", style: AppTextStyle.captionRegular),
            ],
          ),
        ],
      ),
    );
  }

  Widget bar(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.medium,
      ),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.maxFinite,
      child: child,
    );
  }

  void showShowModal(BuildContext context, {Todo? todo}) {
    final vm = context.read<TodoViewModel>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime? deadline;

    if (todo != null) {
      nameController.text = todo.name;
      descController.text = todo.desc ?? '';
      deadline = todo.deadline;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.surface, AppTheme.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.large).add(
                EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(width: 55, height: 1, color: AppTheme.onSurface),
                    SizedBox(height: AppSpacing.large),
                    TextFormField(
                      controller: nameController,
                      style: AppTextStyle.captionRegular.apply(
                        color: AppTheme.secondary,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Nazwa zadania*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        filled: true,
                        fillColor: AppTheme.onSecondary,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.small,
                        ),
                      ),
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Pole nie może być puste';
                        }
                        return null;
                      }
                    ),
                    SizedBox(height: AppSpacing.small),
                    TextField(
                      controller: descController,
                      style: AppTextStyle.captionRegular.apply(
                        color: AppTheme.secondary,
                      ),
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppTheme.onSecondary,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.small,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: DataPicker(validator: (value){
                        if (value == null || value.isBefore(DateTime.now()) == true) {
                          return '';
                        }
                        return null;
                      },
                      onSaved: (value){
                        deadline = value;
                      })
                    ),
                    SizedBox(height: AppSpacing.large),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: AppTheme.primary, width: 2),
                            padding: EdgeInsets.all(
                              AppSpacing.medium,
                            ), // padding
                          ),
                          child: Text(
                            "Cancel",
                            style: AppTextStyle.captionBold.apply(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        button2(
                          todo != null ? "update" : "Add new task",
                          fun: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (todo != null) {
                                vm.update(
                                  todo,
                                  nameController.text,
                                  descController.text,
                                  deadline,
                                );
                              } else {
                                vm.save(
                                  nameController.text,
                                  descController.text,
                                  deadline,
                                );
                              }
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showMessage(Message err) {
    if (!mounted) return;

    String msg = "";
    switch (err) {
      case Message.databaseNotInit:
        msg = "Database error: not initlize";
        break;
      case Message.validationError:
        msg = "Validation error: not all field are filled";
        break;
      case Message.addedToArchive:
        msg = "Dodano do archiwum";
        break;
      case Message.addedToDo:
        msg = "Przywrucono do zrobienia";
        break;
      case Message.updated:
        msg = "Updated :)";
        break;
      case Message.deleted:
        msg = "Deleted :)";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onMsg.cancel();
  }
}
