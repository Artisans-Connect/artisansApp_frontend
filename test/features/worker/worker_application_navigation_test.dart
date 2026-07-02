import 'package:artisans_app/features/worker/presentation/utils/worker_application_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pending applications open their details', () {
    expect(
      workerApplicationDestination('pending', 'searching'),
      WorkerApplicationDestination.details,
    );
  });

  test('accepted active jobs redirect to bookings', () {
    for (final status in <String>[
      'matched',
      'on_the_way',
      'arrived',
      'in_progress',
    ]) {
      expect(
        workerApplicationDestination('accepted', status),
        WorkerApplicationDestination.activeBooking,
      );
    }
  });

  test('terminal accepted jobs redirect to history', () {
    expect(
      workerApplicationDestination('accepted', 'completed'),
      WorkerApplicationDestination.history,
    );
    expect(
      workerApplicationDestination('accepted', 'cancelled'),
      WorkerApplicationDestination.history,
    );
  });

  test('termination-requested accepted jobs redirect to active bookings', () {
    expect(
      workerApplicationDestination('accepted', 'termination_requested'),
      WorkerApplicationDestination.activeBooking,
    );
  });

  test('unknown combinations safely open details', () {
    expect(
      workerApplicationDestination('accepted', 'pending_client_approval'),
      WorkerApplicationDestination.details,
    );
  });
}
