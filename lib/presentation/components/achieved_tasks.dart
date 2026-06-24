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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xff282828),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Achieved Tasks',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xffFFFCFC),
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

                Text(
                  '$achievedTasks Out of $allTasks Done',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xffC6C6C6),
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
            percent: achievedTasks / allTasks,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Color(0xffA0A0A0),
            progressColor: Color(0xff15B86C),
            center: Text(
              '${(achievedTasks / allTasks * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Color(0xffFFFCFC),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
