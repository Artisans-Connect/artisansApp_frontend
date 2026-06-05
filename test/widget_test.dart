import 'package:artisans_app/features/worker/presentation/models/mock_worker_data.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/widgets/availability_card.dart';
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
          ),
        ),
      ),
    );

    expect(find.text('Available for work'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('Accept job from detail updates session',
      (WidgetTester tester) async {
    final session = WorkerSessionState();
    session.acceptJob(MockWorkerData.incomingJobs.first);

    expect(session.hasActiveJob, isTrue);
    expect(session.jobPhase, WorkerJobPhase.accepted);
  });
}
