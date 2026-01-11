import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

/// Exception for remote database errors.
class RemoteDatabaseException implements Exception {
  final String message;
  final Object? originalError;

  const RemoteDatabaseException(this.message, {this.originalError});

  @override
  String toString() =>
      'RemoteDatabaseException: $message${originalError != null ? ' (Original error: $originalError)' : ''}';
}

/// Exception when a task is not found.
class RemoteTaskNotFoundException implements Exception {
  final String message;
  const RemoteTaskNotFoundException(this.message);

  @override
  String toString() => 'RemoteTaskNotFoundException: $message';
}

/// Abstract interface for remote task data operations.
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

/// Implementation of [TaskRemoteDataSource] using Supabase.
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final SupabaseClient _client;
  static const String _tableName = 'todos';

  TaskRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String? get _currentUserId {
    return _client.auth.currentUser?.id;
  }

  void _ensureAuthenticated() {
    if (_currentUserId == null) {
      throw const RemoteDatabaseException('User not authenticated');
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      _ensureAuthenticated();
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TaskModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RemoteDatabaseException(
        'Failed to fetch tasks: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is RemoteDatabaseException) rethrow;
      throw RemoteDatabaseException(
        'An unexpected error occurred while fetching tasks',
        originalError: e,
      );
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    try {
      _ensureAuthenticated();
      final response = await _client
          .from(_tableName)
          .insert(task.toSupabaseMap())
          .select()
          .single();

      return TaskModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw RemoteDatabaseException(
        'Failed to add task: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is RemoteDatabaseException) rethrow;
      throw RemoteDatabaseException(
        'An unexpected error occurred while adding task',
        originalError: e,
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      _ensureAuthenticated();
      final response = await _client
          .from(_tableName)
          .update(task.toSupabaseMap())
          .eq('id', task.id)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return TaskModel.fromMap(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw RemoteTaskNotFoundException('Task with ID ${task.id} not found');
      }
      throw RemoteDatabaseException(
        'Failed to update task: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is RemoteDatabaseException || e is RemoteTaskNotFoundException) {
        rethrow;
      }
      throw RemoteDatabaseException(
        'An unexpected error occurred while updating task',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      _ensureAuthenticated();
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId!);
    } on PostgrestException catch (e) {
      throw RemoteDatabaseException(
        'Failed to delete task: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is RemoteDatabaseException) rethrow;
      throw RemoteDatabaseException(
        'An unexpected error occurred while deleting task',
        originalError: e,
      );
    }
  }
}
