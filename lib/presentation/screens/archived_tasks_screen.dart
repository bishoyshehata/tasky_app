import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/components/tasks_card.dart';

class ArchivedTasksScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const ArchivedTasksScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<ArchivedTasksScreen> createState() => _ArchivedTasksScreenState();
}

class _ArchivedTasksScreenState extends State<ArchivedTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.archivedTitle), elevation: 0),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: AppW.w12),
        child: _buildCards(context, l),
      ),
    );
  }

  Widget _buildCards(BuildContext context, AppLocalizations l) {
    final archived = widget.tasks.where((t) => t.isArchived).toList();

    if (archived.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: AppH.h12),
          Container(
            width: double.infinity,
            height: AppH.h250,
            alignment: Alignment.center,
            child: Lottie.asset('assets/lottie/archeived.json', fit: BoxFit.cover),
          ),
          Text(
            l.noArchivedTasks,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppSp.sp18,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppH.h12),
        // Info banner
        Container(
          padding: EdgeInsets.all(AppW.w12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppR.r10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: AppSp.sp20,
              ),
              SizedBox(width: AppW.w8),
              Expanded(
                child: Text(
                  l.archiveBanner,
                  style: TextStyle(
                    fontSize: AppSp.sp12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppH.h12),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: AppH.h65),
            itemCount: archived.length,
            itemBuilder: (_, i) => TaskCard(
              task: archived[i],
              index: i,
              isReadOnly: true,
              onChanged: () {},
              onEdit: () {},
              onDelete: () {},
            ),
            separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
          ),
        ),
        Container(
          width: double.infinity,
          height: AppH.h250,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: AppH.h40, bottom: AppH.h250),
          child: Lottie.asset('assets/lottie/archeived.json', fit: BoxFit.cover),
        ),
      ],
    );
  }
}
