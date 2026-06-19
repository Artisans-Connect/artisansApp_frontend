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

  test('maps local job draft as a draft booking', () {
    final booking = ClientBooking.fromLocalDraft(
      draftId: 'draft-1',
      draftData: <String, dynamic>{
        'title': 'Repair kitchen sink',
        'categoryName': 'Plumbing',
        'address': 'Adum, Kumasi',
        'recommendedFee': 80.0,
        'clientPremium': 20.0,
        'savedAt': '2026-06-19T09:00:00.000Z',
      },
    );

    expect(booking.status, ClientBookingStatus.draft);
    expect(booking.isLocalDraft, isTrue);
    expect(booking.title, 'Repair kitchen sink');
    expect(booking.profession, 'Plumbing');
    expect(booking.amount, 'GHS 100');
    expect(booking.draftData?['address'], 'Adum, Kumasi');
  });
}
