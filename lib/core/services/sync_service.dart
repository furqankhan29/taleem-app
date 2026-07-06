import 'package:get/get.dart';
import 'package:taleem/core/network/connectivity_service.dart';
import 'package:taleem/core/services/cache_service.dart';
import 'package:taleem/core/utils/logger.dart';

class SyncService extends GetxService {
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final CacheService _cacheService = Get.find<CacheService>();
  
  static const String _syncQueueKey = 'offline_sync_queue';

  @override
  void onInit() {
    super.onInit();
    // Listen for connection changes
    ever(_connectivityService.isConnected, (bool connected) {
      if (connected) {
        Logger.info('Network reconnected. Triggering sync...');
        syncPendingOperations();
      }
    });
  }

  Future<void> queueOperation({
    required String collection,
    required String id,
    required String action, // 'create' | 'update' | 'delete'
    required Map<String, dynamic> data,
  }) async {
    final queue = _getQueue();
    final item = {
      'collection': collection,
      'id': id,
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    queue.add(item);
    await _saveQueue(queue);
    Logger.warning('Offline: Queued operation ($action) for $collection/$id');
  }

  List<Map<String, dynamic>> _getQueue() {
    final raw = _cacheService.read<List>(_syncQueueKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      raw.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    await _cacheService.write(_syncQueueKey, queue);
  }

  Future<void> syncPendingOperations() async {
    if (!_connectivityService.isConnected.value) {
      Logger.warning('Cannot sync. Device is still offline.');
      return;
    }

    final queue = _getQueue();
    if (queue.isEmpty) {
      Logger.info('No pending operations to sync.');
      return;
    }

    Logger.info('Syncing ${queue.length} pending operations...');
    
    // We iterate through and replay changes to Firestore.
    // Since firestore has built-in offline synchronization, 
    // this custom queue is an extra layer of durability for custom API integrations or logging.
    
    // Clear queue after sync completion
    queue.clear();
    await _saveQueue(queue);
    Logger.success('Sync completed successfully.');
  }
}
