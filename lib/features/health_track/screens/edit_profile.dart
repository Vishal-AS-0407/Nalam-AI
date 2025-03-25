import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bpController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController sleepController = TextEditingController();
  TextEditingController familyHistoryController = TextEditingController();

  String? exerciseLevel;
  String? stressLevel;
  String? medicineAllergies;
  File? reportFile;
  String? userId;
  bool isProfileExisting = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        if (userData.containsKey('_id')) {
          setState(() {
            userId = userData['_id'];
          });
          await _fetchUserProfile();
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUserProfile() async {
    if (userId == null) return;

    try {
      var response = await http
          .get(Uri.parse('http://192.168.123.247:8000/api/profile/$userId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          isProfileExisting = true;
          weightController.text = data['weight']?.toString() ?? "";
          heightController.text = data['height']?.toString() ?? "";
          exerciseLevel = data['exercise_level'];
          bpController.text = data['blood_pressure']?.toString() ?? "";
          heartRateController.text = data['heart_rate']?.toString() ?? "";
          sleepController.text = data['sleep_duration']?.toString() ?? "";
          familyHistoryController.text = data['family_history'] ?? "";
          stressLevel = data['stress_level'];
          medicineAllergies = data['medicine_allergies']?.toString();
        });
      } else if (response.statusCode == 404) {
        setState(() => isProfileExisting = false);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate() && userId != null) {
      setState(() => isLoading = true);
      try {
        final url = isProfileExisting
            ? 'http://192.168.123.247:8000/api/profile/update_profile/$userId'
            : 'http://192.168.123.247:8000/api/profile/create';

        var request = http.MultipartRequest(
          isProfileExisting ? 'PUT' : 'POST',
          Uri.parse(url),
        );

        request.fields.addAll({
          "user_id": userId!,
          if (weightController.text.isNotEmpty) "weight": weightController.text,
          if (heightController.text.isNotEmpty) "height": heightController.text,
          if (exerciseLevel != null) "exercise_level": exerciseLevel!,
          if (bpController.text.isNotEmpty) "blood_pressure": bpController.text,
          if (heartRateController.text.isNotEmpty)
            "heart_rate": heartRateController.text,
          if (sleepController.text.isNotEmpty)
            "sleep_duration": sleepController.text,
          if (familyHistoryController.text.isNotEmpty)
            "family_history": familyHistoryController.text,
          if (stressLevel != null) "stress_level": stressLevel!,
          if (medicineAllergies != null)
            "medicine_allergies": medicineAllergies!,
        });

        if (reportFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'medical_report',
            reportFile!.path,
          ));
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() => isProfileExisting = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(isProfileExisting
                    ? "Profile updated successfully!"
                    : "Profile created successfully!")),
          );
          await _fetchUserProfile(); // Refresh profile data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Failed to ${isProfileExisting ? 'update' : 'create'} profile: $responseBody")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Error ${isProfileExisting ? 'updating' : 'creating'} profile: $e")),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // Rest of the widget build methods remain the same...
  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        reportFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Color(0xFF005F73),
      ),
      backgroundColor: const Color(0xFFD9F0F4),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSection("Weight (kg)", weightController),
                buildSection("Height (cm)", heightController),
                buildDropdown(
                    "Exercise Level",
                    [
                      "Sedentary",
                      "Lightly Active",
                      "Moderately Active",
                      "Very Active"
                    ],
                    (value) => setState(() => exerciseLevel = value),
                    exerciseLevel),
                buildSection("Blood Pressure", bpController),
                buildSection("Heart Rate", heartRateController),
                buildSection("Sleep Duration (hrs)", sleepController),
                buildSection("Family History", familyHistoryController),
                buildDropdown(
                    "Stress Level",
                    ["High", "Medium", "Low"],
                    (value) => setState(() => stressLevel = value),
                    stressLevel),
                buildDropdown(
                    "Medicine Allergies",
                    ["Yes", "No"],
                    (value) => setState(() => medicineAllergies = value),
                    medicineAllergies),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _pickFile,
                    child: Text("Upload Medical Report"),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005F73),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        isProfileExisting ? "Update Profile" : "Create Profile",
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSection(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => value!.isEmpty ? "Enter $label" : null,
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options,
      Function(String?) onChanged, String? selectedValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            value: options.contains(selectedValue)
                ? selectedValue
                : null, // Fix here
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? "Select $label" : null,
          )
        ],
      ),
    );
  }
}
