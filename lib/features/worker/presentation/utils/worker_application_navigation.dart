enum WorkerApplicationDestination { details, activeBooking, history }

WorkerApplicationDestination workerApplicationDestination(
  String applicationStatus,
  String jobStatus,
) {
  final String application = applicationStatus.trim().toLowerCase();
  final String job = jobStatus.trim().toLowerCase();

  if (application != 'accepted') {
    return WorkerApplicationDestination.details;
  }
  if (<String>{
    'matched',
    'on_the_way',
    'arrived',
    'in_progress',
    'termination_requested',
    'pending_client_approval',
  }.contains(job)) {
    return WorkerApplicationDestination.activeBooking;
  }
  if (<String>{'completed', 'cancelled'}.contains(job)) {
    return WorkerApplicationDestination.history;
  }
  return WorkerApplicationDestination.details;
}
