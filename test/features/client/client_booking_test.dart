import 'package:artisans_app/features/client/presentation/models/client_booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps pending client approval as trackable and rateable', () {
    final booking = ClientBooking.fromApiJob(<String, dynamic>{
      'id': 'job-1',
      'title': 'Fix sink',
      'status': 'pending_client_approval',
      'worker_id': 'worker-1',
      'created_at': '2026-06-08T10:00:00Z',
    });

    expect(booking.status, ClientBookingStatus.pendingApproval);
    expect(booking.isTrackable, isTrue);
    expect(booking.canRate, isTrue);
  });

  test('does not pick completed jobs as active trackable jobs', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'completed-job',
        'title': 'Old job',
        'status': 'completed',
      },
    ]);

    expect(active, isNull);
  });
}
