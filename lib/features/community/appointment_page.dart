import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final List<Map<String, String>> doctors = [
    {
      "name": "Dr. Sunita Desai",
      "specialty": "Diabetes Specialist",
      "image": "assets/images/speaker1.jpg"
    },
    {
      "name": "Dr. Neil Parikh",
      "specialty": "Cardiologist",
      "image": "assets/images/speaker2.jpg"
    },
    {
      "name": "Dr. Arpan Verma",
      "specialty": "General Physician",
      "image": "assets/images/speaker3.jpg"
    },
    {
      "name": "Dr. Vijetha",
      "specialty": "General Physician",
      "image": "assets/images/speaker4.jpg"
    },
  ];

  String? selectedDoctor;
  String? selectedTime;

  final List<String> timeSlots = ["10:00 AM", "11:00 AM", "2:00 PM", "4:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Book an Appointment"),
          backgroundColor: const Color(0xFF0D7377)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Doctor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDoctor = doctor["name"];
                      });
                    },
                    child: Card(
                      color: selectedDoctor == doctor["name"]
                          ? Colors.blue[100]
                          : Colors.white,
                      child: Column(
                        children: [
                          Image.asset(doctor["image"]!, width: 80, height: 80),
                          Text(doctor["name"]!,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select a Time Slot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTime == time,
                  onSelected: (selected) {
                    setState(() {
                      selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedDoctor != null && selectedTime != null
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Appointment booked with $selectedDoctor at $selectedTime")),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7377)),
              child: const Text("Confirm Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
