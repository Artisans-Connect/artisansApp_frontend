class GreetingUtils {
  GreetingUtils._();

  /// Returns a time-of-day greeting string based on the given or current time.
  /// Options:
  /// - Morning (05:00 - 11:59): 'Good morning' / 'Good Morning'
  /// - Afternoon (12:00 - 16:59): 'Good afternoon' / 'Good Afternoon'
  /// - Evening (17:00 - 21:59): 'Good evening' / 'Good Evening'
  /// - Night (22:00 - 04:59): 'Good night' / 'Good Night'
  static String getGreeting({DateTime? time, bool capitalizeWords = false}) {
    final int hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return capitalizeWords ? 'Good Morning' : 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return capitalizeWords ? 'Good Afternoon' : 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return capitalizeWords ? 'Good Evening' : 'Good evening';
    } else {
      return capitalizeWords ? 'Good Night' : 'Good night';
    }
  }

  /// Returns an emoji icon appropriate for the time of day.
  static String getTimeOfDayEmoji({DateTime? time}) {
    final int hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 17) {
      return '☀️';
    } else if (hour >= 17 && hour < 22) {
      return '🌆';
    } else {
      return '🌙';
    }
  }

  /// Returns a dynamic subtitle tailored for worker/artisan users based on the time of day.
  static String getWorkerSubtitle({DateTime? time}) {
    final int hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return 'Ready to earn today?';
    } else if (hour >= 12 && hour < 17) {
      return 'Let\'s find you your next client.';
    } else if (hour >= 17 && hour < 22) {
      return 'Winding down or taking evening jobs?';
    } else {
      return 'Working late? Stay safe out there!';
    }
  }
}
