import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class StorageService {
  static const String _boxName = 'tasks_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<List<Task>> getAllTasks() async {
    final box = _box;
    final List<Task> tasks = [];
    for (final val in box.values) {
      try {
        tasks.add(Task.fromMap(Map<String, dynamic>.from(val)));
      } catch (_) {}
    }
    return tasks;
  }

  static Future<void> saveTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<Task?> getTask(String id) async {
    final val = _box.get(id);
    if (val == null) return null;
    return Task.fromMap(Map<String, dynamic>.from(val));
  }

  static Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}

