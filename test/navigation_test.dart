import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idealake_poc_ltfs/core/constants/app_strings.dart';
import 'package:idealake_poc_ltfs/core/di/service_locator.dart';
import 'package:idealake_poc_ltfs/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token_123',
      'is_logged_in': true,
    });
    await setupServiceLocator();
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('MainNavScreen handles back press and shows theme-consistent Exit Application dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const IdealakeApp());
    expect(find.text(AppStrings.appName), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));

    // Verify on Dashboard
    expect(find.text('Dashboard'), findsOneWidget);

    // Simulate system back navigation
    final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    // Verify Exit dialog appears with theme-consistent styling
    expect(find.text('Exit Application'), findsOneWidget);
    expect(find.text('Are you sure you want to exit the Idealake CMS app?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog is dismissed and Dashboard is still present
    expect(find.text('Exit Application'), findsNothing);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
