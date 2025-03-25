import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ReportViewerWidget extends StatelessWidget {
  final Map<String, dynamic> report;
  final bool showTranslated;

  const ReportViewerWidget({
    required this.report,
    this.showTranslated = false,
    super.key,
  });

  String getDisplayContent() {
    final content = report['report_content'];
    if (content == null) return '';

    // If we have a translated version and showTranslated is true, show it
    if (showTranslated && content['translated_analysis'] != null) {
      return content['translated_analysis'];
    }

    // Otherwise show the raw analysis (in English)
    return content['raw_analysis'] ?? '';
  }

  String _getLanguage() {
    final content = report['report_content'];
    if (content == null) return 'English';

    if (content is Map) {
      return content['metadata']?['language'] ?? 'English';
    }
    return 'English';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = report['date_created'] ?? DateTime.now().toIso8601String();
    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      date = DateTime.now();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Column(
        children: [
          ExpansionTile(
            title: Text(
              report['report_title'] ?? 'Untitled Report',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM dd, yyyy').format(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Language: ${_getLanguage()}',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MarkdownBody(
                  data: getDisplayContent(),
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    h2: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    h3: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    p: const TextStyle(fontSize: 14),
                    listBullet: const TextStyle(color: Colors.teal),
                  ),
                ),
              ),

              // Toggle language button if translation exists
              if (_hasTranslation())
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Create a stateful builder to handle state change
                      final context = navigatorKey.currentContext;
                      if (context != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportViewerWidget(
                              report: report,
                              showTranslated: !showTranslated,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Image.asset('assets/icons/trans.png', height: 30),
                    label: Text(
                      showTranslated
                          ? 'Show Original (English)'
                          : 'Show Translated',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasTranslation() {
    final content = report['report_content'];
    return content != null && content['translated_analysis'] != null;
  }
}

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
