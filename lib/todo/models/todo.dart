import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  DateTime deadline;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  bool showDescription;

  Todo({
    required this.title,
    this.description,
    required this.deadline,
    this.isDone = false,
    required this.createdAt,
    this.showDescription = false,
  });

  void update(Todo updated) {
    title = updated.title;
    description = updated.description;
    deadline = updated.deadline;
  }

  void toggleDone() {
    isDone = !isDone;
    if (isDone == true) {
      completedAt = DateTime.now();
    } else {
      completedAt = null;
    }
  }

  void toggleShowDescription() {
    showDescription = !showDescription;
  }

  Duration getDuration(DateTime now) {
    return deadline.difference(now);
  }
}
