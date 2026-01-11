import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';

/// Custom exception for when a task is not found in the local database.
///
/// This exception is thrown by the [TaskLocalDataSource] when an operation
/// like `updateTask` or `deleteTask` is called for a task ID that
/// does not exist in the database.
class TaskNotFoundException implements Exception {
  /// The message describing the error.
  final String message;

  /// Creates a [TaskNotFoundException] with the given [message].
  const TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message';
}

/// Custom exception for general local database failures.
///
/// This exception encapsulates errors that occur during database operations
/// such as opening the database, executing queries, or any other `sqflite`
/// related issues. It provides a more specific error type for the repository
/// layer to handle.
class LocalDatabaseException implements Exception {
  /// The message describing the error.
  final String message;

  /// The original error object, if available, for debugging.
  final Object? originalError;

  /// Creates a [LocalDatabaseException] with the given [message] and optional [originalError].
  const LocalDatabaseException(this.message, {this.originalError});

  @override
  String toString() =>
      'LocalDatabaseException: $message${originalError != null ? ' (Original error: $originalError)' : ''}';
}

/// An abstract class defining the contract for interacting with local task data.
///
/// This interface ensures that any implementation provides standard CRUD
/// operations for [TaskModel] objects, encapsulating the underlying
/// data storage mechanism (e.g., SQLite).
abstract class TaskLocalDataSource {
  /// Retrieves a list of all tasks from the local data source.
  ///
  /// Throws a [LocalDatabaseException] if there's an issue fetching tasks.
  /// Returns a [Future] that resolves to a [List<TaskModel>].
  Future<List<TaskModel>> getTasks();

  /// Adds a new task to the local data source.
  ///
  /// The [task] to be added must be a [TaskModel].
  /// Throws a [LocalDatabaseException] if the task cannot be added.
  /// Returns a [Future] that resolves to the added [TaskModel].
  Future<TaskModel> addTask(TaskModel task);

  /// Updates an existing task in the local data source.
  ///
  /// The [task] to be updated must be a [TaskModel] with an existing ID.
  /// Throws a [TaskNotFoundException] if no task with the given ID exists.
  /// Throws a [LocalDatabaseException] if there's an issue updating the task.
  /// Returns a [Future] that resolves to the updated [TaskModel].
  Future<TaskModel> updateTask(TaskModel task);

  /// Deletes a task from the local data source by its ID.
  ///
  /// The [id] of the task to be deleted.
  /// Throws a [TaskNotFoundException] if no task with the given ID exists.
  /// Throws a [LocalDatabaseException] if there's an issue deleting the task.
  /// Returns a [Future] that completes when the task is deleted.
  Future<void> deleteTask(String id);
}

/// An implementation of [TaskLocalDataSource] using `sqflite` for local data storage.
///
/// This class manages the SQLite database operations for tasks, including
/// database initialization, table creation, and CRUD operations.
/// It follows the singleton pattern for database access to ensure
/// a single instance of the database connection.
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  /// The name of the SQLite database file.
  static const String _databaseName = 'todo_app_database.db';

  /// The version of the database schema.
  ///
  /// Used for schema migrations.
  static const int _databaseVersion = 1;

  /// The name of the tasks table.
  static const String _tableName = 'tasks';

  /// The column name for the task ID.
  static const String _columnId = 'id';

  /// The column name for the task title.
  static const String _columnTitle = 'title';

  /// The column name for the task description.
  static const String _columnDescription = 'description';

  /// The column name for the task completion status (0 for false, 1 for true).
  static const String _columnIsCompleted = 'is_completed';

  /// The column name for the task creation timestamp.
  static const String _columnCreatedAt = 'created_at';

  /// The column name for the user ID (owner of the task).
  static const String _columnUserId = 'user_id';

  /// The singleton instance of the [TaskLocalDataSourceImpl].
  ///
  /// This ensures that only one instance of the data source is created.
  static final TaskLocalDataSourceImpl _instance =
      TaskLocalDataSourceImpl._internal();

  /// Factory constructor to return the singleton instance.
  factory TaskLocalDataSourceImpl() {
    return _instance;
  }

  /// Private internal constructor for the singleton pattern.
  TaskLocalDataSourceImpl._internal();

  /// The [Database] instance, lazily initialized.
  ///
  /// This variable will hold the reference to the opened SQLite database.
  static Database? _database;

  /// Provides access to the initialized SQLite database instance.
  ///
  /// If the database has not been initialized yet, it calls `_initDatabase()`
  /// to open it. This ensures that the database is only opened once.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes and opens the SQLite database.
  ///
  /// This method performs the following steps:
  /// 1. Determines the full path for the database file.
  /// 2. Opens the database using `sqflite.openDatabase`.
  /// 3. Defines the `onCreate` callback to create the 'tasks' table if it doesn't exist.
  /// 4. Handles `onUpgrade` for future database schema migrations.
  ///
  /// Throws a [LocalDatabaseException] if the database fails to open or initialize.
  Future<Database> _initDatabase() async {
    try {
      final String databasesPath = await getDatabasesPath();
      final String path = p.join(databasesPath, _databaseName);

      return openDatabase(
        path,
        version: _databaseVersion,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE $_tableName (
            $_columnId TEXT PRIMARY KEY,
            $_columnUserId TEXT NOT NULL,
            $_columnTitle TEXT NOT NULL,
            $_columnDescription TEXT,
            $_columnIsCompleted INTEGER NOT NULL DEFAULT 0,
            $_columnCreatedAt TEXT NOT NULL
          )
        ''');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // For future migrations, e.g., adding new columns or tables.
          // Currently, only version 1 exists.
          if (oldVersion < newVersion) {
            // Example: if upgrading from version 1 to 2
            // await db.execute("ALTER TABLE $_tableName ADD COLUMN new_column TEXT;");
            // print('Database upgraded from version $oldVersion to $newVersion');
          }
        },
        onConfigure: (Database db) async {
          // Enable foreign key support, if any were to be added.
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to initialize database.',
          originalError: e);
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      // Convert the List<Map<String, dynamic>> to List<TaskModel>.
      return List<TaskModel>.from(
        maps.map((Map<String, dynamic> map) => TaskModel.fromMap(map)),
      );
    } on FormatException catch (e) {
      // Catch parsing errors from TaskModel.fromMap
      throw LocalDatabaseException(
          'Failed to parse task data from database.',
          originalError: e);
    } catch (e) {
      // Catch any other database exceptions
      throw LocalDatabaseException(
          'Failed to retrieve tasks from local database.',
          originalError: e);
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    try {
      final Database db = await database;
      await db.insert(
        _tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace if ID already exists
      );
      return task;
    } catch (e) {
      throw LocalDatabaseException('Failed to add task to local database.',
          originalError: e);
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final Database db = await database;
      final int rowsAffected = await db.update(
        _tableName,
        task.toMap(),
        where: '$_columnId = ?',
        whereArgs: <String>[task.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (rowsAffected == 0) {
        throw TaskNotFoundException('Task with ID ${task.id} not found.');
      }
      return task;
    } on TaskNotFoundException {
      rethrow; // Re-throw specific not found exception
    } catch (e) {
      throw LocalDatabaseException('Failed to update task in local database.',
          originalError: e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final Database db = await database;
      final int rowsAffected = await db.delete(
        _tableName,
        where: '$_columnId = ?',
        whereArgs: <String>[id],
      );

      if (rowsAffected == 0) {
        throw TaskNotFoundException('Task with ID $id not found.');
      }
    } on TaskNotFoundException {
      rethrow; // Re-throw specific not found exception
    } catch (e) {
      throw LocalDatabaseException('Failed to delete task from local database.',
          originalError: e);
    }
  }

  /// Closes the database connection.
  ///
  /// This method should be called when the application is shutting down
  /// or when the database is no longer needed to release resources.
  Future<void> close() async {
    final Database? currentDb = _database;
    if (currentDb != null && currentDb.isOpen) {
      await currentDb.close();
      _database = null; // Clear the reference
    }
  }
}

/// An in-memory implementation of [TaskLocalDataSource] for Web platform.
///
/// This implementation stores tasks in memory and is suitable for
/// platforms where SQLite is not available (like Web).
class InMemoryTaskLocalDataSource implements TaskLocalDataSource {
  final List<TaskModel> _tasks = [];

  @override
  Future<List<TaskModel>> getTasks() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw TaskNotFoundException('Task with ID ${task.id} not found.');
    }
    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskNotFoundException('Task with ID $id not found.');
    }
    _tasks.removeAt(index);
  }
}