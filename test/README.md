# Dashboard Test Suite

This directory contains comprehensive tests for the dashboard functionality of the fitness tracker app.

## Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart          # Test utilities and mock data
├── unit/                          # Unit tests for business logic
│   ├── dashboard_aggregator_test.dart
│   ├── dashboard_filter_service_test.dart
│   └── date_utils_test.dart
├── widget/                        # Widget tests for UI components
│   ├── dashboard_summary_row_test.dart
│   ├── date_range_filter_test.dart
│   └── weekly_activity_pie_chart_test.dart
├── integration/                   # Integration tests
│   └── dashboard_screen_test.dart
├── test_runner.dart              # Test runner script
└── README.md                     # This file
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests only
flutter test test/integration/
```

### Run Individual Test Files
```bash
# Example: Run dashboard aggregator tests
flutter test test/unit/dashboard_aggregator_test.dart

# Example: Run dashboard screen integration tests
flutter test test/integration/dashboard_screen_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

## Test Categories

### Unit Tests (`test/unit/`)

#### DashboardAggregator Tests
- **Purpose**: Test data aggregation logic for dashboard metrics
- **Coverage**:
  - `getTodaySummary()` - Calculate today's activity summary
  - `getWeeklySummary()` - Calculate weekly activity summaries
  - `getMetrics()` - Calculate overall dashboard metrics
- **Test Cases**:
  - Normal data processing
  - Empty data handling
  - Edge cases (zero values, large numbers)
  - Date calculations

#### DashboardFilterService Tests
- **Purpose**: Test filtering logic for activities
- **Coverage**:
  - `filterByActivityType()` - Filter by activity type
  - `filterByDateRange()` - Filter by date range
  - `applyFilters()` - Apply multiple filters
  - `getTodayLogs()` - Get today's activities
  - `getLogsForDay()` - Get activities for specific day
- **Test Cases**:
  - Single filter application
  - Multiple filter combinations
  - Date range edge cases
  - Empty data handling

#### DateUtils Tests
- **Purpose**: Test date formatting and manipulation utilities
- **Coverage**:
  - `formatDate()` - Format dates for display
  - `formatTime()` - Format time for display
  - `formatDateForExport()` - Format dates for export
  - `getWeekdayLabel()` - Get weekday abbreviations
  - `isSameDay()` - Compare dates
  - `isToday()` - Check if date is today
  - `getStartOfWeek()` - Get week start date
  - `getStartOfMonth()` - Get month start date
  - `formatDateRange()` - Format date ranges
  - `getDatePresets()` - Get date preset options
- **Test Cases**:
  - Various date formats
  - Edge cases (leap years, month boundaries)
  - Date comparisons
  - Preset calculations

### Widget Tests (`test/widget/`)

#### DashboardSummaryRow Tests
- **Purpose**: Test the summary cards widget
- **Coverage**:
  - Today's summary display
  - Overall metrics display
  - Icon rendering
  - Value formatting
- **Test Cases**:
  - Normal data display
  - Zero values handling
  - Decimal value formatting
  - Large number handling
  - Responsive design

#### DateRangeFilter Tests
- **Purpose**: Test the date range filter widget
- **Coverage**:
  - Preset button display
  - Custom date picker
  - Date range selection
  - Reset functionality
- **Test Cases**:
  - Preset selection
  - Custom date range
  - State management
  - UI interactions

#### WeeklyActivityPieChart Tests
- **Purpose**: Test the activity type distribution chart
- **Coverage**:
  - Chart rendering
  - Legend display
  - Data aggregation
  - Empty state handling
- **Test Cases**:
  - Multiple activity types
  - Single activity type
  - Empty data
  - Large datasets

### Integration Tests (`test/integration/`)

#### DashboardScreen Tests
- **Purpose**: Test the complete dashboard screen
- **Coverage**:
  - Screen loading
  - Data display
  - Filter interactions
  - Export functionality
  - Quick actions
  - Pull-to-refresh
- **Test Cases**:
  - Complete user workflows
  - Error handling
  - State management
  - Responsive design
  - Performance

## Test Helpers

### TestHelpers Class
Located in `test/helpers/test_helpers.dart`, provides:
- Sample data creation
- Mock repository setup
- Common test utilities
- Widget testing helpers

### MockActivityLogRepository
Used in integration tests to simulate the activity log repository:
- Returns predefined test data
- Implements all repository methods
- Allows testing without database dependencies

## Test Data

### Sample Activity Logs
The test suite uses realistic sample data including:
- Multiple activity types (Running, Cycling, Walking)
- Various durations and calorie values
- Different dates (today, yesterday, past week)
- Edge cases (zero values, large numbers)

### Test Scenarios
Tests cover various scenarios:
- **Normal Operation**: Standard data processing
- **Empty Data**: Handling of no activities
- **Edge Cases**: Zero values, large numbers, date boundaries
- **Error Conditions**: Repository failures, invalid data
- **User Interactions**: Filtering, date selection, export

## Best Practices

### Test Organization
- **Arrange-Act-Assert**: Clear test structure
- **Descriptive Names**: Test names explain what is being tested
- **Single Responsibility**: Each test focuses on one aspect
- **Independent Tests**: Tests don't depend on each other

### Test Data Management
- **Realistic Data**: Use realistic sample data
- **Edge Cases**: Include boundary conditions
- **Consistent Setup**: Use setUp() for common initialization
- **Clean Teardown**: Properly clean up after tests

### Widget Testing
- **User Interactions**: Test actual user actions
- **State Changes**: Verify UI updates correctly
- **Responsive Design**: Test different screen sizes
- **Accessibility**: Consider accessibility features

## Coverage Goals

The test suite aims for:
- **Unit Tests**: 90%+ code coverage for business logic
- **Widget Tests**: All UI components tested
- **Integration Tests**: Complete user workflows covered
- **Edge Cases**: Comprehensive edge case handling

## Continuous Integration

Tests are automatically run:
- On every pull request
- Before merging to main branch
- During deployment pipeline
- With coverage reporting

## Troubleshooting

### Common Issues
1. **Test Dependencies**: Ensure all dependencies are added to pubspec.yaml
2. **Mock Setup**: Verify mock implementations match interfaces
3. **Async Operations**: Use proper async/await patterns
4. **State Management**: Ensure proper state initialization

### Debugging Tests
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test with debugging
flutter test test/unit/dashboard_aggregator_test.dart --verbose

# Run tests with coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Contributing

When adding new features:
1. **Write Tests First**: Follow TDD principles
2. **Update Test Helpers**: Add new sample data as needed
3. **Maintain Coverage**: Ensure new code is well-tested
4. **Update Documentation**: Keep this README current

## Dependencies

Required test dependencies in `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.5
  build_runner: ^2.4.8
``` 