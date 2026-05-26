class JobReceiptViewData {
  const JobReceiptViewData({
    required this.jobId,
    required this.title,
    required this.clientName,
    required this.location,
    required this.completedAt,
    required this.amountGhs,
    required this.status,
    this.notes,
  });

  final String jobId;
  final String title;
  final String clientName;
  final String location;
  final DateTime completedAt;
  final double amountGhs;
  final String status;
  final String? notes;
}
