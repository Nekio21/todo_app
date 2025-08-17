import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? desc;

  @HiveField(2)
  DateTime deadline;

  @HiveField(3)
  bool done;

  @HiveField(4)
  DateTime createdTime;

  @HiveField(5)
  DateTime? doneTime;

  bool showDesc;

  Todo({
    required this.name,
    this.desc,
    required this.deadline,
    this.done = false,
    required this.createdTime,
    this.showDesc = false,
  });

  void update(Todo updated) {
    name = updated.name;
    desc = updated.desc;
    deadline = updated.deadline;
  }

  void toggleDone() {
    done = !done;
    if (done == true) {
      doneTime = DateTime.now();
    } else {
      doneTime = null;
    }
  }

  void toggleShowDesc() {
    showDesc = !showDesc;
  }

  Duration getDuration(DateTime now){
    return deadline.difference(now);
  }
}
