import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/database/app_database.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/todo/models/todo.dart';
import 'package:todo_app/weather/models/weather.dart';
import 'package:todo_app/weather/services/weather_service.dart';

import '../../core/util/message.dart';

class TodoViewModel extends ChangeNotifier {
  final StreamController<Message> _msgController = StreamController<Message>();

  Stream<Message> get msgStream => _msgController.stream;

  Box<Todo>? _database;

  Box<Todo>? get database => _database;

  bool _showArchive = false;

  bool get showArchive => _showArchive;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int? _howMany;

  int? get howMany => _howMany;

  int? _theBestDay;

  int? get theBestDay => _theBestDay;

  Future<Weather?>? _weather;

  Future<Weather?>? get weather => _weather;

  bool _isWeatherApiErrorShown = false;
  bool get isWeatherApiErrorShown => _isWeatherApiErrorShown;

  TodoViewModel();

  void init() async {
    setLoading(true);
    final result = await AppDatabase.init();
    if (result == null) {
      _msgController.add(Message.databaseNotInitialized);
    } else {
      _database = result;
    }

    _isWeatherApiErrorShown = false;
    _weather = WeatherService.fetchWeather();

    countHowMany();
    countTheBestDay();

    setLoading(false);
  }

  void save(String? name, String? desc, DateTime? deadline) async {
    if (name == null || name == "" || deadline == null) {
      _msgController.add(Message.validationFailed);
      return;
    }

    setLoading(true);
    Todo todo = Todo(
      title: name,
      description: desc,
      deadline: deadline,
      isDone: false,
      createdAt: DateTime.now(),
    );
    if (_database != null) {
      await _database?.add(todo);
      setNotification(todo);
    } else {
      _msgController.add(Message.databaseNotInitialized);
    }
    setLoading(false);
  }

  Future<void> toggleDone(Todo todo) async {
    setLoading(true);
    todo.toggleDone();
    await todo.save();
    if (todo.isDone) {
      NotificationService.cancel(todo.key);
    } else {
      setNotification(todo);
    }
    countHowMany();
    countTheBestDay();

    _msgController.add(
      todo.isDone ? Message.addedToDoToArchive : Message.addedToDo,
    );
    setLoading(false);
  }

  void setNotification(Todo todo) {
    NotificationService.scheduleNotification(
      id: todo.key,
      title: todo.title,
      body: todo.description ?? "",
      scheduledTime: NotificationService.getNotificationDateTime(todo.deadline),
    );
  }

  void toggleShow(Todo todo) async {
    todo.toggleShowDescription();
    notifyListeners();
  }

  void delete(Todo todo) async {
    setLoading(true);
    NotificationService.cancel(todo.key);
    await todo.delete();
    _msgController.add(Message.deletedToDo);
    countHowMany();
    countTheBestDay();
    setLoading(false);
  }

  void update(
    Todo original,
    String? name,
    String? desc,
    DateTime? deadline,
  ) async {
    if (name == null || name == "" || deadline == null) {
      _msgController.add(Message.validationFailed);
      return;
    }

    setLoading(true);

    if (_database != null) {
      original.title = name;
      original.description = desc;
      original.deadline = deadline;
      await original.save();
      _msgController.add(Message.updatedToDo);
    } else {
      _msgController.add(Message.databaseNotInitialized);
    }

    setLoading(false);
  }

  void setMsg(Message msg) {
    _msgController.add(msg);
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setWeatherApiErrorAsShown(bool isWeatherApiErrorShown) {
    _isWeatherApiErrorShown  = isWeatherApiErrorShown;
    notifyListeners();
  }

  void toggleArchive() {
    _showArchive = !_showArchive;
    notifyListeners();
  }

  void countHowMany() {
    _howMany = _database?.values.where((todo) => todo.isDone).toList().length;
    notifyListeners();
  }

  void countTheBestDay() {
    final List<int?> numbers =
        _database?.values
            .where((todo) => todo.isDone)
            .map((todo) => todo.completedAt?.weekday)
            .toList() ??
        [];

    Map<int, int> counts = {};
    for (int? number in numbers) {
      if (number == null) continue;
      counts[number] = (counts[number] ?? 0) + 1;
    }

    int? mostFrequent = counts.isEmpty
        ? null
        : counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    _theBestDay = mostFrequent;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _msgController.close();
  }
}
