import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String sourceText;

  @HiveField(3)
  String translatedText;

  /// "camera" / "gallery" / "text"
  @HiveField(4)
  String type;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.sourceText,
    required this.translatedText,
    required this.type,
  });
}
