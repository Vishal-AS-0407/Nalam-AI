import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportService {
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

  Future<Map<String, dynamic>> getSupportedLanguages() async {
    try {
      final response = await _dio.get(
        '$baseUrl/reports/languages',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to fetch languages: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to fetch supported languages: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    await loadUserData();

    try {
      final response = await _dio.get(
        '$baseUrl/reports/$userId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final reports = List<Map<String, dynamic>>.from(response.data);

        // Convert all reports to new format
        return reports.map((report) {
          final content = report['report_content'];
          if (content is String) {
            // Convert old format to new format
            report['report_content'] = {
              'raw_analysis': content,
              'metadata': {
                'language': 'English',
              },
            };
          }
          return report;
        }).toList();
      } else {
        throw Exception('Failed to fetch reports: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeReport(
      File file, String languageCode) async {
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
        '$baseUrl/reports/analyze',
        data: formData,
        queryParameters: {
          'user_id': userId,
          'language': languageCode,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        // Response will now come in the new structured format directly from backend
        final responseData = Map<String, dynamic>.from(response.data);
        return responseData;
      } else {
        throw Exception('Failed to analyze report: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Unexpected error during analysis: $e');
    }
  }
}
