import 'package:flutter/material.dart';

import '../../domain/repositories/task_repository.dart';

/// Widget for filtering tasks by status.
class TaskFilterOptions extends StatelessWidget {
  final TaskFilter currentFilter;
  final Function(TaskFilter) onFilterChanged;

  const TaskFilterOptions({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            filter: TaskFilter.all,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Pending',
            filter: TaskFilter.pending,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Completed',
            filter: TaskFilter.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
  }) {
    final isSelected = currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
