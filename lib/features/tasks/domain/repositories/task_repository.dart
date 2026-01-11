import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/core/error/failures.dart';

/// Defines the possible filtering options for retrieving tasks.
///
/// This enum is used by the [TaskRepository] to allow callers to specify
/// whether they want all tasks, only completed tasks, or only pending tasks.
enum TaskFilter {
  /// Represents all tasks, regardless of their completion status.
  all,

  /// Represents tasks that have been marked as completed.
  completed,

  /// Represents tasks that are still pending (not completed).
  pending,
}

/// An abstract interface for managing task data within the domain layer.
///
/// This repository acts as a contract that defines the operations
/// available for interacting with task data. It abstracts away the
/// underlying data source implementation details (e.g., local database,
/// remote API, in-memory storage) from the rest of the domain and
/// presentation layers.
///
/// All methods return a [Future<Either<Failure, T>>] to handle potential
/// operational failures gracefully and provide either a [Failure] object
/// or the expected successful data [T].
abstract class TaskRepository {
  /// Retrieves a list of tasks, with an optional filter.
  ///
  /// If [filter] is provided, tasks will be returned based on the specified
  /// completion status (all, completed, or pending). If [filter] is null,
  /// it typically defaults to returning all tasks, but the concrete
  /// implementation can define its specific default behavior.
  ///
  /// Returns an [Either] containing a [Failure] on error or a [List<Task>]
  /// on success.
  Future<Either<Failure, List<Task>>> getTasks({TaskFilter? filter});

  /// Adds a new task to the repository.
  ///
  /// The provided [task] object represents the new task to be created.
  /// The implementation is responsible for persisting this task and
  /// potentially generating an ID if not already present, or updating
  /// the provided task with a generated ID if necessary.
  ///
  /// Returns an [Either] containing a [Failure] on error or the
  /// newly added [Task] object (potentially with an updated ID) on success.
  Future<Either<Failure, Task>> addTask(Task task);

  /// Updates an existing task in the repository.
  ///
  /// The provided [task] object should contain the updated information
  /// for an existing task, which is identified by its unique `id` property.
  /// The implementation should locate the task by its ID and apply the
  /// updates.
  ///
  /// Returns an [Either] containing a [Failure] on error or the
  /// updated [Task] object on success.
  Future<Either<Failure, Task>> updateTask(Task task);

  /// Deletes a task from the repository based on its unique identifier.
  ///
  /// The [id] parameter specifies the unique identifier of the task to be deleted.
  /// If a task with the given ID does not exist, the implementation might
  /// return a specific failure (e.g., [NotFoundFailure]).
  ///
  /// Returns an [Either] containing a [Failure] on error or [void] on
  /// successful deletion. The `void` type signifies that no data is returned
  /// upon success, only the completion of the operation.
  Future<Either<Failure, void>> deleteTask(String id);
}