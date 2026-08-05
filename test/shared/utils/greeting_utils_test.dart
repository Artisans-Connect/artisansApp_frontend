import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_app/shared/utils/greeting_utils.dart';

void main() {
  group('GreetingUtils', () {
    test('returns Morning greeting between 05:00 and 11:59', () {
      for (int h = 5; h < 12; h++) {
        final DateTime time = DateTime(2026, 8, 2, h, 30);
        expect(GreetingUtils.getGreeting(time: time), equals('Good morning'));
        expect(GreetingUtils.getGreeting(time: time, capitalizeWords: true), equals('Good Morning'));
        expect(GreetingUtils.getTimeOfDayEmoji(time: time), equals('☀️'));
        expect(GreetingUtils.getWorkerSubtitle(time: time), equals('Ready to earn today?'));
      }
    });

    test('returns Afternoon greeting between 12:00 and 16:59', () {
      for (int h = 12; h < 17; h++) {
        final DateTime time = DateTime(2026, 8, 2, h, 0);
        expect(GreetingUtils.getGreeting(time: time), equals('Good afternoon'));
        expect(GreetingUtils.getGreeting(time: time, capitalizeWords: true), equals('Good Afternoon'));
        expect(GreetingUtils.getTimeOfDayEmoji(time: time), equals('☀️'));
        expect(GreetingUtils.getWorkerSubtitle(time: time), equals('Let\'s find you your next client.'));
      }
    });

    test('returns Evening greeting between 17:00 and 21:59', () {
      for (int h = 17; h < 22; h++) {
        final DateTime time = DateTime(2026, 8, 2, h, 15);
        expect(GreetingUtils.getGreeting(time: time), equals('Good evening'));
        expect(GreetingUtils.getGreeting(time: time, capitalizeWords: true), equals('Good Evening'));
        expect(GreetingUtils.getTimeOfDayEmoji(time: time), equals('🌆'));
        expect(GreetingUtils.getWorkerSubtitle(time: time), equals('Winding down or taking evening jobs?'));
      }
    });

    test('returns Night greeting between 22:00 and 04:59', () {
      final List<int> nightHours = <int>[22, 23, 0, 1, 2, 3, 4];
      for (final int h in nightHours) {
        final DateTime time = DateTime(2026, 8, 2, h, 45);
        expect(GreetingUtils.getGreeting(time: time), equals('Good night'));
        expect(GreetingUtils.getGreeting(time: time, capitalizeWords: true), equals('Good Night'));
        expect(GreetingUtils.getTimeOfDayEmoji(time: time), equals('🌙'));
        expect(GreetingUtils.getWorkerSubtitle(time: time), equals('Working late? Stay safe out there!'));
      }
    });
  });
}
