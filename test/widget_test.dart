import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_dashboard/availability_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Availability card renders worker online toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvailabilityCard(
            isAvailable: false,
            onChanged: (_) {},
            lastCheckedAt: null,
            isSilentRefreshing: false,
            isAvailabilityLoading: false,
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('Accept job from detail updates session',
      (WidgetTester tester) async {
    final session = WorkerSessionState();
    session.acceptJob(
      const WorkerJob(
        id: 'job-test',
        title: 'Fix sink',
        category: 'Plumbing',
        description: 'Leaking sink',
        addressLabel: 'Kumasi',
        latitude: 0,
        longitude: 0,
        clientName: 'Client',
        urgency: JobUrgency.scheduled,
      ),
    );

    expect(session.hasActiveJob, isTrue);
    expect(session.jobPhase, WorkerJobPhase.accepted);
  });
}
