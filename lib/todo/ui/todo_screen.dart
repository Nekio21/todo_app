import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/ui/app_spacing.dart';
import 'package:todo_app/core/ui/app_text_style.dart';
import 'package:todo_app/core/util/message_ext.dart';
import 'package:todo_app/todo/models/todo.dart';
import 'package:todo_app/todo/ui/todo_showmodal.dart';
import 'package:todo_app/todo/ui/todo_tile.dart';
import 'package:todo_app/todo/viewmodel/todo_viewmodel.dart';
import 'package:todo_app/weather/models/weather.dart';

import '../../core/ui/action_button.dart';
import '../../core/ui/app_background.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/loader.dart';
import '../../core/util/message.dart';

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

class _TodoScreenState extends State<TodoScreenWidget>
    with WidgetsBindingObserver {
  late final StreamSubscription<Message> _messageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final vm = context.read<TodoViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.init();
    });

    _messageSubscription = vm.msgStream.listen((msg) {
      showMessage(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodoViewModel>();

    return AppBackground(
      name: vm.showArchive ? 'general.archive'.tr() : 'general.app_name'.tr(),
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

                  final List filteredTodos = todosBox.values
                      .toList()
                      .where((td) => td.isDone == vm.showArchive)
                      .toList();

                  filteredTodos.sort(
                    (a, b) => a.deadline.compareTo(b.deadline),
                  );

                  return ListView.separated(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final Todo todo = filteredTodos[index];
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
                          showModal: () => showTodoModal(context, todo: todo),
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
              ActionButton(
                "todo.add_new".tr(),
                function: () => showTodoModal(context),
              ),
            if (!vm.showArchive) summarySection(),
          ],
        ),
      ),
    );
  }

  Widget summarySection() {
    final vm = context.watch<TodoViewModel>();
    return cardContainer(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.howMany.toString(), style: AppTextStyle.bodyLarge),
              Text("general.success".tr(), style: AppTextStyle.captionBold),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vm.theBestDay != null
                    ? DateFormat.EEEE()
                          .format(
                            DateTime(
                              2025,
                              8,
                              17,
                            ).add(Duration(days: vm.theBestDay ?? 0)),
                          )
                          .tr()
                    : "general.no_data".tr(),
                style: AppTextStyle.bodyLarge,
              ),
              Text("general.productive_day".tr(), style: AppTextStyle.captionBold),
            ],
          ),
        ],
      ),
    );
  }

  Widget weatherBar() {
    final vm = context.watch<TodoViewModel>();

    return FutureBuilder<Weather?>(
      future: vm.weather,
      builder: (context, snapshot) {
        final Weather? weather = snapshot.data;

        if (snapshot.hasError) {
          vm.setMsg(Message.weatherApiUnavailable);
        }

        if (weather != null) {
          return cardContainer(
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: AppSpacing.small,
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                      width: 48,
                      height: 48,
                    ),
                    Text("${weather.temp}°C", style: AppTextStyle.bodyLarge),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${"weather.feels_like".tr()}: ${weather.feelTemp}°C",
                      style: AppTextStyle.captionRegular,
                    ),
                    Text(
                      "${"weather.precipitation".tr()}: ${weather.rain} mm/h",
                      style: AppTextStyle.captionRegular,
                    ),
                    Text(
                      "${"weather.cloud_cover".tr()}: ${weather.clouds}%",
                      style: AppTextStyle.captionRegular,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget cardContainer(Widget child) {
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

  void showTodoModal(BuildContext context, {Todo? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TodoShowModal(todo: todo, vm: context.read<TodoViewModel>()),
    );
  }

  void showMessage(Message msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.localized()),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      final vm = context.read<TodoViewModel>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.init();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription.cancel();
  }
}
