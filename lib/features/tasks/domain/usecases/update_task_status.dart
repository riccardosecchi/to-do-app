import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/usecases/usecase.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

/// Represents the parameters required for the [UpdateTaskStatus] use case.
///
/// This immutable class encapsulates the [Task] entity whose completion status
/// needs to be toggled. It uses a const constructor for efficiency and
/// adheres to immutability best practices.
class UpdateTaskStatusParams {
  /// The [Task] entity that needs its completion status updated.
  final Task task;

  /// Creates an instance of [UpdateTaskStatusParams].
  ///
  /// The [task] parameter is required and represents the specific task
  /// to be acted upon by the use case.
  const UpdateTaskStatusParams({
    required this.task,
  });

  /// Compares this [UpdateTaskStatusParams] instance with another object for equality.
  ///
  /// Returns `true` if the other object is also an [UpdateTaskStatusParams]
  /// and its `task` field is equal to this instance's `task` field.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateTaskStatusParams && other.task == task;
  }

  /// Returns a hash code for this [UpdateTaskStatusParams] instance.
  ///
  /// The hash code is based on the `task` field.
  @override
  int get hashCode => task.hashCode;

  /// Returns a string representation of this [UpdateTaskStatusParams] instance.
  @override
  String toString() => 'UpdateTaskStatusParams(task: $task)';
}

/// A use case for toggling the completion status of a specific task.
///
/// This use case encapsulates the business logic for updating a task's
/// `isCompleted` status. It interacts with the [TaskRepository] to persist
/// the changes and returns the updated [Task] entity upon success or a
/// [Failure] upon error.
///
/// It extends [UseCase<Task, UpdateTaskStatusParams>], indicating that it
/// returns a [Task] on success and takes [UpdateTaskStatusParams] as input.
class UpdateTaskStatus implements UseCase<Task, UpdateTaskStatusParams> {
  /// The repository interface used to interact with task data.
  final TaskRepository _repository;

  /// Creates an instance of [UpdateTaskStatus].
  ///
  /// Requires a [TaskRepository] to be injected, allowing the use case
  /// to perform operations on tasks.
  const UpdateTaskStatus({
    required TaskRepository repository,
  }) : _repository = repository;

  /// Executes the use case to toggle a task's completion status.
  ///
  /// Takes [UpdateTaskStatusParams] which contains the [Task] to be updated.
  /// It first creates a new [Task] object with the `isCompleted` status
  /// toggled, and then calls the repository to update this modified task.
  ///
  /// Returns a [Future] that resolves to an [Either] type:
  /// - A [Failure] on the left side if the operation fails.
  /// - The updated [Task] entity on the right side if the operation succeeds.
  @override
  Future<Either<Failure, Task>> call(UpdateTaskStatusParams params) async {
    // Create a new Task object with the toggled completion status.
    // This adheres to immutability principles by creating a new instance
    // rather than modifying the original.
    final Task updatedTask =
        params.task.copyWith(isCompleted: !params.task.isCompleted);

    // Call the repository to update the task in the data source.
    // The repository handles the actual persistence logic and error reporting.
    return _repository.updateTask(updatedTask);
  }
}