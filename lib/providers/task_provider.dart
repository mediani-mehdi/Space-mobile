import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> loadTasks() async {
    final loaded = await StorageService.getAllTasks();
    _tasks
      ..clear()
      ..addAll(loaded);
    _tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await StorageService.saveTask(task);
    await NotificationService().scheduleNotification(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await StorageService.saveTask(task);
      await NotificationService().cancelNotification(task.id);
      await NotificationService().scheduleNotification(task);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await StorageService.deleteTask(id);
    await NotificationService().cancelNotification(id);
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = _tasks[idx];
      final updated = t.copyWith(completed: !t.completed);
      _tasks[idx] = updated;
      await StorageService.saveTask(updated);
      notifyListeners();
    }
  }
}

