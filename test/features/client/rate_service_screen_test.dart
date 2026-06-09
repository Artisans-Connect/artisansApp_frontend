import 'package:artisans_app/features/client/presentation/screens/rate_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders safely when imageUrl is missing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RateServiceScreen(
          service: <String, dynamic>{
            'job_id': 'job-1',
            'worker_id': 'worker-1',
            'artisan': 'Ama Worker',
            'profession': 'Electrician',
            'title': 'Fix lights',
          },
        ),
      ),
    );

    expect(find.text('Ama Worker'), findsOneWidget);
    expect(find.text('Electrician'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
  });
}
