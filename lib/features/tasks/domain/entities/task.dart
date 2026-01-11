/// Represents a single task entity in the To-Do application's domain layer.
///
/// This is an immutable data class designed to hold all the necessary details
/// of a task.
class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Creates a copy of this Task with the given fields replaced.
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
