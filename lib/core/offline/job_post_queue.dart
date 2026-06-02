import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/jobs_service.dart';

const String _boxName = 'pending_job_posts';

class PendingJobPost {
  PendingJobPost({
    required this.idempotencyKey,
    required this.payload,
    required this.createdAt,
  });

  final String idempotencyKey;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'idempotencyKey': idempotencyKey,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  static PendingJobPost fromJson(Map<String, dynamic> json) => PendingJobPost(
        idempotencyKey: json['idempotencyKey'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class JobPostQueue {
  JobPostQueue._();
  static final JobPostQueue instance = JobPostQueue._();

  final JobsService _jobsService = JobsService();
  final _uuid = const Uuid();
  Box<String>? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<String>(_boxName);
    } else {
      _box = Hive.box<String>(_boxName);
    }
    Connectivity().onConnectivityChanged.listen((_) => flush());
  }

  Future<String> enqueue(Map<String, dynamic> payload) async {
    final key = _uuid.v4();
    await _box?.put(
      key,
      jsonEncode(
        PendingJobPost(
          idempotencyKey: key,
          payload: payload,
          createdAt: DateTime.now(),
        ).toJson(),
      ),
    );
    return key;
  }

  Future<void> flush() async {
    if (_box == null || _box!.isEmpty) return;

    final keys = _box!.keys.cast<String>().toList();
    for (final storageKey in keys) {
      final raw = _box!.get(storageKey);
      if (raw == null) continue;
      try {
        final pending = PendingJobPost.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        await _jobsService.createJob(
          pending.payload,
          idempotencyKey: pending.idempotencyKey,
        );
        await _box!.delete(storageKey);
      } catch (_) {
        // Keep in queue until network/API succeeds
      }
    }
  }

  Future<int> pendingCount() async => _box?.length ?? 0;
}
