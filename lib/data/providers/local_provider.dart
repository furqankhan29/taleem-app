import 'package:hive_flutter/hive_flutter.dart';
import 'package:taleem/core/errors/app_exceptions.dart';
import 'package:taleem/core/errors/error_handler.dart';

class LocalProvider {
  LocalProvider();

  Future<void> save<T>(String boxName, String key, T value) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      await box.put(key, value);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(CacheException(e.toString()), stackTrace);
    }
  }

  Future<T?> get<T>(String boxName, String key) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      return box.get(key);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(CacheException(e.toString()), stackTrace);
    }
  }

  Future<List<T>> getAll<T>(String boxName) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      return box.values.toList();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(CacheException(e.toString()), stackTrace);
    }
  }

  Future<void> delete<T>(String boxName, String key) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      await box.delete(key);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(CacheException(e.toString()), stackTrace);
    }
  }

  Future<void> clear<T>(String boxName) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      await box.clear();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(CacheException(e.toString()), stackTrace);
    }
  }
}
