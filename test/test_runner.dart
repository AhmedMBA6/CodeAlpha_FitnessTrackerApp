import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/dashboard_aggregator_test.dart' as dashboard_aggregator_test;
import 'unit/dashboard_filter_service_test.dart' as dashboard_filter_service_test;
import 'unit/date_utils_test.dart' as date_utils_test;
import 'widget/dashboard_summary_row_test.dart' as dashboard_summary_row_test;
import 'widget/date_range_filter_test.dart' as date_range_filter_test;
import 'widget/weekly_activity_pie_chart_test.dart' as weekly_activity_pie_chart_test;
import 'integration/dashboard_screen_test.dart' as dashboard_screen_test;

void main() {
  group('Dashboard Test Suite', () {
    group('Unit Tests', () {
      dashboard_aggregator_test.main();
      dashboard_filter_service_test.main();
      date_utils_test.main();
    });

    group('Widget Tests', () {
      dashboard_summary_row_test.main();
      date_range_filter_test.main();
      weekly_activity_pie_chart_test.main();
    });

    group('Integration Tests', () {
      dashboard_screen_test.main();
    });
  });
} 