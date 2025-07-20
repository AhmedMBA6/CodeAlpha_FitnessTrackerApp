part of 'home_stats_cubit.dart';

abstract class HomeStatsState extends Equatable {
  const HomeStatsState();
  @override
  List<Object?> get props => [];
}

class HomeStatsLoading extends HomeStatsState {}

class HomeStatsLoaded extends HomeStatsState {
  final double calories;
  final double distance;
  final int activeGoals;
  final double progress;

  const HomeStatsLoaded({
    required this.calories,
    required this.distance,
    required this.activeGoals,
    required this.progress,
  });

  @override
  List<Object?> get props => [calories, distance, activeGoals, progress];
}

class HomeStatsError extends HomeStatsState {
  final String message;
  const HomeStatsError(this.message);

  @override
  List<Object?> get props => [message];
} 