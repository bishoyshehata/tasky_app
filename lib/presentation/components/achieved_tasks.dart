import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
    final percent = allTasks == 0 ? 0.0 : achievedTasks / allTasks;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achieved Tasks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                Text(
                  '$achievedTasks Out of $allTasks Done',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 35.0,
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
