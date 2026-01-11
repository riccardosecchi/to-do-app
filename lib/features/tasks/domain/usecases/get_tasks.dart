/// todo_app/lib/features/tasks/domain/usecases/get_tasks.dart
import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/usecases/usecase.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart'; // Assuming Task entity exists
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

/// Represents the parameters required for the [GetTasks] use case.
///
/// This immutable data class encapsulates an optional [filter] to specify
/// which tasks to retrieve (all, completed, or pending).
///
/// It uses a const constructor to ensure immutability and allow for compile-time
/// constant instances, adhering to Flutter's best practices.
class GetTasksParams {
  /// An optional filter to apply when retrieving tasks.
  ///
  /// If null, the repository implementation typically defaults to retrieving
  /// all tasks, but its specific behavior is defined by the [TaskRepository].
  final TaskFilter? filter;

  /// Creates a [GetTasksParams] instance.
  ///
  /// The [filter] parameter is optional and defaults to `null`.
  const GetTasksParams({this.filter});

  /// Overrides the equality operator to compare [GetTasksParams] instances.
  ///
  /// Two [GetTasksParams] instances are considered equal if their [filter]
  /// properties are identical.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetTasksParams && other.filter == filter;
  }

  /// Returns a hash code for this [GetTasksParams] instance.
  ///
  /// The hash code is based on the [filter] property to ensure consistency
  /// with the equality operator.
  @override
  int get hashCode => filter.hashCode;

  /// Returns a string representation of this [GetTasksParams] instance.
  @override
  String toString() => 'GetTasksParams(filter: $filter)';
}

/// A use case for retrieving a list of tasks from the repository.
///
/// This use case extends [UseCase] and defines the contract for fetching
/// tasks. It depends on [TaskRepository] to perform the actual data retrieval.
///
/// It can optionally filter tasks based on a [TaskFilter] provided in [GetTasksParams].
class GetTasks implements UseCase<List<Task>, GetTasksParams> {
  /// The repository responsible for task data operations.
  final TaskRepository repository;

  /// Creates a [GetTasks] use case instance.
  ///
  /// Requires a [repository] to interact with the task data layer.
  /// The constructor is `const` because the `repository` is `final`,
  /// making the use case instance immutable if its dependencies are also immutable.
  const GetTasks({
    required this.repository,
  });

  /// Executes the use case to retrieve tasks.
  ///
  /// Calls the [TaskRepository.getTasks] method, passing the optional
  /// [filter] from the [params].
  ///
  /// Returns a [Future] that resolves to an [Either] type:
  /// - A [Failure] on the left side if an error occurs during retrieval.
  /// - A [List<Task>] on the right side if the tasks are successfully retrieved.
  @override
  Future<Either<Failure, List<Task>>> call(GetTasksParams params) async {
    return await repository.getTasks(filter: params.filter);
  }
}