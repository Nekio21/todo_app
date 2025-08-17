import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/app_database.dart';
import 'package:todo_app/notification_service.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/weather_service.dart';

import 'error_msg.dart';

class TodoViewModel extends ChangeNotifier {
  final _msgController = StreamController<Message>();

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

  TodoViewModel();

  void init() async {
    setLoading(true);
    final result = await AppDatabase.init();
    if (result == null) {
      _msgController.add(Message.databaseNotInit);
    } else {
      _database = result;
    }

    await WeatherService.fetchWeather();

    countHowMany();
    countTheBestDay();

    setLoading(false);
  }

  void save(String? name, String? desc, DateTime? deadline) async {
    if (name == null || name == "" || deadline == null) {
      _msgController.add(Message.validationError);
      return;
    }

    setLoading(true);
    Todo todo = Todo(
      name: name,
      desc: desc,
      deadline: deadline,
      done: false,
      createdTime: DateTime.now(),
    );
    if (_database != null) {
      await _database?.add(todo);
      NotificationService.scheduleNotification(id: todo.key, title: todo.name, body: todo.desc ?? "", scheduledTime: NotificationService.getNotificationDateTime(deadline));
    } else {
      _msgController.add(Message.databaseNotInit);
    }
    setLoading(false);
  }

  Future<void> toggleDone(Todo todo) async {
    setLoading(true);
    todo.toggleDone();
    await todo.save();
    if(todo.done){
      NotificationService.cancel(todo.key);
    }else{
      NotificationService.scheduleNotification(id: todo.key, title: todo.name, body: todo.desc ?? "", scheduledTime: NotificationService.getNotificationDateTime(todo.deadline));
    }
    countHowMany();
    countTheBestDay();

    _msgController.add(todo.done ? Message.addedToArchive : Message.addedToDo);
    setLoading(false);
  }

  void toggleShow(Todo todo) async {
    todo.toggleShowDesc();
    notifyListeners();
  }

  void delete(Todo todo) async {
    setLoading(true);
    NotificationService.cancel(todo.key);
    await todo.delete();
    _msgController.add(Message.deleted);
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
      _msgController.add(Message.validationError);
      return;
    }

    setLoading(true);

    if (_database != null) {
      original.name = name;
      original.desc = desc;
      original.deadline = deadline;
      await original.save();
      _msgController.add(Message.updated);
    } else {
      _msgController.add(Message.databaseNotInit);
    }

    setLoading(false);
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void toggleArchive() {
    _showArchive = !_showArchive;
    notifyListeners();
  }

  void countHowMany(){
    _howMany = _database?.values.where((todo)=>todo.done).toList().length;
    notifyListeners();
  }

  void countTheBestDay(){
    final List<int?> numbers = _database?.values.where((todo)=>todo.done).map((todo)=> todo.doneTime?.weekday).toList() ?? [];

    Map<int, int> counts = {};
    for (int? number in numbers) {
      if(number == null) continue;
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
