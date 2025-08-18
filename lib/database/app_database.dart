import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/todo/models/todo.dart';

class AppDatabase {
  static bool _initialized = false;
  static String databaseName = "todoBox";

  static Future<Box<Todo>?> init() async {
    try {
      if (!_initialized) {
        await Hive.initFlutter();
        Hive.registerAdapter(TodoAdapter());
        _initialized = true;
      }
      return await Hive.openBox<Todo>(databaseName);
    } catch (e) {
      return null;
    }
  }
}
