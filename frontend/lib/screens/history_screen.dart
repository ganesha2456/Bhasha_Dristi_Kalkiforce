import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_manager.dart';
import '../models/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final data = HistoryManager.getHistory();
    setState(() => _items = data);
  }

  Future<void> _deleteItem(int index) async {
    await HistoryManager.deleteHistory(index.toString());
    _loadHistory();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History"), centerTitle: true),
      body: _items.isEmpty
          ? const Center(
              child: Text("No History Yet",
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onLongPress: () => _deleteItem(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.sourceText,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(item.translatedText,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.type.toUpperCase(),
                                style: const TextStyle(color: Colors.amber)),
                            Text(formatDate(item.createdAt),
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
