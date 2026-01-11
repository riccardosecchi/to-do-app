import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_list_item.dart';
import '../widgets/task_filter_options.dart';
import 'add_task_screen.dart';

/// Home screen displaying the list of tasks.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when the screen is first shown, after ensuring auth is ready
    _loadTasksWhenReady();
  }

  Future<void> _loadTasksWhenReady() async {
    // Small delay to ensure Supabase auth state is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && authProvider.user != null) {
        context.read<TaskProvider>().loadTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthProvider>().signOut();
              }
            },
            itemBuilder: (context) {
              final user = context.read<AuthProvider>().user;
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    user?.email ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadTasks();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TaskFilterOptions(
                currentFilter: provider.currentFilter,
                onFilterChanged: provider.setFilter,
              ),
              Expanded(
                child: provider.filteredTasks.isEmpty
                    ? _buildEmptyState(provider)
                    : ListView.builder(
                        itemCount: provider.filteredTasks.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final task = provider.filteredTasks[index];
                          return TaskListItem(
                            task: task,
                            onToggle: () => provider.toggleTaskStatus(task),
                            onDelete: () => provider.deleteTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(TaskProvider provider) {
    String message;
    switch (provider.currentFilter) {
      case _:
        message = provider.tasks.isEmpty
            ? 'No tasks yet.\nTap + to add one!'
            : 'No tasks in this category.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTaskScreen(),
      ),
    );
  }
}
