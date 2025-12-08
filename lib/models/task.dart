class Task {
  final String id;
  String title;
  String? description;
  DateTime? dueDate;
  bool reminder;
  DateTime? reminderDate;
  bool completed;
  String priority;

  Task({
    String? id,
    required this.title,
    this.description,
    this.dueDate,
    this.reminder = false,
    this.reminderDate,
    this.completed = false,
    this.priority = 'Medium',
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? reminder,
    DateTime? reminderDate,
    bool? completed,
    String? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      reminderDate: reminderDate ?? this.reminderDate,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'reminder': reminder,
      'reminderDate': reminderDate?.toIso8601String(),
      'completed': completed,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      reminder: map['reminder'] as bool? ?? false,
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate'] as String) : null,
      completed: map['completed'] as bool? ?? false,
      priority: map['priority'] as String? ?? 'Medium',
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority)';
  }
}
