import 'mock_worker_job.dart';

abstract final class MockWorkerData {
  static const workerName = 'Kofi Mensah';
  static const workerFirstName = 'Kofi';
  static const workerRating = 4.9;
  static const totalJobs = 0;
  static const responseHoursLabel = '-- hrs';

  static final List<MockWorkerJob> incomingJobs = [
    const MockWorkerJob(
      id: 'job-001',
      title: 'Fix leaking kitchen pipe',
      category: 'Plumbing',
      description:
          'High-pressure leak under the kitchen sink. Water is spraying from the connection. Need an expert plumber to fix it ASAP before it damages the cabinets.',
      addressLabel: 'East Legon',
      cityLine: 'East Legon, Accra',
      postalLine: 'Greater Accra, Ghana',
      mapLabel: 'East Legon, Accra',
      latitude: 5.6500,
      longitude: -0.1667,
      clientName: 'Akosua Mensah',
      urgency: JobUrgency.asap,
      urgencyBadge: 'ASAP',
      isNewClient: true,
      isUrgent: true,
      distanceKm: 2.3,
      photoCount: 3,
      estimateLabel: '₵85 - 120',
      estimatedBudgetLabel: '₵85 - 120',
      referencePhotoLabels: ['Leak under sink', 'Pipe connection', 'Tools'],
      earnedAmount: 145,
    ),
    const MockWorkerJob(
      id: 'job-002',
      title: 'Ceiling Fan Installation',
      category: 'Electrical',
      description:
          'Install a new ceiling fan in the master bedroom. Wiring is already in place. Fan provided by client.',
      addressLabel: 'Osu',
      cityLine: 'Osu, Accra',
      postalLine: 'Greater Accra, Ghana',
      mapLabel: 'Osu, Accra',
      latitude: 5.5560,
      longitude: -0.1820,
      clientName: 'Kwame Asante',
      clientRating: 4.8,
      reviewCount: 8,
      urgency: JobUrgency.scheduled,
      urgencyBadge: 'FRI 2PM',
      scheduledLabel: 'FRI 2PM',
      distanceKm: 4.1,
      photoCount: 1,
      estimateLabel: '₵60 - 90',
    ),
    const MockWorkerJob(
      id: 'job-003',
      title: 'Emergency Pipe Repair',
      category: 'Plumbing',
      description:
          'Burst pipe in the bathroom wall. Need urgent repair and patch. Client home all day.',
      addressLabel: 'Madina',
      cityLine: 'Madina, Accra',
      postalLine: 'Greater Accra, Ghana',
      mapLabel: 'Madina, Accra',
      latitude: 5.6833,
      longitude: -0.1667,
      clientName: 'Sarah Mitchell',
      urgency: JobUrgency.asap,
      urgencyBadge: 'ASAP',
      isUrgent: true,
      distanceKm: 2.4,
      photoCount: 3,
      estimateLabel: '₵85 - 120',
      referencePhotoLabels: ['Burst pipe', 'Bathroom wall'],
    ),
  ];

  static final List<MockWorkerJob> historyJobs = [
    const MockWorkerJob(
      id: 'hist-001',
      title: 'Custom Cabinetry Repair',
      category: 'Carpentry',
      description: 'Cabinet hinge and shelf repair.',
      addressLabel: 'Labone',
      latitude: 0,
      longitude: 0,
      clientName: 'Sarah Jenkins',
      urgency: JobUrgency.asap,
      historyStatus: HistoryStatus.completed,
      historyDate: '14/10/2025',
      historyRating: 5.0,
      earnedAmount: 180,
    ),
    const MockWorkerJob(
      id: 'hist-002',
      title: 'Plumbing Emergency',
      category: 'Plumbing',
      description: 'Fixed burst pipe.',
      addressLabel: 'Tema',
      latitude: 0,
      longitude: 0,
      clientName: 'Robert Miller',
      urgency: JobUrgency.asap,
      historyStatus: HistoryStatus.completed,
      historyDate: '10/10/2025',
      historyRating: 4.0,
      earnedAmount: 95,
    ),
    const MockWorkerJob(
      id: 'hist-003',
      title: 'Wall Painting',
      category: 'Painting',
      description: 'Client cancelled before start.',
      addressLabel: 'Spintex',
      latitude: 0,
      longitude: 0,
      clientName: 'Grace Adjei',
      urgency: JobUrgency.scheduled,
      historyStatus: HistoryStatus.cancelled,
      historyDate: '05/10/2025',
    ),
  ];

  static MockWorkerJob? findById(String id) {
    try {
      return incomingJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  static String formatCedis(num amount) {
    if (amount == amount.roundToDouble()) {
      return '₵${amount.round()}';
    }
    return '₵${amount.toStringAsFixed(2)}';
  }

  static String formatRating(double rating) => rating.toStringAsFixed(1);
}
