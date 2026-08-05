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
}
