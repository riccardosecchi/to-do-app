/// /Users/riccardo/Desktop/dirProva/todo_app/lib/features/tasks/data/models/task_model.dart
import '../../domain/entities/task.dart';

/// [TaskModel] represents a task data structure specific to the data layer.
///
/// It extends the [Task] domain entity, allowing it to inherit core task properties
/// and be seamlessly converted to and from the domain entity.
/// This model handles serialization and deserialization for data sources
/// like SQLite, including specific type conversions (e.g., `bool` to `int`,
/// `DateTime` to ISO8601 string).
///
/// By extending [Task], [TaskModel] instances can be used wherever a [Task]
/// is expected, ensuring compatibility with the domain layer.
class TaskModel extends Task {
  /// Creates a [TaskModel] instance.
  ///
  /// All parameters are directly mapped to the [Task] entity's properties.
  /// It uses named parameters with `required` for clarity and null safety,
  /// delegating to the super constructor of [Task].
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.isCompleted = false,
    required super.createdAt,
  });

  /// Factory constructor to create a [TaskModel] from a `Map<String, dynamic>`.
  ///
  /// This is typically used when reading data from a data source like SQLite.
  /// It handles:
  /// - Parsing `id` and `title` as non-nullable strings.
  /// - Parsing `description` as a nullable string.
  /// - Converting `isCompleted` from an integer (0 or 1) to a boolean (`false` or `true`).
  /// - Parsing `createdAt` from an ISO8601 string to a `DateTime` object.
  ///
  /// Throws a [FormatException] if any required field is missing, has an
  /// invalid type, or if the `createdAt` string is not a valid ISO8601 format.
  /// This ensures robust error handling for corrupted or malformed data.
  ///
  /// Example SQLite row conversion:
  /// ```dart
  /// final Map<String, dynamic> data = {
  ///   'id': 'task_123',
  ///   'title': 'Buy groceries',
  ///   'description': 'Milk, eggs, bread',
  ///   'isCompleted': 0, // SQLite stores boolean as INT
  ///   'createdAt': '2023-10-26T10:00:00.000Z', // ISO8601 string
  /// };
  /// final TaskModel taskModel = TaskModel.fromMap(data);
  /// ```
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    try {
      final String id = map['id'] as String;
      final String userId = map['user_id'] as String;
      final String title = map['title'] as String;
      final String? description = map['description'] as String?;
      // Handle both integer (SQLite) and boolean (Supabase) for is_completed.
      final isCompleted = map['is_completed'] is bool
          ? map['is_completed'] as bool
          : (map['is_completed'] as int) == 1;
      // DateTime is stored as an ISO8601 string.
      final DateTime createdAt = DateTime.parse(map['created_at'] as String);

      return TaskModel(
        id: id,
        userId: userId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        createdAt: createdAt,
      );
    } on TypeError catch (e) {
      throw FormatException(
        'Failed to parse TaskModel from map due to type error: $e. Map: $map',
      );
    } on FormatException catch (e) {
      throw FormatException(
        'Failed to parse TaskModel from map due to data format error: $e. Map: $map',
      );
    } catch (e) {
      // Catch any other unexpected errors during parsing for robustness.
      throw FormatException(
        'An unknown error occurred while parsing TaskModel from map: $e. Map: $map',
      );
    }
  }

  /// Factory constructor to create a [TaskModel] from a [Task] domain entity.
  ///
  /// This is used when converting a domain entity received from the domain layer
  /// (e.g., after business logic processing) into a data layer model for storage.
  /// It simply maps the properties of the domain entity to the model.
  ///
  /// Example:
  /// ```dart
  /// final Task domainTask = Task(id: '1', title: 'Test', createdAt: DateTime.now());
  /// final TaskModel taskModel = TaskModel.fromEntity(domainTask);
  /// ```
  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this [TaskModel] instance back into a `Map<String, dynamic>`.
  ///
  /// This is typically used when writing data to a data source like SQLite.
  /// It handles:
  /// - Converting `isCompleted` from a boolean (`true`/`false`) to an integer (1/0).
  /// - Converting `createdAt` from a `DateTime` object to an ISO8601 string.
  /// - `description` is included as `null` if its value is `null`.
  ///
  /// Example:
  /// ```dart
  /// final TaskModel taskModel = TaskModel(
  ///   id: 'task_123',
  ///   title: 'Buy groceries',
  ///   isCompleted: false,
  ///   createdAt: DateTime.now(),
  /// );
  /// final Map<String, dynamic> data = taskModel.toMap();
  /// // data will contain (example values):
  /// // {
  /// //   'id': 'task_123',
  /// //   'title': 'Buy groceries',
  /// //   'description': null,
  /// //   'isCompleted': 0,
  /// //   'createdAt': '2023-10-26T10:00:00.000Z'
  /// // }
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0, // Convert true/false to 1/0 for SQLite
      'created_at':
          createdAt.toIso8601String(), // Convert DateTime to ISO8601 string
    };
  }

  /// Converts this [TaskModel] to a map for Supabase.
  /// Uses boolean for is_completed instead of integer.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts this [TaskModel] instance back into a [Task] domain entity.
  ///
  /// This is used when data is retrieved from a data source and needs to be
  /// passed up to the domain or presentation layer for business logic or UI display.
  ///
  /// Since [TaskModel] extends [Task], this method simply returns `this` instance
  /// as it already conforms to the [Task] interface. This makes the conversion
  /// efficient and direct without creating a new object.
  ///
  /// Example:
  /// ```dart
  /// final TaskModel taskModel = TaskModel.fromMap(someDatabaseRow);
  /// final Task domainTask = taskModel.toEntity();
  /// ```
  Task toEntity() {
    return this; // TaskModel already IS a Task due to inheritance.
  }

  /// Overrides the `toString()` method to provide a more descriptive
  /// string representation of a [TaskModel] instance for debugging purposes.
  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, createdAt: $createdAt)';
  }
}