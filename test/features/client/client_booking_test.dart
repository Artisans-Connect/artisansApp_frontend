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

  test('picks termination requested jobs as active trackable jobs', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'job-termination',
        'title': 'Fix wiring',
        'status': 'termination_requested',
        'worker_id': 'worker-1',
      },
    ]);

    expect(active, isNotNull);
    expect(active!.backendStatus, 'termination_requested');
    expect(active.status, ClientBookingStatus.inProgress);
    expect(active.isTrackable, isTrue);
  });

  test('picks scheduled confirmed jobs as active trackable jobs', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'job-scheduled-confirmed',
        'title': 'Install ceiling fan',
        'status': 'scheduled_confirmed',
        'worker_id': 'worker-1',
        'job_mode': 'scheduled',
        'scheduled_for': '2026-07-01T09:00:00Z',
      },
    ]);

    expect(active, isNotNull);
    expect(active!.backendStatus, 'scheduled_confirmed');
    expect(active.status, ClientBookingStatus.accepted);
    expect(active.isClientCancellable, isTrue);
    expect(active.isTrackable, isTrue);
  });

  test('does not pick worker-cancelled jobs as active jobs on home banner', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'job-worker-cancelled',
        'title': 'Fix wiring',
        'status': 'cancelled',
        'cancelled_by': 'worker',
      },
    ]);

    expect(active, isNull);

    final booking = ClientBooking.fromApiJob(<String, dynamic>{
      'id': 'job-worker-cancelled',
      'title': 'Fix wiring',
      'status': 'cancelled',
      'cancelled_by': 'worker',
    });
    expect(booking.status, ClientBookingStatus.cancelled);
    expect(booking.isRecoverableServiceInterruption, isTrue);
  });

  test('does not pick accepted termination jobs as active jobs on home banner', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'job-termination-accepted',
        'title': 'Fix wiring',
        'status': 'cancelled',
        'cancelled_by': 'client',
        'cancellation_stage': 'termination_requested',
      },
    ]);

    expect(active, isNull);

    final booking = ClientBooking.fromApiJob(<String, dynamic>{
      'id': 'job-termination-accepted',
      'title': 'Fix wiring',
      'status': 'cancelled',
      'cancelled_by': 'client',
      'cancellation_stage': 'termination_requested',
    });
    expect(booking.status, ClientBookingStatus.cancelled);
    expect(booking.isRecoverableServiceInterruption, isTrue);
  });

  test('does not pick ordinary client cancellations as active jobs', () {
    final active = ClientBooking.pickActiveTrackable(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'job-client-cancelled',
        'title': 'Fix wiring',
        'status': 'cancelled',
        'cancelled_by': 'client',
        'cancellation_stage': 'free',
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

  test('maps backend scheduled drafts as requested scheduled bookings', () {
    final booking = ClientBooking.fromApiJob(<String, dynamic>{
      'id': 'scheduled-job',
      'title': 'Install ceiling fan',
      'status': 'draft',
      'job_mode': 'scheduled',
      'scheduled_for': '2026-07-01T09:00:00Z',
    });

    expect(booking.status, ClientBookingStatus.requested);
    expect(booking.backendStatus, 'draft');
    expect(booking.jobMode, 'scheduled');
    expect(booking.scheduledFor, '2026-07-01T09:00:00Z');
    expect(booking.isLocalDraft, isFalse);
  });
}
