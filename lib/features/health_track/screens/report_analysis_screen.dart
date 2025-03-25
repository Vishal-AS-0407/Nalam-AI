import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'report_service.dart';
import 'report_viewer_widget.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  _ReportAnalysisScreenState createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  bool isLoading = false;
  bool isAnalyzing = false;
  List<Map<String, dynamic>> reports = [];

  // Initialize with Indian languages
  Map<String, String> supportedLanguages = {
    "en": "English",
    "hi": "Hindi",
    "bn": "Bengali",
    "gu": "Gujarati",
    "kn": "Kannada",
    "ml": "Malayalam",
    "mr": "Marathi",
    "od": "Odia",
    "pa": "Punjabi",
    "ta": "Tamil",
    "te": "Telugu"
  };

  // Set default language to English
  String selectedLanguage = 'en';
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);

      // Load languages and reports in parallel
      await Future.wait([
        _loadLanguages(),
        _loadReports(),
      ]);
    } catch (e) {
      _showError('Error loading initial data', e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadLanguages() async {
    try {
      final languages = await _reportService.getSupportedLanguages();
      setState(() {
        supportedLanguages = Map<String, String>.from(languages);
      });
    } catch (e) {
      // If API fails, we'll use the default languages
      debugPrint('Failed to load languages: $e');
    }
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          isExpanded: true,
          hint: const Text('Select Language'),
          icon: const Icon(Icons.language, color: Colors.teal),
          items: supportedLanguages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => selectedLanguage = newValue);
            }
          },
        ),
      ),
    );
  }

  Future<void> _loadReports() async {
    if (isLoading) return;

    try {
      final loadedReports = await _reportService.getReports();
      setState(() => reports = loadedReports);
    } catch (e) {
      _showError('Error loading reports', e);
    }
  }

  Future<void> _uploadReport() async {
    try {
      // Request storage permissions if needed
      // Note: Add necessary permission handlers for iOS/Android

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData:
            true, // This ensures we get the file bytes even if path is null
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => isAnalyzing = true);

        final pickedFile = result.files.first;

        // Handle both file path and bytes
        File? file;
        if (pickedFile.path != null) {
          file = File(pickedFile.path!);
        } else if (pickedFile.bytes != null) {
          // Create temporary file from bytes if path is null
          final tempDir = await Directory.systemTemp.create();
          file = File('${tempDir.path}/temp_report.pdf');
          await file.writeAsBytes(pickedFile.bytes!);
        }

        if (file == null) {
          throw Exception('Could not access the selected file');
        }

        // Pass the selected language to the service
        final response =
            await _reportService.analyzeReport(file, selectedLanguage);

        if (!mounted) return; // Check if widget is still mounted

        // Insert the new report at the beginning of the list
        setState(() {
          reports.insert(0, response);
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Report analyzed successfully in ${supportedLanguages[selectedLanguage] ?? "selected language"}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error analyzing report', e);
    } finally {
      if (mounted) {
        setState(() => isAnalyzing = false);
      }
    }
  }

  void _showError(String title, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(error.toString(), style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      appBar: AppBar(
        title: const Text('Health Report Analysis',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 12, 141, 145),
        elevation: 4,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language for Analysis:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLanguageDropdown(),
                  ],
                ),
              ),
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
          if (isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing Report...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !isLoading && !isAnalyzing
          ? FloatingActionButton.extended(
              onPressed: _uploadReport,
              icon: Image.asset('assets/icons/upload.png', height: 44),
              label:
                  const Text('Upload', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color.fromARGB(255, 3, 106, 115),
            )
          : null,
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined,
                size: 64, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'No Reports Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a medical report to get started',
              style: TextStyle(color: Color.fromARGB(255, 2, 116, 114)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _uploadReport,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('Upload Report',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          final bool hasTranslation = report['report_content'] != null &&
              report['report_content']['translated_analysis'] != null;

          return ReportViewerWidget(
            report: report,
            showTranslated: hasTranslation,
          );
        },
      ),
    );
  }
}
