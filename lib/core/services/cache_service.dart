import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taleem/core/utils/logger.dart';

class CacheService extends GetxService {
  late dynamic _appBox;

  Future<CacheService> init() async {
    try {
      await Hive.initFlutter();
      _appBox = await Hive.openBox('taleem_cache');
      Logger.success('CacheService (Hive) initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Hive cache', e);
      // Fallback in-memory map to prevent app crash if Hive fails
      _appBox = _InMemoryBox();
    }
    return this;
  }

  Future<void> write<T>(String key, T value) async {
    await _appBox.put(key, value);
  }

  T? read<T>(String key) {
    final value = _appBox.get(key);
    if (value is T) {
      return value;
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _appBox.delete(key);
  }

  Future<void> clear() async {
    await _appBox.clear();
  }

  bool hasData(String key) {
    return _appBox.containsKey(key);
  }
}

// Simple in-memory fallback box if Hive fails (e.g. platform permission issue)
class _InMemoryBox {
  final Map<dynamic, dynamic> _data = {};

  dynamic get(key, {defaultValue}) => _data[key] ?? defaultValue;

  Future<void> put(key, value) async => _data[key] = value;

  Future<void> delete(key) async => _data.remove(key);

  Future<int> clear() async {
    final len = _data.length;
    _data.clear();
    return len;
  }

  bool containsKey(key) => _data.containsKey(key);

  Iterable get keys => _data.keys;

  Iterable get values => _data.values;

  int get length => _data.length;

  bool get isEmpty => _data.isEmpty;

  bool get isOpen => true;

  String? get path => null;

  bool get isNotEmpty => _data.isNotEmpty;

  Future<void> putAll(Map entries) async => _data.addAll(entries);

  Future<void> deleteAll(Iterable keys) async {
    for (var key in keys) {
      _data.remove(key);
    }
  }

  Future<void> compact() async {}

  Future<void> close() async {}

  Future<void> deleteFromDisk() async {}

  dynamic getAt(int index) => _data.values.elementAt(index);

  Future<void> putAt(int index, value) async {
    final key = _data.keys.elementAt(index);
    _data[key] = value;
  }

  Future<void> deleteAt(int index) async {
    final key = _data.keys.elementAt(index);
    _data.remove(key);
  }

  Stream<BoxEvent> watch({key}) => const Stream.empty();

  Map<dynamic, dynamic> toMap() => _data;
}
