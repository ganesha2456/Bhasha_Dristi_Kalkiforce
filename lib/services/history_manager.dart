import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/history_item.dart';

class HistoryManager {
  static const _uuid = Uuid();
  static Box<HistoryItem> get _box => Hive.box<HistoryItem>("historyBox");

  static Future<void> addHistory({
    required String sourceText,
    required String translatedText,
    required String type,
  }) async {
    final item = HistoryItem(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      sourceText: sourceText,
      translatedText: translatedText,
      type: type,
    );
    await _box.put(item.id, item);
  }

  static List<HistoryItem> getHistory() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> deleteHistory(String id) async {
    await _box.delete(id);
  }

  static Future<void> clearHistory() async {
    await _box.clear();
  }
}
