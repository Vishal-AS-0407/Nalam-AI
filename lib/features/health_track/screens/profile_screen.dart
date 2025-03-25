import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';
import 'package:nurture_sync/services/health_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'edit_profile.dart';
import 'package:http/http.dart' as http;

class HealthProfile extends StatefulWidget {
  const HealthProfile({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<HealthProfile> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? profileData;
  Map<String, dynamic> healthData = {};
  final HealthService _healthService = HealthService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _loadUserData(),
      _initializeHealthData(),
      _loadProfileData(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString != null) {
        setState(() {
          userData = jsonDecode(userDataString);
        });
        await _fetchUpdatedProfile(userData?['_id']);
        await _loadProfileData();
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _fetchUpdatedProfile(String? userId) async {
    if (userId == null) return;

    try {
      final Uri url =
          Uri.parse('http://192.168.123.247:8000/api/profile/$userId');

      final response = await http.get(
        // Change PUT to GET since we're fetching the profile
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> profileData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileData', jsonEncode(profileData));
      } else {
        print("Failed to fetch updated profile: ${response.body}");
      }
    } catch (e) {
      print("Error fetching updated profile: $e");
    }
  }

  Future<void> _loadProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dataString = prefs.getString('profileData');

      if (dataString != null) {
        setState(() {
          profileData = jsonDecode(dataString);
        });
      }
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  Future<void> _initializeHealthData() async {
    try {
      bool permissionsGranted = await _healthService.requestPermissions();
      if (permissionsGranted) {
        bool authorized = await _healthService.requestHealthAuthorization();
        if (authorized) {
          Map<String, dynamic> data =
              await _healthService.fetchLatestHealthData();
          setState(() {
            healthData = data;
          });
        }
      }
    } catch (e) {
      print("Error loading health data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F0F4),
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
        backgroundColor: const Color(0xFF005F73),
        title: const Text(
          'Health Profile',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/user_avatar.png'), // Should be able to upload an image
              ),
              const SizedBox(height: 8),
              Text(
                userData!['full_name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                userData!['profession'] ?? 'Not specified',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF006D77),
                ),
              ),
              const SizedBox(height: 20),

              // Health Details
              _buildInfoRow('Health Condition',
                  userData!['patient_data']['current_diagnosis']),
              _buildInfoRow(
                  'Medications', userData!['patient_data']['medications']),
              _buildInfoRow('Age', userData!['age']),
              _buildInfoRow('Current Symptoms',
                  userData!['patient_data']['current_symptoms']),
              _buildInfoRow(
                  'Health Goals', userData!['patient_data']['health_goals']),
              _buildInfoRow('Exercise Routine',
                  userData!['patient_data']['exercise_routine']),
              SizedBox(height: 30),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfileForm()),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F73),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              const SizedBox(height: 20),

              // Recent Analysis Section
              const Text(
                'Recent Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003B4C),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard('${healthData["steps"] ?? "N/A"}', 'Steps'),
                  _buildMetricCard(
                      '${profileData?["heart_rate"] ?? "N/A"}', 'Heart Rate'),
                  _buildMetricCard(
                      (profileData?["sleep_duration"] as num?)
                              ?.toStringAsFixed(1) ??
                          "N/A",
                      'Sleep Hours'),
                ],
              ),

// if profile data is not null
//then build metric cards for the remaining details in profile data, style them diffrently
              const SizedBox(height: 20),

              if (profileData != null) ...[
                const SizedBox(height: 10),
                _buildStyledCard(
                    'Sleep Duration',
                    (profileData?["sleep_duration"] is num)
                        ? (profileData?["sleep_duration"] as num)
                            .toStringAsFixed(1)
                        : "N/A",
                    const Color(0xFF94D2BD)),
                _buildStyledCard(
                    'Stress Level',
                    '${profileData?["stress_level"] ?? "N/A"}',
                    const Color(0xFF005F73)),
                _buildStyledCard(
                    'Allergies',
                    '${profileData?["medicine_allergies"] ?? "N/A"}',
                    const Color(0xFF52B69A)),
              ],

              const SizedBox(height: 20),

              // Share Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF94D2BD), Color(0xFF005F73)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x80005F73),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Share Functionality
                    await Share.share(
                        'Check out my health profile on Nurture Sync! Link: https://nurturesynchealth.com/shyamala');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Share My Profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(width: 8),
                      Image.asset('assets/icons/share.png',
                          height: 20, width: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String title, dynamic value) {
    String displayValue;

    if (value == null) {
      displayValue = 'N/A'; // Handle null values
    } else if (value is List) {
      displayValue =
          value.isNotEmpty ? value.join(", ") : 'N/A'; // Join list values
    } else {
      displayValue = value.toString(); // Convert other types to string
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003B4C),
            ),
          ),
          Flexible(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF006D77),
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis, // Prevents text overflow
              maxLines: 2, // Limits text to 2 lines
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricCard(String value, String label) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
