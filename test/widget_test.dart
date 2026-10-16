import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_admission_application/core/widgets/deadline_chip.dart';

void main() {
  testWidgets('DeadlineChip displays Closed for past deadline', (WidgetTester tester) async {
    final pastDeadline = DateTime.now().subtract(const Duration(days: 2));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DeadlineChip(deadline: pastDeadline),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('DeadlineChip displays countdown for future deadline', (WidgetTester tester) async {
    final futureDeadline = DateTime.now().add(const Duration(days: 5, hours: 3));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DeadlineChip(deadline: futureDeadline),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.textContaining('left'), findsOneWidget);
  });
}
