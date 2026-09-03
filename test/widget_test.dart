import 'package:flutter_test/flutter_test.dart';
import 'package:idealake_poc_ltfs/core/constants/app_strings.dart';
import 'package:idealake_poc_ltfs/core/di/service_locator.dart';
import 'package:idealake_poc_ltfs/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('App launches with splash screen and redirects to Login screen when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const IdealakeApp());
    expect(find.text(AppStrings.appName), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Sign In to Sitefinity Portal'), findsOneWidget);
  });

  testWidgets('App launches with splash screen and redirects to Dashboard when authenticated', (WidgetTester tester) async {
    await locator.reset();
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token_123',
      'is_logged_in': true,
    });
    await setupServiceLocator();

    await tester.pumpWidget(const IdealakeApp());
    expect(find.text(AppStrings.appName), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Digital Portal'), findsOneWidget);
  });
}
