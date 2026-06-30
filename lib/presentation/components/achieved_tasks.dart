import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/l10n/app_localizations.dart';

class AchievedTasks extends StatelessWidget {
  final int allTasks;
  final int achievedTasks;

  const AchievedTasks({
    super.key,
    required this.allTasks,
    required this.achievedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final percent = allTasks == 0 ? 0.0 : achievedTasks / allTasks;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppW.w16, vertical: AppH.h12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppR.r20),
        color: colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.achievedTasksTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: AppSp.sp20, fontWeight: FontWeight.w400),
                ),
                Text(
                  l.achievedTasksCount(achievedTasks, allTasks),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: AppSp.sp14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: AppR.r35,
            lineWidth: 5.0,
            animation: true,
            animationDuration: 500,
            animateFromLastPercent: true,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            progressColor: colorScheme.primary,
            center: Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: AppSp.sp20, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
