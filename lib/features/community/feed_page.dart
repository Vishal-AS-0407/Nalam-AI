import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helper.dart';
import 'events_page.dart';
import 'post_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final postsCollection = await DatabaseHelper.getCollection('posts');
      final posts = await postsCollection.find().toList();
      setState(() {
        _posts = List<Map<String, dynamic>>.from(posts);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint("Error fetching posts: ${e.toString()}");
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching posts: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text("Feed"),
        backgroundColor: const Color(0xFF00A0B0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _posts.isEmpty
                  ? const Center(child: Text("No posts available."))
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];

                        // Extract post fields
                        final String title = post['title'] ?? 'No Title';
                        final String content = post['content'] ?? 'No Content';
                        final String imageUrl = post['image_url'] ?? '';
                        final String timestamp = post.containsKey('timestamp')
                            ? DateFormat.yMMMd()
                                .add_jm()
                                .format(DateTime.parse(post['timestamp']))
                            : 'Unknown time';

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
                                // Title
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF003B4C),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Image (if available)
                                if (imageUrl.isNotEmpty)
                                  Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text(
                                        "Image not available.",
                                        style: TextStyle(color: Colors.red),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 8),

                                // Content
                                Text(
                                  content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF006D77),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Timestamp
                                Text(
                                  "Posted on $timestamp",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Action Icons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          post['isLiked'] =
                                              !(post['isLiked'] ?? false);
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/like.png',
                                        color: post['isLiked'] ?? false
                                            ? const Color(0xFF00A0B0)
                                            : Colors.grey,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          post['isCommented'] =
                                              !(post['isCommented'] ?? false);
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/comment.png',
                                        color: post['isCommented'] ?? false
                                            ? const Color(0xFF00A0B0)
                                            : Colors.grey,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          post['isShared'] =
                                              !(post['isShared'] ?? false);
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/share.png',
                                        color: post['isShared'] ?? false
                                            ? const Color(0xFF00A0B0)
                                            : Colors.grey,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          post['isSaved'] =
                                              !(post['isSaved'] ?? false);
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/save.png',
                                        color: post['isSaved'] ?? false
                                            ? const Color(0xFF00A0B0)
                                            : Colors.grey,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/new-post.png', // Replace with your actual image path
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
