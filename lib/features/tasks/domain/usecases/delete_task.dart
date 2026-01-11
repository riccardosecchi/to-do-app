/// `/Users/riccardo/Desktop/dirProva/todo_app/lib/features/tasks/domain/usecases/delete_task.dart`
///
/// This file defines the `DeleteTask` use case and its associated parameters.
/// It encapsulates the business logic for deleting a task from the system.

import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/usecases/usecase.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

/// Represents the parameters required to delete a task.
///
/// This immutable data class holds the unique identifier of the task
/// that needs to be deleted. It uses a const constructor and final fields
/// to ensure immutability and allow for compile-time constant instances.
class DeleteTaskParams {
  /// The unique identifier of the task to be deleted.
  final String taskId;

  /// Creates a [DeleteTaskParams] instance.
  ///
  /// The [taskId] is a required parameter, ensuring that a task ID is
  /// always provided when attempting to delete a task.
  const DeleteTaskParams({
    required this.taskId,
  });

  /// Creates a copy of this [DeleteTaskParams] instance with optional new values.
  ///
  /// This method is useful for making minor modifications to an existing
  /// parameter object without directly mutating it, promoting immutability.
  /// If no new [taskId] is provided, the existing one is used.
  DeleteTaskParams copyWith({
    String? taskId,
  }) {
    return DeleteTaskParams(
      taskId: taskId ?? this.taskId,
    );
  }

  /// Compares this [DeleteTaskParams] object with another for equality.
  ///
  /// Two [DeleteTaskParams] objects are considered equal if their [taskId]
  /// properties are identical.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeleteTaskParams && other.taskId == taskId;
  }

  /// Returns a hash code for this [DeleteTaskParams] instance.
  ///
  /// The hash code is generated based on the [taskId] property, ensuring
  /// consistency with the equality operator.
  @override
  int get hashCode => taskId.hashCode;

  /// Returns a string representation of this [DeleteTaskParams] instance.
  ///
  /// Useful for debugging and logging purposes, showing the contained task ID.
  @override
  String toString() => 'DeleteTaskParams(taskId: $taskId)';
}

/// A use case for deleting an existing task.
///
/// This use case orchestrates the deletion of a task by interacting with
/// the [TaskRepository]. It adheres to the Clean Architecture's principle
/// of separating business logic from data access and UI concerns.
///
/// It extends [UseCase] with a return type of `void` (indicating no data
/// is returned on success) and [DeleteTaskParams] as its input parameters.
class DeleteTask implements UseCase<void, DeleteTaskParams> {
  /// The repository responsible for task data operations.
  final TaskRepository _repository;

  /// Creates a [DeleteTask] use case instance.
  ///
  /// Takes a [TaskRepository] as a required dependency, which allows
  /// the use case to interact with the underlying data layer.
  const DeleteTask({
    required TaskRepository repository,
  }) : _repository = repository;

  /// Executes the delete task operation.
  ///
  /// Takes [params] which encapsulate the `taskId` of the task to be deleted.
  /// It calls the `deleteTask` method on the injected [TaskRepository].
  ///
  /// Returns a [Future] that resolves to an [Either] type:
  /// - A [Failure] on the left side if an error occurs during deletion (e.g.,
  ///   network issues, task not found).
  /// - `void` on the right side if the task is successfully deleted,
  ///   signifying the completion of the operation without returning any data.
  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return _repository.deleteTask(params.taskId);
  }
}