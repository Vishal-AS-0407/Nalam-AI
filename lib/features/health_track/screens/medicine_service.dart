import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicineService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://192.168.123.247:8000/api';
  String? userId;

  Future<void> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null) {
        throw Exception('User data not found');
      }

      Map<String, dynamic> userData = jsonDecode(userDataString);
      userId = userData['_id'];

      if (userId == null) {
        throw Exception('Invalid user data format');
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getmedicines() async {
    await loadUserData();

    try {
      final response = await _dio.get(
        '$baseUrl/medicines/$userId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch medicines: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> analyzemedicine(File file) async {
    await loadUserData();

    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/medicines/analyze',
        data: formData,
        queryParameters: {'user_id': userId},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            'Failed to analyze medicine: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
