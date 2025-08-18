import 'package:easy_localization/easy_localization.dart';

import 'message.dart';

extension MessageExt on Message {
  String localized() {
    switch (this) {
      case Message.databaseNotInitialized: return "errors.database_not_initialized".tr();
      case Message.validationFailed: return "errors.validation_error".tr();
      case Message.addedToDoToArchive: return "todo.added_to_archive".tr();
      case Message.addedToDo: return "todo.restored".tr();
      case Message.updatedToDo: return "todo.updated".tr();
      case Message.deletedToDo: return "todo.deleted".tr();
      case Message.weatherApiUnavailable: return "weather.not_working".tr();
    }
  }
}