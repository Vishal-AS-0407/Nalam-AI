import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MealLogForm extends StatefulWidget {
  const MealLogForm({super.key});

  @override
  _MealLogFormState createState() => _MealLogFormState();
}

class _MealLogFormState extends State<MealLogForm> {
  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final List<Map<String, dynamic>> _foodLog = [];
  File? _image;

  final String appId = "be2cc170";
  final String appKey = "94c0787b3419a34286acf0552848d866";
  final String url = "https://trackapi.nutritionix.com/v2/natural/nutrients";

  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "x-app-id": appId,
        "x-app-key": appKey,
        "Content-Type": "application/json",
      },
      body: json.encode({"query": foodName}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["foods"] != null && data["foods"].isNotEmpty) {
        final food = data["foods"][0];
        return {
          "calories": food["nf_calories"] ?? 0,
          "protein": food["nf_protein"] ?? 0,
          "fat": food["nf_total_fat"] ?? 0,
          "carbs": food["nf_total_carbohydrate"] ?? 0,
          "fibre": food["nf_dietary_fiber"] ?? 0,
        };
      }
    }
    return {};
  }

  void _logFood(String foodName, int quantity, String unit) async {
    final nutritionInfo = await getNutritionInfo(foodName);

    setState(() {
      _foodLog.add({
        "food": foodName,
        "quantity": quantity,
        "unit": unit,
        "calories": nutritionInfo["calories"] ?? 0,
        "protein": nutritionInfo["protein"] ?? 0,
        "fat": nutritionInfo["fat"] ?? 0,
        "carbs": nutritionInfo["carbs"] ?? 0,
        "fibre": nutritionInfo["fibre"] ?? 0,
      });
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Widget _buildFoodLog() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _foodLog.length,
      itemBuilder: (context, index) {
        final food = _foodLog[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: ListTile(
            title: Text(
              "${food['food']} - ${food['quantity']} ${food['unit']}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Calories: ${food['calories']} kcal"),
                Text("Protein: ${food['protein']} g"),
                Text("Fat: ${food['fat']} g"),
                Text("Carbs: ${food['carbs']} g"),
                Text("Fibre: ${food['fibre']} g"),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _foodController,
            decoration: InputDecoration(
              labelText: 'Enter Food Name',
              labelStyle: TextStyle(color: Color(0xFF006E7F)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              labelStyle: TextStyle(color: Color(0xFF006E7F)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _unitController,
            decoration: InputDecoration(
              labelText: 'Unit (grams, bowls, count)',
              labelStyle: TextStyle(color: Color(0xFF006E7F)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final foodName = _foodController.text;
              final quantity = int.tryParse(_quantityController.text) ?? 0;
              final unit = _unitController.text;
              if (foodName.isNotEmpty && quantity > 0 && unit.isNotEmpty) {
                _logFood(foodName, quantity, unit);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00A0B0),
              foregroundColor: Colors.white,
            ),
            child: Text("Log Food"),
          ),
          SizedBox(height: 20),
          Text(
            "Take a picture of your meal plate and get nutrition analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E7F),
            ),
          ),
          _buildFoodLog(),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shadowColor: Colors.grey.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: Image.asset(
              'assets/icons/cam.png',
              height: 24,
              width: 24,
            ),
            label: Text("Snap"),
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.file(_image!),
            ),
        ],
      ),
    );
  }
}
