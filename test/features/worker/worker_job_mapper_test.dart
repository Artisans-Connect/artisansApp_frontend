import 'package:artisans_app/features/worker/presentation/utils/worker_job_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps category presentation data onto a worker job', () {
    final job = workerJobFromApi(<String, dynamic>{
      'id': 'job-1',
      'title': 'Fix wiring',
      'categories': <String, dynamic>{
        'name': 'Electrical & Power',
        'icon_name': 'lightning',
        'color_hex': '#0058BE',
      },
    });

    expect(job.category, 'Electrical & Power');
    expect(job.categoryIconName, 'lightning');
    expect(job.categoryColorHex, '#0058BE');
  });
}
