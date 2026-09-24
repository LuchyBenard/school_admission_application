import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/offline_queue_service.dart';

class OfflineQueueProvider extends ChangeNotifier {
  final OfflineQueueService _service = OfflineQueueService.instance;

  bool _isOnline = true;
  int _pendingCount = 0;
  bool _isSyncing = false;
  bool _initialized = false;

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;
  bool get hasPendingItems => _pendingCount > 0;
  bool get isInitialized => _initialized;

  /// Start connectivity monitoring and replay any queued operations.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _service.onConnectivityChanged = _onConnectivityChanged;
    await _service.init();
    _isOnline = _service.isOnlineNow;
    _pendingCount = await _service.pendingCount();

    if (_isOnline && _pendingCount > 0) {
      unawaited(syncNow());
    }
    notifyListeners();
  }

  void _onConnectivityChanged(bool online) {
    _isOnline = online;
    notifyListeners();
    if (online && hasPendingItems) {
      unawaited(syncNow());
    }
  }

  /// Replay queued operations now (called from the banner retry button).
  Future<SyncSummary> syncNow() async {
    if (_isSyncing) return const SyncSummary(0, 0, _pendingCount);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    _isSyncing = true;
    notifyListeners();

    // isOnline might be stale (e.g. WiFi without internet) — the service
    // re-checks and only proceeds when connectivity actually exists.
    await _service.isOnline();

    final result = await _service.syncAll(userId: uid);
    _pendingCount = await _service.pendingCount();
    _isSyncing = false;
    notifyListeners();
    return result;
  }

  // ---------------------------------------------------------------------
  // Offline-aware operations used by the application flow screens.
  // Each returns true when the write happened or was queued.
  // ---------------------------------------------------------------------

  Future<bool> uploadDocument({
    required String applicationId,
    required String docKey,
    required String userId,
    required String base64Image,
  }) async {
    final result = await _service.executeOrQueue(
      type: 'document_upload',
      key: 'document_upload:$applicationId:$docKey',
      payload: {
        'appId': applicationId,
        'docKey': docKey,
        'userId': userId,
        'data': base64Image,
      },
      write: () => _service.uploadDocumentToFirestore(
        applicationId: applicationId,
        docKey: docKey,
        userId: userId,
        base64Image: base64Image,
      ),
    );
    _pendingCount = await _service.pendingCount();
    notifyListeners();
    return result != OfflineOpResult.failed;
  }

  Future<bool> completeApplication({
    required String applicationId,
    required List<String> docKeys,
  }) async {
    final result = await _service.executeOrQueue(
      type: 'application_complete',
      key: 'application_complete:$applicationId',
      payload: {'appId': applicationId, 'documents': docKeys},
      write: () => _service.completeApplicationInFirestore(
        applicationId: applicationId,
        docKeys: docKeys,
      ),
    );
    _pendingCount = await _service.pendingCount();
    notifyListeners();
    return result != OfflineOpResult.failed;
  }

  Future<bool> recordPayment({
    required String applicationId,
    required String method,
    required double amount,
  }) async {
    final result = await _service.executeOrQueue(
      type: 'payment_complete',
      key: 'payment_complete:$applicationId',
      payload: {
        'appId': applicationId,
        'paymentMethod': method,
        'amountPaid': amount,
      },
      write: () => _service.recordPaymentInFirestore(
        applicationId: applicationId,
        method: method,
        amount: amount,
      ),
    );
    _pendingCount = await _service.pendingCount();
    notifyListeners();
    return result != OfflineOpResult.failed;
  }

  @override
  void dispose() {
    _service.onConnectivityChanged = null;
    _service.dispose();
    super.dispose();
  }
}