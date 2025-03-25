import 'package:flutter/material.dart';
import 'package:nurture_sync/features/community/events_page.dart';
import 'helper.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;

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

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List<Map<String, dynamic>> _queries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorQueries();
  }

  Future<void> _fetchDoctorQueries() async {
    try {
      final queriesCollection = await DatabaseHelper.getCollection('queries');
      final queries = await queriesCollection.find().toList();
      setState(() {
        _queries = List<Map<String, dynamic>>.from(queries);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching doctor queries: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addDoctorResponse(String queryId, String response) async {
    try {
      final newResponse = {
        "response": response,
        "timestamp": DateTime.now().toIso8601String(),
      };

      final queriesCollection = await DatabaseHelper.getCollection('queries');
      await queriesCollection.updateOne(
        mongo.where.id(mongo.ObjectId.parse(queryId)),
        mongo.modify.push('responses', newResponse),
      );

      _fetchDoctorQueries(); // Refresh queries after adding response
    } catch (e) {
      debugPrint("Error adding doctor response: $e");
    }
  }

  void _showAddResponseDialog(String queryId) {
    final TextEditingController responseController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add a Doctor Response",
          style: TextStyle(color: Color(0xFF00A0B0)),
        ),
        content: TextField(
          controller: responseController,
          decoration:
              const InputDecoration(hintText: "Type your response here"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          StyledButton(
            text: "Submit",
            onPressed: () async {
              if (responseController.text.trim().isNotEmpty) {
                await _addDoctorResponse(
                    queryId, responseController.text.trim());
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventsPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ask a Doctor"),
          backgroundColor: const Color(0xFF00A0B0),
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
              ); // Navigate to EventsPage
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _queries.isEmpty
                ? const Center(
                    child: Text(
                      "No questions available.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _queries.length,
                    itemBuilder: (context, index) {
                      final query = _queries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 6.0,
                        color: const Color(0xFFE5FCF7),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                query['question'] ?? 'No Question',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003B4C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Asked by: ${query['user_id'] ?? 'Anonymous'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (query['responses'] != null &&
                                  query['responses'] is List &&
                                  query['responses'].isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Doctor Responses:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003B4C),
                                      ),
                                    ),
                                    ...List.generate(
                                      query['responses'].length,
                                      (i) => Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "- ${query['responses'][i]['response'] ?? ''}",
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
                                text: "Add Response",
                                onPressed: () {
                                  _showAddResponseDialog(
                                      query['_id'].toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
