import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/logic/cubit/route_tracking_cubit.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/logic/cubit/route_tracking_state.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/repositories/route_tracking_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/models/route_track.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/models/route_point.dart';

import 'route_tracking_cubit_test.mocks.dart';

@GenerateMocks([RouteTrackingRepository])
void main() {
  group('RouteTrackingCubit', () {
    late RouteTrackingCubit cubit;
    late MockRouteTrackingRepository mockRepository;

    setUp(() {
      mockRepository = MockRouteTrackingRepository();
      cubit = RouteTrackingCubit(repository: mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const RouteTrackingState.initial());
    });

    group('loadRoutes', () {
      final testRoutes = [
        RouteTrack(
          id: '1',
          name: 'Test Route 1',
          startTime: DateTime.now(),
          points: [],
          totalDistance: 1000.0,
          totalDuration: const Duration(minutes: 10),
          averageSpeed: 1.67,
          maxSpeed: 3.0,
          activityType: 'Running',
        ),
        RouteTrack(
          id: '2',
          name: 'Test Route 2',
          startTime: DateTime.now(),
          points: [],
          totalDistance: 2000.0,
          totalDuration: const Duration(minutes: 20),
          averageSpeed: 1.67,
          maxSpeed: 4.0,
          activityType: 'Walking',
        ),
      ];

      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits [loading, success] when loadRoutes succeeds',
        build: () {
          when(mockRepository.getAllRoutes()).thenAnswer((_) async => testRoutes);
          return cubit;
        },
        act: (cubit) => cubit.loadRoutes(),
        expect: () => [
          const RouteTrackingState(status: RouteTrackingStatus.loading, routes: []),
          RouteTrackingState(
            status: RouteTrackingStatus.success,
            routes: testRoutes,
          ),
        ],
      );

      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits [loading, failure] when loadRoutes fails',
        build: () {
          when(mockRepository.getAllRoutes()).thenThrow(Exception('Database error'));
          return cubit;
        },
        act: (cubit) => cubit.loadRoutes(),
        expect: () => [
          const RouteTrackingState(status: RouteTrackingStatus.loading, routes: []),
          const RouteTrackingState(
            status: RouteTrackingStatus.failure,
            routes: [],
            errorMessage: 'Failed to load routes: Exception: Database error',
          ),
        ],
      );
    });

    group('startTracking', () {
      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits [tracking] when startTracking succeeds',
        build: () {
          when(mockRepository.saveActiveRoute(any)).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.startTracking(
          name: 'Test Route',
          activityType: 'Running',
        ),
        expect: () => [
          isA<RouteTrackingState>().having(
            (state) => state.status,
            'status',
            RouteTrackingStatus.tracking,
          ).having(
            (state) => state.activeRoute?.name,
            'route name',
            'Test Route',
          ).having(
            (state) => state.activeRoute?.activityType,
            'activity type',
            'Running',
          ),
        ],
        verify: (_) {
          verify(mockRepository.saveActiveRoute(any)).called(1);
        },
      );
    });

    group('stopTracking', () {
      final activeRoute = RouteTrack(
        id: '1',
        name: 'Test Route',
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        points: [
          RoutePoint(
            latitude: 0.0,
            longitude: 0.0,
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
          RoutePoint(
            latitude: 0.001,
            longitude: 0.001,
            timestamp: DateTime.now(),
          ),
        ],
        totalDistance: 0.0,
        totalDuration: Duration.zero,
        averageSpeed: 0.0,
        maxSpeed: 0.0,
        activityType: 'Running',
      );

      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits [success] when stopTracking succeeds',
        build: () {
          when(mockRepository.saveRoute(any)).thenAnswer((_) async {});
          when(mockRepository.saveActiveRoute(null)).thenAnswer((_) async {});
          when(mockRepository.getAllRoutes()).thenAnswer((_) async => [activeRoute]);
          return cubit;
        },
        seed: () => RouteTrackingState(
          status: RouteTrackingStatus.tracking,
          routes: [],
          activeRoute: activeRoute,
        ),
        act: (cubit) => cubit.stopTracking(),
        expect: () => [
          isA<RouteTrackingState>().having(
            (state) => state.status,
            'status',
            RouteTrackingStatus.success,
          ).having(
            (state) => state.activeRoute,
            'active route',
            null,
          ),
        ],
        verify: (_) {
          verify(mockRepository.saveRoute(any)).called(1);
          verify(mockRepository.saveActiveRoute(null)).called(1);
          verify(mockRepository.getAllRoutes()).called(1);
        },
      );
    });

    group('deleteRoute', () {
      final testRoutes = [
        RouteTrack(
          id: '1',
          name: 'Test Route 1',
          startTime: DateTime.now(),
          points: [],
          totalDistance: 1000.0,
          totalDuration: const Duration(minutes: 10),
          averageSpeed: 1.67,
          maxSpeed: 3.0,
          activityType: 'Running',
        ),
      ];

      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits updated routes when deleteRoute succeeds',
        build: () {
          when(mockRepository.deleteRoute('1')).thenAnswer((_) async {});
          when(mockRepository.getAllRoutes()).thenAnswer((_) async => testRoutes);
          return cubit;
        },
        seed: () => RouteTrackingState(
          status: RouteTrackingStatus.success,
          routes: testRoutes,
        ),
        act: (cubit) => cubit.deleteRoute('1'),
        expect: () => [
          RouteTrackingState(
            status: RouteTrackingStatus.success,
            routes: testRoutes,
          ),
        ],
        verify: (_) {
          verify(mockRepository.deleteRoute('1')).called(1);
          verify(mockRepository.getAllRoutes()).called(1);
        },
      );
    });

    group('clearFilters', () {
      blocTest<RouteTrackingCubit, RouteTrackingState>(
        'emits state with cleared filters',
        build: () => cubit,
        seed: () => RouteTrackingState(
          status: RouteTrackingStatus.success,
          routes: [],
          filteredRoutes: [RouteTrack(
            id: '1',
            name: 'Test Route',
            startTime: DateTime.now(),
            points: [],
            totalDistance: 1000.0,
            totalDuration: const Duration(minutes: 10),
            averageSpeed: 1.67,
            maxSpeed: 3.0,
            activityType: 'Running',
          )],
        ),
        act: (cubit) => cubit.clearFilters(),
        expect: () => [
          const RouteTrackingState(
            status: RouteTrackingStatus.success,
            routes: [],
            filteredRoutes: null,
          ),
        ],
      );
    });
  });
} 