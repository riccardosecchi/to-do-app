import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:todo_app/features/tasks/data/models/task_model.dart';

/// Implementation of [TaskRepository] using Supabase as the data source.
class TaskRepositorySupabaseImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  const TaskRepositorySupabaseImpl({
    required TaskRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final addedTaskModel = await _remoteDataSource.addTask(taskModel);
      return Right(addedTaskModel.toEntity());
    } on RemoteDatabaseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      return const Right(null);
    } on RemoteTaskNotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on RemoteDatabaseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks({TaskFilter? filter}) async {
    try {
      final allTaskModels = await _remoteDataSource.getTasks();

      List<TaskModel> filteredTaskModels;
      if (filter == TaskFilter.completed) {
        filteredTaskModels = allTaskModels.where((task) => task.isCompleted).toList();
      } else if (filter == TaskFilter.pending) {
        filteredTaskModels = allTaskModels.where((task) => !task.isCompleted).toList();
      } else {
        filteredTaskModels = allTaskModels;
      }

      final tasks = filteredTaskModels.map((model) => model.toEntity()).toList();
      return Right(tasks);
    } on RemoteDatabaseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final updatedTaskModel = await _remoteDataSource.updateTask(taskModel);
      return Right(updatedTaskModel.toEntity());
    } on RemoteTaskNotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on RemoteDatabaseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
