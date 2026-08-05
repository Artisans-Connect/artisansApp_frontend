import 'package:hive_flutter/hive_flutter.dart';

const String _boxName = 'hidden_bookings';

class HiddenBookingsStore {
  HiddenBookingsStore._();

  static final HiddenBookingsStore instance = HiddenBookingsStore._();

  Box<bool>? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<bool>(_boxName);
    } else {
      _box = Hive.box<bool>(_boxName);
    }
  }

  Future<void> hide(String bookingId) async {
    await _ensureBox();
    await _box?.put(bookingId, true);
  }

  Future<bool> isHidden(String bookingId) async {
    await _ensureBox();
    return _box?.get(bookingId) ?? false;
  }

  Future<Set<String>> getHiddenIds() async {
    await _ensureBox();
    if (_box == null) return <String>{};
    return _box!.keys.map((dynamic k) => k.toString()).toSet();
  }

  Future<void> _ensureBox() async {
    if (_box == null || !Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  Future<void> clear() async {
    await _ensureBox();
    await _box?.clear();
  }
}
