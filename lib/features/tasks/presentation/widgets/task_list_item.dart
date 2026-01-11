import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

/// Widget for displaying a single task item.
class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: task.description != null && task.description!.isNotEmpty
              ? Text(
                  task.description!,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            color: Colors.red[300],
          ),
        ),
      ),
    );
  }
}
