import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'events_page.dart';
import 'helper.dart';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StyledButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 130,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00A0B0), Color(0xFF006E7F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _DiscussionPageState extends State<DiscussionPage> {
  List<Map<String, dynamic>> _discussions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiscussions();
  }

  Future<void> _fetchDiscussions() async {
    try {
      final discussionsCollection =
          await DatabaseHelper.getCollection('discussions');
      final discussions = await discussionsCollection.find().toList();
      setState(() {
        _discussions = List<Map<String, dynamic>>.from(discussions);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching discussions: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addResponse(String discussionId, String responseText) async {
    try {
      final newResponse = {
        "response": responseText,
        "timestamp": DateTime.now().toIso8601String(),
      };

      final discussionsCollection =
          await DatabaseHelper.getCollection('discussions');

      // Update the document in MongoDB
      await discussionsCollection.updateOne(
        mongo.where.id(mongo.ObjectId.parse(discussionId)),
        mongo.modify.push('responses', newResponse),
      );

      // Update the UI
      setState(() {
        final discussionIndex = _discussions.indexWhere(
            (discussion) => discussion['_id'].toString() == discussionId);
        if (discussionIndex != -1) {
          final responses =
              _discussions[discussionIndex]['responses'] as List<dynamic>?;
          if (responses != null) {
            responses.add(newResponse); // Append the new response
          } else {
            _discussions[discussionIndex]['responses'] = [newResponse];
          }
        }
      });
    } catch (e) {
      debugPrint("Error adding response: $e");
    }
  }

  void _showAddResponseDialog(String discussionId) {
    final TextEditingController responseController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a Response"),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(hintText: "Type your response"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          StyledButton(
            text: "Submit",
            onPressed: () async {
              if (responseController.text.trim().isNotEmpty) {
                await _addResponse(
                    discussionId, responseController.text.trim());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EventsPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Discussion"),
        backgroundColor: const Color(0xFF005F73),
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/left.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EventsPage()),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFD9F0F4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _discussions.isEmpty
              ? const Center(
                  child: Text(
                    "No discussions available.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFBAC1C8),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _discussions.length,
                  itemBuilder: (context, index) {
                    final discussion = _discussions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFFE5FCF7),
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              discussion['topic'] ?? 'No Topic',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003B4C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              discussion['content'] ?? 'No Content',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF006D77),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (discussion['responses'] != null &&
                                discussion['responses'] is List &&
                                (discussion['responses'] as List).isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Responses:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003B4C),
                                    ),
                                  ),
                                  ...List.generate(
                                    (discussion['responses'] as List).length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "- ${(discussion['responses'][i]['response']) ?? ''}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF006D77),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            StyledButton(
                              text: "Add a Response",
                              onPressed: () {
                                _showAddResponseDialog(
                                    discussion['_id'].toString());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
