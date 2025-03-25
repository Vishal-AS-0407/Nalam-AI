import 'package:flutter/material.dart';
import 'dart:async';
import 'doctor_page.dart';
import 'feed_page.dart';
import 'discussion_page.dart';
import 'appointment_page.dart';
import 'package:nurture_sync/features/health_track/screens/home_screen.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late String countdownText = "Loading...";
  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    DateTime eventDate = DateTime(2024, 12, 15, 0, 0, 0); // Event date
    Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      Duration difference = eventDate.difference(now);

      if (difference.isNegative) {
        setState(() {
          countdownText = "Event is live!";
        });
        timer.cancel();
      } else {
        setState(() {
          countdownText =
              "${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m left!";
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the corresponding page
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DiscussionPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorPage()),
        );
        break;
      default:
        break;
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
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text('Events'),
        backgroundColor: const Color(0xFF0D7377),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 217, 240, 244),
                  Color.fromARGB(255, 214, 242, 247)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Header
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Diabetic Awareness Event",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D7377),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Join us for an inspiring event!",
                      style: TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 10, 94, 97)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      countdownText,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D7377)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Event Description
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/events.png',
                              width: 400,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Diabetic Awareness Event",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D7377),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Join us for an event dedicated to raising awareness about diabetes. "
                              "Learn tips for managing diabetes, hear from medical experts, and share your "
                              "experiences with fellow patients.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Date: 18th Feb 2024",
                                  style: TextStyle(color: Color(0xFF0D7377)),
                                ),
                                Text(
                                  "Location: Online",
                                  style: TextStyle(color: Color(0xFF0D7377)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D7377),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Handle registration logic
                              },
                              child: const Text(
                                "Register Now",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 242, 245, 246)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Speakers Section
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Meet the Experts",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D7377),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SpeakerCard(
                          name: "Dr. Sunita Desai",
                          specialty: "Diabetes Specialist",
                          image: "assets/images/speaker2.jpg",
                        ),
                        SpeakerCard(
                          name: "Dr. Neil Parikh",
                          specialty: "Nutrition Expert",
                          image: "assets/images/speaker1.jpg",
                        ),
                        SpeakerCard(
                          name: "Dr. Arpan Parikh",
                          specialty: "Nutrition Expert",
                          image: "assets/images/speaker3.jpg",
                        ),
                      ],
                    ),
                    // Appointment Scheduling Card
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/appointment.png', // Replace with an appropriate image
                          width: 50,
                          height: 50,
                        ),
                        title: const Text(
                          "Schedule an Appointment",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D7377)),
                        ),
                        subtitle: const Text(
                            "Book a consultation with a specialist."),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF0D7377)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AppointmentPage()),
                          );
                        },
                      ),
                    ),

                    // FAQ Section
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "FAQs",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D7377),
                        ),
                      ),
                    ),
                    ListTile(
                      title: GestureDetector(
                        onTap: () => toggleFAQ(0),
                        child: const Text(
                          "What is the event about?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: faqVisibility[0]
                          ? const Text(
                              "This event raises awareness about managing diabetes and provides tips and resources.")
                          : null,
                    ),
                    ListTile(
                      title: GestureDetector(
                        onTap: () => toggleFAQ(1),
                        child: const Text(
                          "How do I join online?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: faqVisibility[1]
                          ? const Text(
                              "Once registered, you'll receive a link to join the event via email.")
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D7377),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/community.png',
              width: 24, // Set appropriate size for the image
              height: 24,
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/post.png',
              width: 24,
              height: 24,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/discussion.png',
              width: 24,
              height: 24,
            ),
            label: 'Discussion',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/doctor.png',
              width: 24,
              height: 24,
            ),
            label: 'Doctor',
          ),
        ],
      ),
    );
  }

  List<bool> faqVisibility = [false, false];

  void toggleFAQ(int index) {
    setState(() {
      faqVisibility[index] = !faqVisibility[index];
    });
  }
}

class SpeakerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String image;

  const SpeakerCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(image, width: 90, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(specialty),
        ],
      ),
    );
  }
}
