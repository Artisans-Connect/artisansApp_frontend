import 'package:artisans_app/features/client/presentation/screens/job_post_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows description minimum guidance while typing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: JobPostDetailsScreen(
          jobData: <String, dynamic>{
            'categoryName': 'Plumbing',
          },
        ),
      ),
    );

    expect(find.text('0/20 characters minimum'), findsOneWidget);
    expect(
      find.text('Add at least 20 characters so artisans understand the work.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'What should the artisan do? Include scope, access details, and any deadlines.',
      ),
      'Fix the leaking pipe under my kitchen sink.',
    );
    await tester.pump();

    expect(find.text('43/20 characters minimum'), findsOneWidget);
    expect(
      find.text('Add at least 20 characters so artisans understand the work.'),
      findsNothing,
    );
  });
}
