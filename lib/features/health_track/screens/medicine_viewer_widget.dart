import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class medicineViewerWidget extends StatelessWidget {
  final Map<String, dynamic> medicine;

  const medicineViewerWidget({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          medicine['medicine_name'] ?? 'Unknown medicine',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          DateFormat('MMMM dd, yyyy').format(
            DateTime.parse(medicine['date_created']),
          ),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: medicine['about_medicine'] ?? 'No content available',
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                h3: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                p: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                listBullet: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
