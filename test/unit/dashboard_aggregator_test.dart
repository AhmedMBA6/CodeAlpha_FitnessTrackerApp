import 'package:flutter_test/flutter_test.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_model.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_goals/data/models/activity_goal.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/models/activity_log_goal_link.dart';

void main() {
  group('DashboardAggregator Tests', () {
    test('should calculate today summary correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: today,
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Walking',
          duration: 20,
          calories: 80.0,
          date: today.subtract(const Duration(days: 1)),
        ),
      ];

      final summary = DashboardAggregator.getTodaySummary(logs);

      expect(summary.totalCalories, equals(350.0));
      expect(summary.totalDuration, equals(75));
      expect(summary.date, equals(today));
    });

    test('should calculate weekly summary correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: today,
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: today.subtract(const Duration(days: 1)),
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Walking',
          duration: 20,
          calories: 80.0,
          date: today.subtract(const Duration(days: 2)),
        ),
      ];

      final weeklySummaries = DashboardAggregator.getWeeklySummary(logs);

      expect(weeklySummaries.length, equals(7));
      expect(weeklySummaries[0].totalCalories, equals(150.0));
      expect(weeklySummaries[1].totalCalories, equals(200.0));
      expect(weeklySummaries[2].totalCalories, equals(80.0));
    });

    test('should calculate metrics correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '3',
          activityType: 'Running',
          duration: 25,
          calories: 125.0,
          date: DateTime.now(),
        ),
      ];

      final metrics = DashboardAggregator.getMetrics(logs);

      expect(metrics.totalCalories, equals(475.0));
      expect(metrics.totalDuration, equals(100));
      expect(metrics.totalActivities, equals(3));
      expect(metrics.averageDuration, equals(33.33));
      expect(metrics.averageCaloriesPerActivity, equals(158.33));
      expect(metrics.activityTypeBreakdown['Running'], equals(2));
      expect(metrics.activityTypeBreakdown['Cycling'], equals(1));
    });

    test('should handle empty logs gracefully', () {
      final logs = <ActivityLogModel>[];

      final summary = DashboardAggregator.getTodaySummary(logs);
      final weeklySummaries = DashboardAggregator.getWeeklySummary(logs);
      final metrics = DashboardAggregator.getMetrics(logs);

      expect(summary.totalCalories, equals(0.0));
      expect(summary.totalDuration, equals(0));
      expect(weeklySummaries.length, equals(7));
      expect(metrics.totalCalories, equals(0.0));
      expect(metrics.totalActivities, equals(0));
    });

    test('should aggregate with join model correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cycling',
          duration: 45,
          calories: 200.0,
          date: DateTime.now(),
        ),
      ];

      final goals = [
        ActivityGoal(
          id: 'goal1',
          goalType: GoalType.quantitative,
          description: 'Run 5km',
          targetValue: 5.0,
          unit: 'km',
          createdAt: DateTime.now(),
        ),
        ActivityGoal(
          id: 'goal2',
          goalType: GoalType.quantitative,
          description: 'Burn 500 calories',
          targetValue: 500.0,
          unit: 'calories',
          createdAt: DateTime.now(),
        ),
      ];

      final links = [
        ActivityLogGoalLink(
          id: 'link1',
          activityLogId: '1',
          goalId: 'goal1',
          contributedValue: 3.0,
          contributionType: 'km',
          linkedAt: DateTime.now(),
        ),
        ActivityLogGoalLink(
          id: 'link2',
          activityLogId: '2',
          goalId: 'goal2',
          contributedValue: 200.0,
          contributionType: 'calories',
          linkedAt: DateTime.now(),
        ),
      ];

      final result = DashboardAggregator.aggregateWithJoinModel(
        logs: logs,
        goals: goals,
        links: links,
      );

      expect(result['totalGoals'], equals(2));
      expect(result['completedGoals'], equals(0));
      expect(result['pendingGoals'], equals(2));
      expect(result['topGoals'], isA<List>());
      expect((result['topGoals'] as List).length, equals(2));
    });

    test('should calculate goal progress correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 250.0,
          distance: 3.0,
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Running',
          duration: 25,
          calories: 200.0,
          distance: 2.5,
          date: DateTime.now(),
        ),
      ];

      final goals = [
        ActivityGoal(
          id: 'goal1',
          goalType: GoalType.quantitative,
          description: 'Run 5km',
          targetValue: 5.0,
          unit: 'km',
          createdAt: DateTime.now(),
        ),
        ActivityGoal(
          id: 'goal2',
          goalType: GoalType.quantitative,
          description: 'Burn 500 calories',
          targetValue: 500.0,
          unit: 'calories',
          createdAt: DateTime.now(),
        ),
      ];

      final links = [
        ActivityLogGoalLink(
          id: 'link1',
          activityLogId: '1',
          goalId: 'goal1',
          contributedValue: 3.0,
          contributionType: 'km',
          linkedAt: DateTime.now(),
        ),
        ActivityLogGoalLink(
          id: 'link2',
          activityLogId: '2',
          goalId: 'goal1',
          contributedValue: 2.5,
          contributionType: 'km',
          linkedAt: DateTime.now(),
        ),
        ActivityLogGoalLink(
          id: 'link3',
          activityLogId: '1',
          goalId: 'goal2',
          contributedValue: 250.0,
          contributionType: 'calories',
          linkedAt: DateTime.now(),
        ),
      ];

      final result = DashboardAggregator.aggregateWithJoinModel(
        logs: logs,
        goals: goals,
        links: links,
      );

      final topGoals = result['topGoals'] as List;
      final goal1Data = topGoals.firstWhere((g) => (g['goal'] as ActivityGoal).id == 'goal1');
      final goal2Data = topGoals.firstWhere((g) => (g['goal'] as ActivityGoal).id == 'goal2');

      // Goal 1: 5.5km / 5.0km = 110% progress (capped at 100%)
      expect(goal1Data['goalProgress'], equals(1.0));
      // Goal 2: 250 calories / 500 calories = 50% progress
      expect(goal2Data['goalProgress'], equals(0.5));
    });

    test('should handle goals without linked activities', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 150.0,
          date: DateTime.now(),
        ),
      ];

      final goals = [
        ActivityGoal(
          id: 'goal1',
          goalType: GoalType.quantitative,
          description: 'Run 5km',
          targetValue: 5.0,
          unit: 'km',
          createdAt: DateTime.now(),
        ),
        ActivityGoal(
          id: 'goal2',
          goalType: GoalType.quantitative,
          description: 'Burn 500 calories',
          targetValue: 500.0,
          unit: 'calories',
          createdAt: DateTime.now(),
        ),
      ];

      final links = <ActivityLogGoalLink>[]; // No links

      final result = DashboardAggregator.aggregateWithJoinModel(
        logs: logs,
        goals: goals,
        links: links,
      );

      expect(result['totalGoals'], equals(2));
      expect(result['completedGoals'], equals(0));
      expect(result['pendingGoals'], equals(2));
      
      final topGoals = result['topGoals'] as List;
      expect(topGoals.length, equals(2));
      
      // Both goals should have 0 progress
      for (final goalData in topGoals) {
        expect(goalData['goalProgress'], equals(0.0));
        expect((goalData['linkedLogs'] as List).isEmpty, isTrue);
      }
    });

    test('should handle qualitative goals correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Strength Training',
          duration: 45,
          calories: 200.0,
          tags: ['chest', 'triceps'],
          date: DateTime.now(),
        ),
        ActivityLogModel(
          id: '2',
          activityType: 'Cardio',
          duration: 30,
          calories: 150.0,
          tags: ['cardio'],
          date: DateTime.now(),
        ),
      ];

      final goals = [
        ActivityGoal(
          id: 'goal1',
          goalType: GoalType.qualitative,
          description: 'Train chest muscles',
          tags: ['chest'],
          createdAt: DateTime.now(),
        ),
        ActivityGoal(
          id: 'goal2',
          goalType: GoalType.qualitative,
          description: 'Do cardio workouts',
          tags: ['cardio'],
          createdAt: DateTime.now(),
        ),
      ];

      final links = [
        ActivityLogGoalLink(
          id: 'link1',
          activityLogId: '1',
          goalId: 'goal1',
          contributedValue: 1.0,
          contributionType: 'hours',
          linkedAt: DateTime.now(),
        ),
        ActivityLogGoalLink(
          id: 'link2',
          activityLogId: '2',
          goalId: 'goal2',
          contributedValue: 1.0,
          contributionType: 'hours',
          linkedAt: DateTime.now(),
        ),
      ];

      final result = DashboardAggregator.aggregateWithJoinModel(
        logs: logs,
        goals: goals,
        links: links,
      );

      final topGoals = result['topGoals'] as List;
      expect(topGoals.length, equals(2));
      
      // Both qualitative goals should be considered completed (progress = 1.0)
      for (final goalData in topGoals) {
        expect(goalData['goalProgress'], equals(1.0));
      }
    });

    test('should handle mixed goal types correctly', () {
      final logs = [
        ActivityLogModel(
          id: '1',
          activityType: 'Running',
          duration: 30,
          calories: 300.0,
          distance: 4.0,
          tags: ['cardio'],
          date: DateTime.now(),
        ),
      ];

      final goals = [
        ActivityGoal(
          id: 'goal1',
          goalType: GoalType.quantitative,
          description: 'Run 5km',
          targetValue: 5.0,
          unit: 'km',
          createdAt: DateTime.now(),
        ),
        ActivityGoal(
          id: 'goal2',
          goalType: GoalType.qualitative,
          description: 'Do cardio',
          tags: ['cardio'],
          createdAt: DateTime.now(),
        ),
      ];

      final links = [
        ActivityLogGoalLink(
          id: 'link1',
          activityLogId: '1',
          goalId: 'goal1',
          contributedValue: 4.0,
          contributionType: 'km',
          linkedAt: DateTime.now(),
        ),
        ActivityLogGoalLink(
          id: 'link2',
          activityLogId: '1',
          goalId: 'goal2',
          contributedValue: 1.0,
          contributionType: 'hours',
          linkedAt: DateTime.now(),
        ),
      ];

      final result = DashboardAggregator.aggregateWithJoinModel(
        logs: logs,
        goals: goals,
        links: links,
      );

      final topGoals = result['topGoals'] as List;
      expect(topGoals.length, equals(2));
      
      final quantitativeGoal = topGoals.firstWhere((g) => (g['goal'] as ActivityGoal).goalType == GoalType.quantitative);
      final qualitativeGoal = topGoals.firstWhere((g) => (g['goal'] as ActivityGoal).goalType == GoalType.qualitative);
      
      // Quantitative: 4.0km / 5.0km = 80% progress
      expect(quantitativeGoal['goalProgress'], equals(0.8));
      // Qualitative: completed = 100% progress
      expect(qualitativeGoal['goalProgress'], equals(1.0));
    });
  });
} 