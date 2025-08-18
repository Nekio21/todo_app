import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/action_button.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_text_style.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/data_picker.dart';
import '../models/todo.dart';
import '../viewmodel/todo_viewmodel.dart';

class TodoShowModal extends StatefulWidget {
  final TodoViewModel vm;
  final Todo? todo;

  const TodoShowModal({super.key, required this.vm, this.todo});

  @override
  State<TodoShowModal> createState() => _TodoShowModalState();
}

class _TodoShowModalState extends State<TodoShowModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.todo?.title ?? '');
    _descController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedDeadline = widget.todo?.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

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
                  controller: _nameController,
                  style: AppTextStyle.captionRegular.apply(
                    color: AppTheme.secondary,
                  ),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'todo.task_name'.tr(),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'todo.field_empty'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.small),
                TextField(
                  controller: _descController,
                  style: AppTextStyle.captionRegular.apply(
                    color: AppTheme.secondary,
                  ),
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'todo.description'.tr(),
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
                  child: DataPicker(
                    validator: (value) {
                      if (value == null ||
                          value.isBefore(DateTime.now()) == true) {
                        return '';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _selectedDeadline = value;
                    },
                  ),
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
                        "actions.cancel".tr(),
                        style: AppTextStyle.captionBold.apply(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    ActionButton(
                      widget.todo != null ? "actions.update".tr() : "todo.add_new".tr(),
                      function: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (widget.todo != null) {
                            vm.update(
                              widget.todo!,
                              _nameController.text,
                              _descController.text,
                              _selectedDeadline,
                            );
                          } else {
                            vm.save(
                              _nameController.text,
                              _descController.text,
                              _selectedDeadline,
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
  }
}

