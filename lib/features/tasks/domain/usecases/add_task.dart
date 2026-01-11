import 'package:dartz/dartz.dart' hide Task;
import 'package:uuid/uuid.dart';

import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/usecases/usecase.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

/// Parameters for the [AddTask] use case.
class AddTaskParams {
  final String userId;
  final String title;
  final String? description;

  const AddTaskParams({
    required this.userId,
    required this.title,
    this.description,
  });
}

/// A use case for adding a new task to the system.
class AddTask implements UseCase<Task, AddTaskParams> {
  final TaskRepository _repository;
  final Uuid _uuid;

  const AddTask({
    required TaskRepository repository,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, Task>> call(AddTaskParams params) async {
    final String taskId = _uuid.v4();
    final DateTime now = DateTime.now();

    final Task newTask = Task(
      id: taskId,
      userId: params.userId,
      title: params.title,
      description: params.description,
      isCompleted: false,
      createdAt: now,
    );

    return _repository.addTask(newTask);
  }
}
