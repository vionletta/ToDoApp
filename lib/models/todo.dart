import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime? dueDate;
  final String userId;
  final String category; // NEW: kategori todo
  final String? calendarEventId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.category,
    this.isDone = false,
    this.dueDate,
    this.calendarEventId,
  });

  bool get isToday => _sameDate(dueDate, DateTime.now());
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _sameDate(dueDate, tomorrow);
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return dueDate!.isBefore(todayDateOnly);
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
    String? userId,
    String? category,
    String? calendarEventId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'userId': userId,
      'category': category,
      'calendarEventId': calendarEventId,
    };
  }

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    DateTime? _parse(dynamic raw) {
      if (raw == null) return null;
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }

    return Todo(
      id: id,
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isDone: map['isDone'] == true,
      dueDate: _parse(map['dueDate']),
      userId: (map['userId'] ?? '').toString(),
      category: (map['category'] ?? 'Lain-lain').toString(),
      calendarEventId: map['calendarEventId'] as String?,
    );
  }

  factory Todo.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Todo.fromMap(doc.id, doc.data() ?? {});
  }

  static bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
