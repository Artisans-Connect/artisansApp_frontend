import 'package:artisans_app/features/worker/presentation/models/worker_job.dart';
import 'package:artisans_app/shared/widgets/job_requests_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('job requests map renders nothing without located jobs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobRequestsMapPreview(
            jobs: const <WorkerJob>[],
            selectedJobId: '',
            onSelectJob: (_) {},
            onOpenJob: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Details'), findsNothing);
    expect(find.textContaining('dispatched request'), findsNothing);
  });

  testWidgets('job requests map shows configuration state when key is absent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobRequestsMapPreview(
            jobs: const <WorkerJob>[
              WorkerJob(
                id: 'job-1',
                title: 'Fix wiring',
                category: 'Electrical',
                description: 'Replace a damaged socket',
                addressLabel: 'Ayeduase',
                latitude: 6.6745,
                longitude: -1.5716,
                clientName: 'Client',
                urgency: JobUrgency.asap,
              ),
            ],
            selectedJobId: 'job-1',
            onSelectJob: (_) {},
            onOpenJob: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Configure GOOGLE_MAPS_API_KEY'),
      findsOneWidget,
    );
  });
}
