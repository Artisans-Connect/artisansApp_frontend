import 'package:artisans_app/core/navigation/route_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JobRouteArgs', () {
    test('normalizes legacy job id keys', () {
      final args = JobRouteArgs.tryParse(<String, dynamic>{
        'jobId': 'job-123',
        'title': 'Repair',
      });

      expect(args?.jobId, 'job-123');
      expect(args?.toMap()['job_id'], 'job-123');
      expect(args?.toMap()['title'], 'Repair');
    });

    test('rejects missing job identity', () {
      expect(JobRouteArgs.tryParse(<String, dynamic>{}), isNull);
    });

    test('rejects maps with non-string keys', () {
      expect(JobRouteArgs.tryParse(<dynamic, dynamic>{1: 'job-123'}), isNull);
    });
  });

  group('ArtisanRouteArgs', () {
    test('normalizes worker identity keys', () {
      final args = ArtisanRouteArgs.tryParse(<String, dynamic>{
        'worker_id': 'worker-123',
      });

      expect(args?.userId, 'worker-123');
    });

    test('accepts direct string identities', () {
      expect(ArtisanRouteArgs.tryParse('worker-456')?.userId, 'worker-456');
    });

    test('rejects maps with non-string keys', () {
      expect(ArtisanRouteArgs.tryParse(<dynamic, dynamic>{1: 'worker-456'}), isNull);
    });
  });

  test('rejects malformed payment checkout payloads', () {
    expect(
      PaymentCheckoutArgs.tryParse(<dynamic, dynamic>{1: 'job-123'}),
      isNull,
    );
  });
}
