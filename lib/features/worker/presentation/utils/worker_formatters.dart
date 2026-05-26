import '../models/mock_worker_data.dart';

String formatCedis(num amount) => MockWorkerData.formatCedis(amount);

String formatRating(double rating) => MockWorkerData.formatRating(rating);

String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
