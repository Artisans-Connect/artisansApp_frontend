String formatRelativeTime(DateTime dateTime) {
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
