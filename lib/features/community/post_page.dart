import 'package:flutter/material.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController postController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D7377),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFD9F0F4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: postController,
                maxLines: 5,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  hintText: "Write something...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Post Created!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7377),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Post",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
