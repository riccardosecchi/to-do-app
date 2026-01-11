/// /Users/riccardo/Desktop/dirProva/todo_app/lib/features/tasks/data/repositories/task_repository_impl.dart

// Core imports for error handling and functional programming types.
import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';

// Domain layer imports.
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

// Data layer imports.
import 'package:todo_app/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';

/// An concrete implementation of the [TaskRepository] interface.
///
/// This repository is responsible for coordinating data operations
/// for tasks, primarily by interacting with local data sources.
/// It acts as a bridge between the domain layer (which expects [Task] entities)
/// and the data layer (which works with [TaskModel]s and specific data sources).
///
/// It handles:
/// - Converting [Task] entities to [TaskModel]s before sending them to the data source.
/// - Converting [TaskModel]s back to [Task] entities after retrieving them from the data source.
/// - Wrapping data source exceptions into domain-specific [Failure] types.
/// - Implementing task filtering logic based on [TaskFilter].
class TaskRepositoryImpl implements TaskRepository {
  /// The local data source responsible for actual CRUD operations on tasks.
  final TaskLocalDataSource _localDataSource;

  /// Creates a [TaskRepositoryImpl] instance.
  ///
  /// Requires a [TaskLocalDataSource] to be injected, promoting dependency
  /// inversion and making the repository easily testable by mocking the data source.
  const TaskRepositoryImpl({
    required final TaskLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Adds a new task to the local data source.
  ///
  /// Converts the domain [Task] entity to a data layer [TaskModel],
  /// then delegates the operation to the [_localDataSource].
  /// Wraps potential data source errors into a [CacheFailure].
  ///
  /// Returns an [Either] containing a [Failure] on error or the
  /// newly added [Task] object (potentially with an updated ID) on success.
  @override
  Future<Either<Failure, Task>> addTask(final Task task) async {
    try {
      // Convert domain entity to data model.
      final TaskModel taskModel = TaskModel.fromEntity(task);
      // Delegate to local data source to add the task model.
      final TaskModel addedTaskModel = await _localDataSource.addTask(taskModel);
      // Convert the added data model back to a domain entity and return it.
      return Right<Failure, Task>(addedTaskModel.toEntity());
    } on LocalDatabaseException catch (e) {
      // Map local database specific exceptions to a CacheFailure, indicating a storage issue.
      return Left<Failure, Task>(CacheFailure(message: e.message));
    } on Exception catch (e) {
      // Catch any other unexpected exceptions and return a generic CacheFailure.
      return Left<Failure, Task>(
          CacheFailure(message: 'An unknown error occurred while adding task: $e'));
    }
  }

  /// Deletes a task from the local data source by its ID.
  ///
  /// Delegates the deletion operation to the [_localDataSource].
  /// Wraps potential data source errors into [NotFoundFailure] if the task
  /// does not exist, or [CacheFailure] for other storage-related issues.
  ///
  /// Returns an [Either] containing a [Failure] on error or [void] on
  /// successful deletion.
  @override
  Future<Either<Failure, void>> deleteTask(final String id) async {
    try {
      // Delegate to local data source to delete the task by ID.
      await _localDataSource.deleteTask(id);
      // Return Right(null) to indicate successful completion of a void operation.
      return const Right<Failure, void>(null);
    } on TaskNotFoundException catch (e) {
      // Map specific not found exception to NotFoundFailure, as per domain requirements.
      return Left<Failure, void>(NotFoundFailure(message: e.message));
    } on LocalDatabaseException catch (e) {
      // Map local database specific exceptions to a CacheFailure.
      return Left<Failure, void>(CacheFailure(message: e.message));
    } on Exception catch (e) {
      // Catch any other unexpected exceptions and return a generic CacheFailure.
      return Left<Failure, void>(
          CacheFailure(message: 'An unknown error occurred while deleting task: $e'));
    }
  }

  /// Retrieves a list of tasks from the local data source, with an optional filter.
  ///
  /// Delegates the initial fetch of all tasks to the [_localDataSource].
  /// Then, it filters the retrieved list of [TaskModel]s in memory based on
  /// the provided [filter] (e.g., all, completed, pending) before converting
  /// them to [Task] entities for the domain layer.
  /// Wraps potential data source errors into a [CacheFailure].
  ///
  /// Returns an [Either] containing a [Failure] on error or a [List<Task>]
  /// on success.
  @override
  Future<Either<Failure, List<Task>>> getTasks({final TaskFilter? filter}) async {
    try {
      // Fetch all tasks from the local data source.
      final List<TaskModel> allTaskModels = await _localDataSource.getTasks();

      // Apply in-memory filtering based on the TaskFilter enum.
      List<TaskModel> filteredTaskModels;
      if (filter == TaskFilter.completed) {
        filteredTaskModels =
            allTaskModels.where((final TaskModel task) => task.isCompleted).toList();
      } else if (filter == TaskFilter.pending) {
        filteredTaskModels =
            allTaskModels.where((final TaskModel task) => !task.isCompleted).toList();
      } else {
        // If filter is TaskFilter.all or null, return all tasks without filtering.
        filteredTaskModels = allTaskModels;
      }

      // Convert the filtered list of TaskModels to a list of Task entities.
      final List<Task> tasks =
          filteredTaskModels.map((final TaskModel model) => model.toEntity()).toList();

      return Right<Failure, List<Task>>(tasks);
    } on FormatException catch (e) {
      // Catch parsing errors during data conversion (e.g., within TaskModel.fromMap),
      // indicating malformed data in storage.
      return Left<Failure, List<Task>>(
          CacheFailure(message: 'Data format error retrieving tasks: ${e.message}'));
    } on LocalDatabaseException catch (e) {
      // Map local database specific exceptions to a CacheFailure.
      return Left<Failure, List<Task>>(CacheFailure(message: e.message));
    } on Exception catch (e) {
      // Catch any other unexpected exceptions and return a generic CacheFailure.
      return Left<Failure, List<Task>>(
          CacheFailure(message: 'An unknown error occurred while getting tasks: $e'));
    }
  }

  /// Updates an existing task in the local data source.
  ///
  /// Converts the domain [Task] entity to a data layer [TaskModel],
  /// then delegates the operation to the [_localDataSource].
  /// Wraps potential data source errors into [NotFoundFailure] if the task
  /// to be updated does not exist, or [CacheFailure] for other storage-related issues.
  ///
  /// Returns an [Either] containing a [Failure] on error or the
  /// updated [Task] object on success.
  @override
  Future<Either<Failure, Task>> updateTask(final Task task) async {
    try {
      // Convert domain entity to data model.
      final TaskModel taskModel = TaskModel.fromEntity(task);
      // Delegate to local data source to update the task model.
      final TaskModel updatedTaskModel = await _localDataSource.updateTask(taskModel);
      // Convert the updated data model back to a domain entity and return it.
      return Right<Failure, Task>(updatedTaskModel.toEntity());
    } on TaskNotFoundException catch (e) {
      // Map specific not found exception to NotFoundFailure.
      return Left<Failure, Task>(NotFoundFailure(message: e.message));
    } on LocalDatabaseException catch (e) {
      // Map local database specific exceptions to a CacheFailure.
      return Left<Failure, Task>(CacheFailure(message: e.message));
    } on Exception catch (e) {
      // Catch any other unexpected exceptions and return a generic CacheFailure.
      return Left<Failure, Task>(
          CacheFailure(message: 'An unknown error occurred while updating task: $e'));
    }
  }
}