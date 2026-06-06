String formatCedis(num amount) {
  if (amount == amount.roundToDouble()) {
    return 'GHS ${amount.round()}';
  }
  return 'GHS ${amount.toStringAsFixed(2)}';
}

String formatRating(double rating) => rating.toStringAsFixed(1);

String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
