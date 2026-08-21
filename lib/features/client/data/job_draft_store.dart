import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:artisans_app/features/client/presentation/models/client_booking.dart';
import 'package:artisans_app/features/client/presentation/models/client_job_draft.dart';

const String _boxName = 'client_job_drafts';

class JobDraftStore {
  JobDraftStore._();

  static final JobDraftStore instance = JobDraftStore._();

  final Uuid _uuid = const Uuid();
  Box<String>? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<String>(_boxName);
    } else {
      _box = Hive.box<String>(_boxName);
    }
  }

  Future<String> save(ClientJobDraft draft) async {
    await _ensureBox();
    final Map<String, dynamic> data = _jsonSafeMap(draft.toMap());
    final String draftId =
        data['draftId'] as String? ?? 'draft_${_uuid.v4()}';
    data['draftId'] = draftId;
    data['savedAt'] = DateTime.now().toUtc().toIso8601String();
    await _box?.put(draftId, jsonEncode(data));
    draft.merge(data);
    return draftId;
  }

  Future<List<ClientBooking>> listBookings() async {
    await _ensureBox();
    final Box<String>? box = _box;
    if (box == null || box.isEmpty) return <ClientBooking>[];

    final List<ClientBooking> bookings = <ClientBooking>[];
    for (final Object key in box.keys) {
      final String draftId = key.toString();
      final String? raw = box.get(key);
      if (raw == null) continue;
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        bookings.add(
          ClientBooking.fromLocalDraft(
            draftId: draftId,
            draftData: data,
          ),
        );
      } catch (_) {
        // Ignore malformed local drafts rather than blocking bookings.
      }
    }

    bookings.sort(
      (ClientBooking a, ClientBooking b) =>
          (b.draftSavedAt ?? '').compareTo(a.draftSavedAt ?? ''),
    );
    return bookings;
  }

  Future<void> delete(String draftId) async {
    await _ensureBox();
    await _box?.delete(draftId);
  }

  Future<void> _ensureBox() async {
    if (_box == null || !Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> input) {
    return input.map(
      (String key, dynamic value) => MapEntry<String, dynamic>(
        key,
        _jsonSafeValue(value),
      ),
    );
  }

  dynamic _jsonSafeValue(dynamic value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic nestedValue) => MapEntry<String, dynamic>(
          key.toString(),
          _jsonSafeValue(nestedValue),
        ),
      );
    }
    if (value is List) return value.map(_jsonSafeValue).toList();
    return value;
  }
}
