import 'package:artisans_app/features/worker/presentation/models/mock_worker_data.dart';
import 'package:artisans_app/features/worker/presentation/screens/job_request_detail_screen.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/worker_dev_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Worker shell shows Requests on EXPLORE tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WorkerDevRouter());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Available for work'), findsOneWidget);
    expect(find.text('EXPLORE'), findsOneWidget);
  });

  testWidgets('Accept job from detail updates session',
      (WidgetTester tester) async {
    final session = WorkerSessionState();
    await tester.pumpWidget(
      MaterialApp(
        home: WorkerScope(
          notifier: session,
          child: JobRequestDetailScreen(
            job: MockWorkerData.incomingJobs.first,
            onAcceptRequest: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Accept Job'));
    await tester.pumpAndSettle();

    expect(session.hasActiveJob, isTrue);
    expect(session.jobPhase, WorkerJobPhase.preStart);
  });
}
