import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final String title;
  final double progress;

  const ProgressBar({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.teal,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
