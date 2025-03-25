import 'package:flutter/material.dart';
import 'package:nurture_sync/features/community/events_page.dart';
import 'exercise_tracking_screen.dart';
import 'report_analysis_screen.dart';
import 'profile_screen.dart';
import 'package:nurture_sync/features/chatbot/syncbot.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'medicine_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePageContent(userData: userData),
      ExerciseTrackingScreen(),
      ReportAnalysisScreen(),
      EventsPage(),
      SyncBotPage(),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      appBar: AppBar(
        title: const Text(
          'Nurture Sync',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF006E7F),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HealthProfile()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Lottie.asset(
                  'assets/animations/user.json', // Correct path to your animation
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Image.asset('assets/icons/home.png', width: 24, height: 24),
            title: const Text("Home"),
            selectedColor: const Color(0xFF005F73),
          ),
          SalomonBottomBarItem(
            icon:
                Image.asset('assets/icons/exercise.png', width: 24, height: 24),
            title: const Text("Exercise"),
            selectedColor: const Color(0xFF005F73),
          ),
          SalomonBottomBarItem(
            icon: Image.asset('assets/icons/report.png', width: 24, height: 24),
            title: const Text("Reports"),
            selectedColor: const Color(0xFF005F73),
          ),
          SalomonBottomBarItem(
            icon: Image.asset('assets/images/community.png',
                width: 24, height: 24),
            title: const Text("Community"),
            selectedColor: const Color(0xFF005F73),
          ),
          SalomonBottomBarItem(
            icon: Image.asset('assets/images/bot_avatar.png',
                width: 24, height: 24),
            title: const Text("SyncBot"),
            selectedColor: const Color(0xFF005F73),
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const HomePageContent({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Hello ${userData?['full_name'] ?? 'User'}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E7F),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 4,
          ),
          Text(
            DateFormat('EEEE, MMM d, y')
                .format(DateTime.now()), // Example: Monday, Feb 13, 2025
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF006E7F),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Your Daily Health Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006E7F),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircularProgressBar("Steps", 6500, 10000),
                    _buildCircularProgressBar("Sleep", 6, 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Daily Tips & Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E7F),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTipCard(
                    "Drink 8 glasses of water!", "assets/icons/water.png"),
                _buildTipCard("Walk for 30 minutes!", "assets/icons/walk.png"),
                _buildTipCard("Eat a balanced diet!", "assets/icons/food.png"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upcoming Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E7F),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAppointmentCard("Dec 28, 2024", "Doctor's Visit"),
                _buildAppointmentCard("Dec 30, 2024", "Lab Test"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWeightTrackingGraph(),
          const SizedBox(height: 20),

          _buildMedicineAnalysisCard(context),
          const SizedBox(height: 20),
          const SizedBox(height: 20),

          const AnimatedRoadmapWidget(), // Use the animated roadmap widget here
        ],
      ),
    );
  }

  Widget _buildMedicineAnalysisCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const medicineAnalysisScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006E7F), Color(0xFF00A0B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Medicine Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Analyze your medicines and get detailed information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgressBar(String label, int value, int total) {
    double percentage = value / total;
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE0F7FA),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF94D2BD)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF006E7F),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String tip, String assetPath) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF006E7F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(String date, String title) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E7F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF006E7F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrackingGraph() {
    final List<FlSpot> weightData = [
      FlSpot(0, 75),
      FlSpot(1, 76),
      FlSpot(2, 78),
      FlSpot(3, 80),
    ];

    void addWeight(BuildContext context) {
      final TextEditingController weightController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Today\'s Weight'),
            content: TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final double? newWeight =
                      double.tryParse(weightController.text);
                  if (newWeight != null) {
                    weightData
                        .add(FlSpot(weightData.length.toDouble(), newWeight));
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight Tracking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006E7F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.5),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) => Text(
                                'Day ${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              getTitlesWidget: (value, _) => Text(
                                '${value.toInt()} kg',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: weightData,
                            isCurved: true,
                            color: const Color(0xFF94D2BD),
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        lineTouchData: LineTouchData(enabled: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () => addWeight(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A0B0), Color(0xFF006E7F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Text(
                    "Add Today's Weight",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}

class AnimatedRoadmapWidget extends StatefulWidget {
  const AnimatedRoadmapWidget({super.key});

  @override
  _AnimatedRoadmapWidgetState createState() => _AnimatedRoadmapWidgetState();
}

class _AnimatedRoadmapWidgetState extends State<AnimatedRoadmapWidget> {
  final List<bool> achievedSteps = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your goals for Today',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006E7F),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(achievedSteps.length, (index) {
          return buildRoadmapStep(
            stepNumber: index + 1,
            title: stepTitles[index],
            description: stepDescriptions[index],
            reward: stepRewards[index],
            animationPath: stepAnimations[index],
            achieved: achievedSteps[index],
            onCheckboxChanged: (bool? value) {
              setState(() {
                achievedSteps[index] = value ?? false;
              });
            },
          );
        }),
        const SizedBox(height: 20),
        buildCompletionMessage(),
      ],
    );
  }

  final List<String> stepTitles = [
    "Set Daily Water Intake Goal",
    "Track Balanced Meals",
    "Consistent Sleep Pattern",
    "Stress Management",
  ];

  final List<String> stepDescriptions = [
    "Stay hydrated! Aim for at least 4 liters of water today. You've been drinking less than 2 liters for the past 3 days—let's build a great habit! 💧",
    "Fuel your body right! Log 3 balanced meals today. Tap to get personalized diet recommendations. 🍽️",
    "Great job on your sleep routine! You’ve maintained a healthy pattern for 7 days. Let’s keep it going—sleep 30 minutes earlier tonight. 🌙✨",
    "Take a mindful break! Practice 15 minutes of meditation and crush your workout today. Your body and mind will thank you! 🧘‍♂️💪",
  ];

  final List<String> stepRewards = [
    "10 Reward Points",
    "20 Reward Points",
    "30 Reward Points",
    "50 Reward Points",
  ];

  final List<String> stepAnimations = [
    "assets/animations/water.json",
    "assets/animations/diet.json",
    "assets/animations/sleep.json",
    "assets/animations/meditation2.json",
  ];

  Widget buildRoadmapStep({
    required int stepNumber,
    required String title,
    required String description,
    required String reward,
    required String animationPath,
    required bool achieved,
    required ValueChanged<bool?> onCheckboxChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: achieved ? const Color(0xFF006E7F) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: achieved ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0), // Decreased padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Align elements
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006E7F),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: achieved,
                        onChanged: onCheckboxChanged,
                        activeColor: const Color.fromARGB(255, 1, 139, 160),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF006E7F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    // Centering the Lottie animation
                    child: SizedBox(
                      width: 100, // Increased size for Lottie animation
                      height: 100,
                      child: Lottie.asset(animationPath),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompletionMessage() {
    // Check if all steps are achieved
    bool allAchieved = achievedSteps.every((achieved) => achieved);

    return Center(
      child: Column(
        children: [
          if (allAchieved) ...[
            const Text(
              "Great Job!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006E7F),
              ),
            ),
            const SizedBox(height: 10),
            Lottie.asset(
              "assets/animations/congrats.json",
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 10),
            const Text(
              "Keep going to unlock more rewards!",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF006E7F),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
