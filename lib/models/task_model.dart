import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String userId;
  String title;
  String subject;
  String dueDate;
  String priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      dueDate: map['dueDate'] ?? '',
      priority: map['priority'] ?? 'Low',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
