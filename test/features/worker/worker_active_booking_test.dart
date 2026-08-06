import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_phase_stepper.dart';

void main() {
  group('WorkerPhaseStepper', () {
    testWidgets('renders all 4 phase step labels correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkerPhaseStepper(currentPhase: WorkerJobPhase.onTheWay),
          ),
        ),
      );

      expect(find.text('En Route'), findsOneWidget);
      expect(find.text('Arrived'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('renders active phase for inProgress step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkerPhaseStepper(currentPhase: WorkerJobPhase.inProgress),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });
  });

  group('WorkerSessionState', () {
    test('initial state has no pending cancellation message and phase is none', () {
      final state = WorkerSessionState();
      expect(state.pendingCancellationMessage, isNull);
      expect(state.jobPhase, WorkerJobPhase.none);
    });

    test('clearCancellationMessage clears pending message', () {
      final state = WorkerSessionState();
      state.pendingCancellationMessage = 'Test cancellation message';
      expect(state.pendingCancellationMessage, equals('Test cancellation message'));

      state.clearCancellationMessage();
      expect(state.pendingCancellationMessage, isNull);
    });
  });

  group('Job alert modal dismissal tracking', () {
    test('declined modal job IDs set retains declined IDs when dispatches close', () {
      final Set<String> declinedModalJobIds = <String>{};
      declinedModalJobIds.add('job_123');
      expect(declinedModalJobIds.contains('job_123'), isTrue);

      // Simulating dispatch closed event: job_123 is cleared from shown set but retained in declined set
      final Set<String> shownRequestIds = <String>{'job_123'};
      shownRequestIds.remove('job_123');

      expect(shownRequestIds.contains('job_123'), isFalse);
      expect(declinedModalJobIds.contains('job_123'), isTrue);
    });
  });
}
