import 'package:flutter/foundation.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task_status.dart';
import '../../domain/usecases/delete_task.dart';

/// Provider for managing task state in the presentation layer.
class TaskProvider extends ChangeNotifier {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final UpdateTaskStatus _updateTaskStatus;
  final DeleteTask _deleteTask;

  TaskProvider({
    required GetTasks getTasks,
    required AddTask addTask,
    required UpdateTaskStatus updateTaskStatus,
    required DeleteTask deleteTask,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _updateTaskStatus = updateTaskStatus,
        _deleteTask = deleteTask;

  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Task> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns tasks filtered by current filter
  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  /// Load all tasks from repository
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getTasks(GetTasksParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (tasks) {
        _tasks = tasks;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new task
  Future<void> addTask(String userId, String title, String? description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _addTask(AddTaskParams(
      userId: userId,
      title: title,
      description: description,
    ));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (task) {
        _tasks.add(task);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle task completion status
  Future<void> toggleTaskStatus(Task task) async {
    final result = await _updateTaskStatus(UpdateTaskStatusParams(task: task));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (updatedTask) {
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      },
    );

    notifyListeners();
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final result = await _deleteTask(DeleteTaskParams(taskId: taskId));

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _tasks.removeWhere((task) => task.id == taskId);
      },
    );

    notifyListeners();
  }

  /// Update current filter
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
