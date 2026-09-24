import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Outcome of an offline-aware write.
enum OfflineOpResult { done, queued, failed }

/// Result of a sync pass over the pending queue.
class SyncSummary {
  final int synced;
  final int failed;
  final int remaining;

  const SyncSummary(this.synced, this.failed, this.remaining);
}

/// Backs every application write with an offline queue.
///
/// When the app is online the operation is written straight to
/// Firestore. When it is offline (or the write times out) the operation
/// is persisted to GetStorage and replayed in order once connectivity
/// returns, via [syncAll].
///
/// Operation types:
///  - 'application_submit'    -> set applications/{appId}
///  - 'document_upload'       -> set applications/{appId}/documents/{docKey}
///  - 'application_complete'  -> update applications/{appId} (documentsUploaded)
///  - 'payment_complete'      -> update applications/{appId} (paid)
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  static const String queueKey = 'offline_queue_items';
  static const Duration _writeTimeout = Duration(seconds: 10);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  List<ConnectivityResult> _lastResults = [];
  bool _initialized = false;

  /// Called whenever connectivity state changes (bool = online?).
  ValueChanged<bool>? onConnectivityChanged;

  bool get isOnlineNow => _hasConnectivity;

  bool get _hasConnectivity =>
      !_lastResults.contains(ConnectivityResult.none);

  /// Read the current connectivity state.
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _lastResults = results;
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('[OfflineQueueService] checkConnectivity error: $e');
      return false;
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _lastResults = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('[OfflineQueueService] init connectivity error: $e');
    }
    _connSub = _connectivity.onConnectivityChanged.listen((results) {
      _lastResults = results;
      onConnectivityChanged?.call(_hasConnectivity);
    });
  }

  void dispose() {
    _connSub?.cancel();
    _connSub = null;
  }

  // ---------------------------------------------------------------------
  // Queue persistence (GetStorage)
  // ---------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> readQueue() async {
    final box = GetStorage();
    final raw = box.read<List<dynamic>>(queueKey);
    return (raw ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<int> pendingCount() async {
    return (await readQueue()).length;
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> items) async {
    await GetStorage().write(queueKey, items);
  }

  /// Add an operation to the queue, replacing any existing operation
  /// with the same [key] (keeps re-taps from queuing duplicates).
  Future<void> enqueue({
    required String type,
    required String key,
    required Map<String, dynamic> payload,
  }) async {
    final items = await readQueue();
    items.removeWhere((i) => i['key'] == key);
    items.add({
      'key': key,
      'type': type,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _writeQueue(items);
  }

  /// Attempt [write] to Firestore; if offline (or the call times out)
  /// persist the operation to the queue instead and report [OfflineOpResult.queued].
  Future<OfflineOpResult> executeOrQueue({
    required String type,
    required String key,
    required Map<String, dynamic> payload,
    required Future<void> Function() write,
  }) async {
    if (await isOnline()) {
      try {
        await write().timeout(_writeTimeout);
        return OfflineOpResult.done;
      } catch (e) {
        debugPrint('[OfflineQueueService] write failed, queueing ($type): $e');
      }
    }

    try {
      await enqueue(type: type, key: key, payload: payload);
      return OfflineOpResult.queued;
    } catch (e) {
      debugPrint('[OfflineQueueService] enqueue failed ($type): $e');
      return OfflineOpResult.failed;
    }
  }

  // ---------------------------------------------------------------------
  // Sync — replay queued operations in FIFO order
  // ---------------------------------------------------------------------

  /// Replay queued operations for [userId] (ops belonging to another
  /// signed-in user are left untouched). Returns how many synced/failed.
  Future<SyncSummary> syncAll({String? userId}) async {
    final items = await readQueue();
    if (items.isEmpty) return const SyncSummary(0, 0, 0);

    if (!await isOnline()) {
      return const SyncSummary(0, 0, items.length);
    }

    int synced = 0;
    int failed = 0;
    final keep = <Map<String, dynamic>>[];

    for (final item in items) {
      final type = item['type'] as String? ?? '';
      final rawPayload = item['payload'];
      final payload =
          rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : <String, dynamic>{};

      // Only sync ops that belong to the current user.
      final opUserId = payload['userId'] as String?;
      if (userId != null && opUserId != null && opUserId != userId) {
        keep.add(item);
        continue;
      }

      try {
        await _runOperation(type, payload);
        synced++;
      } catch (e) {
        debugPrint('[OfflineQueueService] sync failed ($type, ${item['key']}): $e');
        failed++;
        keep.add(item);
        // A failure usually means the connection dropped mid-sync.
        // Keep everything after this point for the next retry.
        for (var i = items.indexOf(item) + 1; i < items.length; i++) {
          keep.add(items[i]);
        }
        break;
      }
    }

    if (keep.length != items.length) {
      await _writeQueue(keep);
    }
    return SyncSummary(synced, failed, keep.length);
  }

  Future<void> _runOperation(String type, Map<String, dynamic> payload) async {
    switch (type) {
      case 'application_submit':
        final appId = payload['appId'] as String;
        final data = (payload['data'] as Map).cast<String, dynamic>();
        await uploadApplicationToFirestore(appId: appId, data: data);
        break;

      case 'document_upload':
        await uploadDocumentToFirestore(
          applicationId: payload['appId'] as String,
          docKey: payload['docKey'] as String,
          userId: payload['userId'] as String,
          base64Image: payload['data'] as String,
        );
        break;

      case 'application_complete':
        await completeApplicationInFirestore(
          applicationId: payload['appId'] as String,
          docKeys: (payload['documents'] as List).cast<String>(),
        );
        break;

      case 'payment_complete':
        await recordPaymentInFirestore(
          applicationId: payload['appId'] as String,
          method: payload['paymentMethod'] as String,
          amount: (payload['amountPaid'] as num).toDouble(),
        );
        break;

      default:
        throw ArgumentError('Unknown offline queue operation type: $type');
    }
  }

  // ---------------------------------------------------------------------
  // Firestore write primitives (shared by live writes and queue replay)
  // ---------------------------------------------------------------------

  Future<void> uploadApplicationToFirestore({
    required String appId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('applications').doc(appId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadDocumentToFirestore({
    required String applicationId,
    required String docKey,
    required String userId,
    required String base64Image,
  }) async {
    await _firestore
        .collection('applications')
        .doc(applicationId)
        .collection('documents')
        .doc(docKey)
        .set({
      'docKey': docKey,
      'data': base64Image,
      'userId': userId,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeApplicationInFirestore({
    required String applicationId,
    required List<String> docKeys,
  }) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'documents': docKeys,
      'documentsUploaded': true,
    });
  }

  Future<void> recordPaymentInFirestore({
    required String applicationId,
    required String method,
    required double amount,
  }) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'paymentStatus': 'paid',
      'paymentMethod': method,
      'paymentDate': DateTime.now().toIso8601String(),
      'amountPaid': amount,
    });
  }
}