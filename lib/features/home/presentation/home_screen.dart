import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/stat_card.dart';
import 'widgets/action_card.dart';
import 'widgets/animated_progress_ring.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/home/logic/home_stats_cubit.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../dashboard/logic/dashboard_cubit.dart';
import '../../activity_log/presentation/activity_log_list_screen.dart';
import '../../activity_goals/presentation/goals_screen.dart';
import '../../activity_log/logic/activity_log_cubit.dart';
import '../../activity_goals/logic/cubit/goals_cubit.dart';
import '../../activity_log/data/repos/activity_log_repository.dart';
import '../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../activity_log/data/repos/activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        390,
        844,
      ), // iPhone 12/13/14 Pro size for reference
      minTextAdapt: true,
      builder: (context, child) => BlocProvider(
        create: (_) {
          // Ensure data sync service is initialized
          try {
            getIt<DataSyncService>();
          } catch (e) {
            print('[HOME] Data sync service not initialized, setting up dependencies');
            setupDependencies();
          }
          return HomeStatsCubit()..fetchStats();
        },
        child: const _HomeScreenBody(),
      ),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();
  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeTab(scrollController: _scrollController),
      BlocProvider(
        create: (_) => DashboardCubit()..loadDashboard(),
        child: const DashboardScreen(),
      ),
      BlocProvider(
        create: (_) => ActivityLogListCubit(
          linkRepository: SQLiteActivityLogGoalLinkRepository(),
        )..loadActivities(),
        child: const ActivityLogListScreen(),
      ),
      BlocProvider(
        create: (_) => GoalsCubit(
          goalRepo: ActivityGoalRepository(),
          linkRepo: SQLiteActivityLogGoalLinkRepository(),
          activityLogRepo: ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository()),
        ),
        child: const GoalsScreen(),
      ),
    ];
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      if (_selectedIndex == 0) {
        // Double-tap Home: scroll to top
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      }
      setState(() => _selectedIndex = 0);
      await HapticFeedback.lightImpact();
    } else {
      setState(() => _selectedIndex = index);
      await HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 0,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Fitness Tracker'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.deepPurple, size: 28.sp),
                  ),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Semantics(
        label: 'Bottom navigation bar',
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          iconSize: 26.sp,
          items: [
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'Home',
                child: Container(
                  decoration: _selectedIndex == 0
                      ? BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                      : null,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(Icons.home, semanticLabel: 'Home'),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'Dashboard',
                child: Container(
                  decoration: _selectedIndex == 1
                      ? BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                      : null,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(Icons.dashboard, semanticLabel: 'Dashboard'),
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'Activity Log',
                child: Container(
                  decoration: _selectedIndex == 2
                      ? BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                      : null,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(Icons.list_alt, semanticLabel: 'Activity Log'),
                ),
              ),
              label: 'Activity Log',
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'Goals',
                child: Container(
                  decoration: _selectedIndex == 3
                      ? BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                      : null,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(Icons.flag, semanticLabel: 'Goals'),
                ),
              ),
              label: 'Goals',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ScrollController? scrollController;
  const _HomeTab({this.scrollController});

  void _showStatDetails(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label Details'),
        content: Text(
          'More trends and shortcuts for $label will be shown here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = 'Alex'; // TODO: Fetch from user profile if available
    final quote = 'Stay strong. One step at a time.';
    return BlocBuilder<HomeStatsCubit, HomeStatsState>(
      builder: (context, state) {
        bool isLoading = state is HomeStatsLoading;
        bool hasError = state is HomeStatsError;
        double calories = 0.0;
        double distance = 0.0;
        int activeGoals = 0;
        double progress = 0.0;
        if (state is HomeStatsLoaded) {
          calories = state.calories;
          distance = state.distance;
          activeGoals = state.activeGoals;
          progress = state.progress;
        }
        return Stack(
          children: [
            // Gradient header background
            Container(
              height: 260.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB993F4), Color(0xFF8CA6DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 24.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32.r,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                            size: 36.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, $userName!',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                quote,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Animated progress ring
                  Center(
                    child: AnimatedProgressRing(
                      progress: progress,
                      label: 'Goal Progress',
                      value: '${(progress * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Quick stats
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCard(
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          label: 'Calories',
                          value: calories,
                          isLoading: isLoading,
                          onTap: () => _showStatDetails(context, 'Calories'),
                          tooltip: 'Tap for calories trends',
                        ),
                        StatCard(
                          icon: Icons.directions_run,
                          color: Colors.blue,
                          label: 'Distance',
                          value: distance,
                          isLoading: isLoading,
                          onTap: () => _showStatDetails(context, 'Distance'),
                          tooltip: 'Tap for distance trends',
                        ),
                        StatCard(
                          icon: Icons.flag,
                          color: Colors.green,
                          label: 'Goals',
                          value: activeGoals,
                          isLoading: isLoading,
                          onTap: () => _showStatDetails(context, 'Goals'),
                          tooltip: 'Tap for goals summary',
                        ),
                      ],
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Text(
                        'Failed to load stats. Please try again.',
                        style: TextStyle(color: Colors.red, fontSize: 15.sp),
                      ),
                    ),
                  SizedBox(height: 32.h),
                  // Main actions as large cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        ActionCard(
                          icon: Icons.play_arrow,
                          color: Colors.deepPurple,
                          label: 'Start Activity',
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            // No navigation needed; Home is current screen.
                          },
                          tooltip: 'Start a new activity',
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Last Activity'),
                                content: const Text(
                                  'Show summary of last activity here.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          enabled: true,
                        ),
                        ActionCard(
                          icon: Icons.flag,
                          color: Colors.green,
                          label: 'View Goals',
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, Routes.goals);
                          },
                          tooltip: 'View and manage your goals',
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Goals Info'),
                                content: const Text(
                                  'Quick access to your goals summary.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          enabled: true,
                        ),
                        ActionCard(
                          icon: Icons.dashboard,
                          color: Colors.blue,
                          label: 'Dashboard',
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, Routes.dashboard);
                          },
                          tooltip: 'View analytics dashboard',
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Dashboard Info'),
                                content: const Text(
                                  'See your analytics and trends.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          enabled: true,
                        ),
                        ActionCard(
                          icon: Icons.history,
                          color: Colors.orange,
                          label: 'Activity Log',
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(
                              context,
                              Routes.activityLogList,
                            );
                          },
                          tooltip: 'View your activity log',
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Activity Log Info'),
                                content: const Text(
                                  'See all your past activities.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          enabled: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
