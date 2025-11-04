import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Task list screen dengan filter status (All, Pending, Overdue, Completed)
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late List<TaskModel> tasks;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    tasks = TaskModel.getDummyTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myTasks),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(filteredTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔹 Filter Chips Section
  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Overdue', 'Completed'];

    Color _getChipColor(String filter) {
      switch (filter) {
        case 'Pending':
          return AppColors.statusPending;
        case 'Overdue':
          return AppColors.statusOverdue;
        case 'Completed':
          return AppColors.statusCompleted;
        default:
          // Warna netral yang tetap terlihat (misalnya abu-abu lembut)
          return Colors.grey;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final bool isSelected = _selectedFilter == filter;
            final Color chipColor = _getChipColor(filter);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                showCheckmark: false,
                backgroundColor: chipColor.withOpacity(filter == 'All' ? 0.2 : 0.15),
                selectedColor: chipColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (filter == 'All'
                          ? Colors.black87
                          : chipColor),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                side: BorderSide(
                  color: chipColor.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 🔹 Filter Logic
  List<TaskModel> _getFilteredTasks() {
    switch (_selectedFilter) {
      case 'Pending':
        return tasks.where((t) => t.status == TaskStatus.pending).toList();
      case 'Overdue':
        return tasks.where((t) => t.status == TaskStatus.overdue).toList();
      case 'Completed':
        return tasks.where((t) => t.status == TaskStatus.completed).toList();
      default:
        return tasks;
    }
  }

  /// 🔹 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noTasks,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Task List
  Widget _buildTaskList(List<TaskModel> filteredTasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildDismissibleTaskCard(task);
      },
    );
  }

  Widget _buildDismissibleTaskCard(TaskModel task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmation(task),
      onDismissed: (direction) => _deleteTask(task),
      child: InkWell(
        onTap: () => _navigateToDetail(task),
        borderRadius: BorderRadius.circular(12),
        child: TaskCard(task: task),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }

  Future<bool?> _showDeleteConfirmation(TaskModel task) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _deleteTask(TaskModel task) {
    setState(() {
      tasks.remove(task);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.taskDeleted),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(TaskModel task) {
    Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task);
  }

  void _navigateToAddTask() {
    Navigator.pushNamed(context, AppRoutes.addTask);
  }
}
